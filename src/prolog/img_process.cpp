#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>
#include <cxxabi.h>
#include <string>
#include <typeinfo>
#include <cmath>

#include "../utils/utils.h"
#include "../socket/message.h"
#include "../socket/socket_server.h"
#include "../sampler/sampler.h"

#include <SWI-cpp.h>
#include <opencv/cv.h>

using namespace std;

const string GetClearName(const char* name) {
    int status = -1;
    char* clearName = abi::__cxa_demangle(name, NULL, NULL, &status);
    const char* const demangledName = (status==0) ? clearName : name;
    string ret_val(demangledName);
    free(clearName);
    return ret_val;
}

const int sendMsg(MyMessage* msg, char* scktmp) {
    int connfd;
    sprintf(scktmp, "../../tmp/scktmp%05d", getpid());
    connfd = client_socket_conn("../../tmp/img_server.sock", scktmp);

    if (connfd < 0) {
	perror("[CLIENT] ERROR connecting server");
	return FALSE;
    }
    char* buff = (char *) malloc(sizeof(MyMessage));
    memcpy(buff, msg, sizeof(MyMessage));
    int msg_size = send(connfd, buff, sizeof(MyMessage), 0);
    free(buff);
    free(msg);
    buff = NULL;
    msg = NULL;
    if (msg_size < 0) {
	perror("[CLIENT] ERROR sending message to server");
	return -1;
    }
    return connfd;
}

/* load_img('image_path', PID).
 * Start an image processing server, load image and unifies PID 
 * with the server.
 */
PREDICATE(load_img, 2) {
    char* img_path = (char*) A1;
    pid_t server_pid;
    server_pid = fork();

    switch(server_pid) {
    case -1:
	perror("Fork server error");
	exit(EXIT_FAILURE);
	break;
    case 0:
	execlp("../socket/img_server", "img_server", img_path, (char *) NULL);
	break;
    default:
    {
	// if father process, asstert image size.

	sleep(1); // wait server

	// require image size and assert it, for later reference
	MyMessage *msg = myCreateMsg(MY_MSG_REQUIRE_SIZE);
	int connfd;
	char scktmp[256];
	sprintf(scktmp, "../../tmp/scktmp05%d", getpid());
	connfd = client_socket_conn("../../tmp/img_server.sock", scktmp);
	if (connfd < 0) {
	    perror("[CLIENT] ERROR creating server");
	    return FALSE;
	}
	char* buff = (char *) malloc(sizeof(MyMessage));
	memcpy(buff, msg, sizeof(MyMessage));
	int msg_size = send(connfd, msg, sizeof(MyMessage), 0);
	if (msg_size < 0) {
	    perror("[CLIENT] ERROR sending message");
	    return FALSE;
	}
	free(buff);
	buff = NULL;
	free(msg);
	msg = NULL;

	// wait for return message from server
	while (1) {
	    buff = (char *) malloc(sizeof(MyMessage));
	    MyMessage* msg_back = (MyMessage *) malloc(sizeof(MyMessage));    
	    int backmsg_size = recv(connfd, buff, sizeof(MyMessage), 0);
	    memcpy(msg_back, buff, sizeof(MyMessage));
	    free(buff);
	    buff = NULL;
	    if (backmsg_size < 0) {
		perror("[CLIENT] ERROR recieving message from server");
		free(msg_back);
		msg_back = NULL;
		return FALSE;
	    } else if (msg_back->msg_type == MY_MSG_MSGGOT) {
		client_socket_close(connfd, scktmp);
		int size_x = msg_back->x;
		int size_y = msg_back->y;
		PlTermv args(2);
		args[0] = size_x;
		args[1] = size_y;
		PlTermv size(1);
		size[0] = PlCompound("img_size", args);
		PlCall("assertz", size);
		cout << "assertz(img_size(" << size_x << ", " << size_y  << "))."<< endl;
		free(msg_back);
		msg_back = NULL;

		printf("Image loaded, ");
		printf("server pid = %d\n", server_pid);

		return A2 = (int) server_pid;
	    } else {
		printf("[CLIENT] Unexpected message from image server.\n");
		free(msg_back);
		msg_back = NULL;
		return FALSE;
	    }

    	}
	break;
    }
    }
    return TRUE;
}

/* img_release().
 * Release IplImage and MyQuantifiedImg (if quantified) and then terminate
 * the server.
 */
PREDICATE(img_release, 0) {
    MyMessage* msg = myCreateMsg(MY_MSG_RLS_IMG);
    
    int connfd;
    char scktmp[256];
    sprintf(scktmp, "../../tmp/scktmp%05d", getpid());
    connfd = client_socket_conn("../../tmp/img_server.sock", scktmp);

    if (connfd < 0) {
	perror("[CLIENT] ERROR connecting server");
	return FALSE;
    }
    char* buff = (char *) malloc(sizeof(MyMessage));
    memcpy(buff, msg, sizeof(MyMessage));
    int msg_size = send(connfd, msg, sizeof(MyMessage), 0);
    free(buff);
    buff = NULL;
    free(msg);
    msg = NULL;
    if (msg_size < 0) {
	perror("[CLIENT] ERROR message sending");
	return FALSE;
    }
    // wait for return message from server
    while (1) {
	buff = (char *) malloc(sizeof(MyMessage));
	MyMessage* msg_back = (MyMessage *) malloc(sizeof(MyMessage));    
	int backmsg_size = recv(connfd, buff, sizeof(MyMessage), 0);
	memcpy(msg_back, buff, sizeof(MyMessage));
	free(buff);
	buff = NULL;
	if (backmsg_size < 0) {
	    perror("[CLIENT] ERROR recieving message from server");
	    free(msg_back);
	    msg_back = NULL;
	    return FALSE;
	} else if (msg_back->msg_type == MY_MSG_MSGGOT) {
	    client_socket_close(connfd, scktmp);
	    printf("[CLIENT] Confirmed: Image released.\n");
	    free(msg_back);
	    msg_back = NULL;
	    return TRUE;
	} else {
	    printf("[CLIENT] Unexpected message from image server.\n");
	    free(msg_back);
	    msg_back = NULL;
	    return FALSE;
	}
    }
}

/* img_quantify(N).
 * Quantify original image, use kmeans to reduce it to N colors.
 */
PREDICATE(img_quantify, 1) {
    int cluster_num = (int) A1;
    
    MyMessage* msg = myCreateMsg(MY_MSG_QTFY_IMG);
    msg->palette_size = cluster_num;

    int connfd;
    char scktmp[256];
    sprintf(scktmp, "../../tmp/scktmp%05d", getpid());
    connfd = client_socket_conn("../../tmp/img_server.sock", scktmp);

    if (connfd < 0) {
	perror("[CLIENT] ERROR connecting server");
	return FALSE;
    }
    char* buff = (char *) malloc(sizeof(MyMessage));
    memcpy(buff, msg, sizeof(MyMessage));
    int msg_size = send(connfd, buff, sizeof(MyMessage), 0);
    free(buff);
    free(msg);
    buff = NULL;
    msg = NULL;

    if (msg_size < 0) {
	perror("[CLIENT] ERROR message sending");
	return FALSE;
    } else {
	printf("[CLIENT] message sent.\n");
    }
    // wait for return message from server
    while (1) {
	buff = (char *) malloc(sizeof(MyMessage));
	MyMessage* msg_back = (MyMessage *) malloc(sizeof(MyMessage));
	int backmsg_size = recv(connfd, buff, sizeof(MyMessage), 0);
	memcpy(msg_back, buff, sizeof(MyMessage));
	free(buff);
	buff = NULL;

	if (backmsg_size < 0) {
	    perror("[CLIENT] ERROR recieving message from server");
	    free(msg_back);
	    msg_back = NULL;
	    return FALSE;
	} else if (msg_back->msg_type == MY_MSG_MSGGOT) {
	    client_socket_close(connfd, scktmp);
	    printf("[CLIENT] Confirmed: Image quantified.\n");
	    free(msg_back);
	    msg_back = NULL;
	    break;
	} else {
	    printf("[CLIENT] Unexpected message from image server.\n");
	    free(msg_back);
	    msg_back = NULL;
	    return FALSE;
	}
    }

    return TRUE;
}

/*

 * hv_point_line(X, Y, L): sample hv_point on line L.
 * High variance point on line L.
 * line(l_name, k, b):
 *     where k and b are parameter of line function: y = k*x + b

PREDICATE(hv_point_line, 3) {
    // if line argument is variable, fail this backtracking, do not sample;
    // if x or y are grounded, fail this backtracking, do not sample.
    if (
	(PL_is_variable(A3.ref)) || 
	(PL_is_ground(A1.ref) || PL_is_ground(A2.ref))
	) {
	return FALSE;
    } else {
	// Get line_start and line_end point:
	// query for line(A3, K, B).
	PlTermv args(3); // 3 arguments for line/3
	args[0] = A3; // binding 1st argument of line/3 to A3
	
	// get parameter k and b
	double k, b;
	if (PlCall("line", args) ==  TRUE) {
	    k = (double) args[1];
	    b = (double) args[2];
	} else {
	    cout << "No line named as " << (char *) A1 << "." << endl;
	    return FALSE;
	}
	// compute start point
	int x_s, y_s, x_e, y_e;
	y_s = (k*0 + b >= 0) ? (int) (round(k*0 + b)) : 0;
	x_s = (y_s == 0) ? (int) (round((0 - b)/k)) : 0;
        // ask for image size
	PlTermv size(2);
	int width, height;
	if (PlCall("img_size", size) == TRUE) {
	    width = (int) size[0];
	    height = (int) size[1];
	} else {
	    cout << "Error reading image size." << endl;
	    return FALSE;
	}
	y_e = (k*width + b) < height ? (int) (round(k*width + b)) : height - 1;
	x_e = (y_e == height - 1) ? (int) round((height - 1 - b)/k) : width - 1; 
	// send message
	MyMessage* msg = myCreateMsg(MY_MSG_LINE_SAMPLER);
	msg->sample_on_quant_img = TRUE;
	msg->line_start = cvPoint(x_s, y_s);
	msg->line_end = cvPoint(x_e, y_e);
	msg->sampler_type = MY_CV_SAMPLE_DESCRIPTOR_PALETTE;
	// query if defined neighbor_size in prolog
	PlTermv neighbor_size(1);
	if (PlCall("neighbor_size", neighbor_size) == FALSE)
	    msg->sampler_neighbor_size = LINE_SAMPLER_NEIGHBOR_SIZE;
	else
	    msg->sampler_neighbor_size = (int) neighbor_size[0];
	if (sendMsg(msg) == FALSE) {
	    return FALSE;
	}

	// wait for response
	while (1) {
	    buff = (char *) malloc(sizeof(MyMessage));
	    MyMessage* msg_back = (MyMessage *) malloc(sizeof(MyMessage));
	    int backmsg_size = recv(connfd, buff, sizeof(MyMessage), 0);
	    memcpy(msg_back, buff, sizeof(MyMessage));
	    free(buff);
	    buff = NULL;

	    if (backmsg_size < 0) {
		perror("[CLIENT] ERROR recieving message from server");
		free(msg_back);
		msg_back = NULL;
		return FALSE;
	    } else if (msg_back->msg_type == MY_MSG_MSGGOT) {
		client_socket_close(connfd, scktmp);
		printf("[CLIENT] Confirmed: Image quantified.\n");
		free(msg_back);
		msg_back = NULL;
		break;
	    } else {
		printf("[CLIENT] Unexpected message from image server.\n");
		free(msg_back);
		msg_back = NULL;
		return FALSE;
	    }
	}
    }
    return TRUE;
}

 * hv_point_segment(X, Y, L): sample hv_point on line segment S
 * High variance point on line sampler

PREDICATE(hv_point_segment, 3) {
    // if line argument is variable, fail this backtracking, do not sample;
    // if x or y are grounded, fail this backtracking, do not sample.
    if (
	(!PL_is_variable(A3.ref)) || 
	(PL_is_ground(A1.ref) || PL_is_ground(A2.ref))
	) {
	return FALSE;
    } else {
	MyMessage* msg = myCreateMsg(MY_MSG_LINE_SAMPLER);
    }
    return TRUE;
}

*/

// edge_point predicate
PREDICATE(edge_point, 4) {
    // if value argument is variable, fail this backtracking, do not sample;
    if 	(!PL_is_variable(A3.ref)) {
	return FALSE;
    } else {
	int x = (int) A1;
	int y = (int) A2;

	PlTermv size(2);
	int width = 0, height = 0;
	try {
	    if (PlCall("img_size", size) == TRUE) {
		width = (int) size[0];
		height = (int) size[1];
	    }
	} catch (PlException &ex) {
	    cerr << "Error point position." << endl;
	    return FALSE;
	}

	
	if (x < 0 || x >= width || y < 0 || y >= height) {
	    cout << "Wrong point position" << endl;
	    return FALSE;
	}
	
	// send message
	MyMessage* msg = myCreateMsg(MY_MSG_PALETTE_EDGE_POINT);
	char scktmp[256];
	msg->x = x;
	msg->y = y;
	msg->sample_on_quant_img = TRUE; // use quantiled image
	// query if defined sample_window_size and l_channel_weight in prolog
	// TODO: not work
	PlTermv window_size(1);

	try { 
	    PlCall("sample_window_size", window_size);
	    msg->sampler_neighbor_size = (int) window_size[0];
	} catch (PlException &ex) { 
	    cout << "Use default window size" << endl;
	    msg->sampler_neighbor_size = LINE_SAMPLER_NEIGHBOR_SIZE;
	}

	PlTermv l_channel_weight(1);

	try { 
	    PlCall("l_channel_weight", l_channel_weight);
	    msg->l_channel_weight = (double) l_channel_weight[0];
	} catch (PlException &ex) { 
	    cout << "Use default L channel weight" << endl;
	    msg->l_channel_weight = L_CHANNEL_WEIGHT;
	}

	if (msg->sampler_neighbor_size%2 != 1) {
	    cout << "Neighbor size should be odd number." << endl;
	    return FALSE;
	}
	int connfd = sendMsg(msg, scktmp);
	if ( connfd < 0) {
	    return FALSE;
	}

	// wait for response
	while (1) {
	    char *buff = (char *) malloc(sizeof(MyMessage));
	    MyMessage* msg_back = (MyMessage *) malloc(sizeof(MyMessage));
	    int backmsg_size = recv(connfd, buff, sizeof(MyMessage), 0);
	    memcpy(msg_back, buff, sizeof(MyMessage));
	    free(buff);
	    buff = NULL;

	    if (backmsg_size < 0) {
		perror("[CLIENT] ERROR recieving message from server");
		free(msg_back);
		msg_back = NULL;
		return FALSE;
	    } else if (msg_back->msg_type == MY_MSG_MSGGOT) {
		client_socket_close(connfd, scktmp);
		cout << "[CLIENT] Confirmed: edge point checked." << endl;

		if (PL_is_variable(A4.ref)) {
		    double max = .0;
		    int max_k = -1;
		    for (int k = 0; k < 4; k++) {
			if (msg_back->scalar.val[k] > max) {
			    max = msg_back->scalar.val[k];
			    max_k = k;
			}
		    }
		    A3 = max;
		    A4 = max_k;
		} else {
		    int dir = (int) A4;
		    A3 = msg_back->scalar.val[dir];
		}

		free(msg_back);
		msg_back = NULL;
		break;
	    } else {
		printf("[CLIENT] Unexpected message from image server.\n");
		free(msg_back);
		msg_back = NULL;
		return FALSE;
	    }
	}
    }
    return TRUE;
}
