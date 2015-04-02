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
    const char* const demangledName = (status == 0) ? clearName : name;
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

const int confirm_img(void) {
    PlTermv size(2);
    try {
	if (PlCall("img_size", size) == TRUE)
	    return TRUE;
	else
	    return FALSE;
    } catch (PlException &ex) {
	cerr << "Image not loaded." << endl;
	return FALSE;
    }
}

const int confirm_quant(void) {
    PlTermv quant_num(1);
    try {
	if (PlCall("quant_num", quant_num) == TRUE)
	    return TRUE;
	else
	    return FALSE;
    } catch (PlException &ex) {
	cerr << "Image not quantified." << endl;
	return FALSE;
    }
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
		// cout << "*** assert img_size/2 ***" << endl;
		client_socket_close(connfd, scktmp);
		int size_x = msg_back->x;
		int size_y = msg_back->y;
		PlTermv args(2);
		args[0] = size_x;
		args[1] = size_y;
		PlTermv size(1);
		size[0] = PlCompound("img_size", args);
		PlCall("assertz", size);
		cout << "[IMG] img_size/2 asserted." << endl;
		free(msg_back);
		msg_back = NULL;

		cout << "[IMG] Image loaded: " << img_path << endl;
		cout << "[IMG] Server pid = " <<  server_pid << endl;

		return A2 = (int) server_pid;
	    } else {
		perror("[CLIENT] ERROR Unexpected message from image server");
		free(msg_back);
		msg_back = NULL;
		return FALSE;
	    }

    	}
	break;
    }
    }

    sleep(1);
    return TRUE;
}

/* img_release().
 * Release IplImage and MyQuantifiedImg (if quantified) and then terminate
 * the server.
 */
PREDICATE(img_release, 0) {
    if (confirm_img() == FALSE) {
	return FALSE;
    }

    sleep(1);
    
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
	    printf("[IMG] Image released.\n");
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

/* img_quantize(N).
 * Quantify original image, use kmeans to reduce it to N colors.
 */
PREDICATE(img_quantize, 1) {
    if (confirm_img() == FALSE) {
	return FALSE;
    }
    
    sleep(1);
    
    int cluster_num = (int) A1;
    
    MyMessage* msg = myCreateMsg(MY_MSG_QTZ_IMG);
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
    }
    // wait for return message from server
    
    CvScalar colorTable[cluster_num]; // quantized color table

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
	    cout << "[IMG] Image is quantized to " << cluster_num << " colors" << endl;
	    for (int i = 0; i < cluster_num; i++)
		colorTable[i] = msg_back->colorTable[i];
	    free(msg_back);
	    msg_back = NULL;
	    break;
	} else {
	    perror("[CLIENT] Unexpected message from image server");
	    free(msg_back);
	    msg_back = NULL;
	    return FALSE;
	}
    }

    /* assert quant_num/1 */
    // cout << "*** assert quant_num/1 ***" << endl;
    PlTermv quant(1);
    PlTermv args_q(1);
    args_q[0] = cluster_num;
    quant[0] = PlCompound("quant_num", args_q);
    PlCall("assertz", quant);
    // cout << "assertz(quant_num(" << cluster_num << "))." << endl;

    /* assert color_diff/3, color_L_diff/3, color_ab_diff/3 */
    cout << "[IMG] color_diff/3, color_L_diff/3, color_ab_diff/3 computed." << endl;
    for (int i = 0; i < cluster_num; i++) {
	for (int j = 0; j < cluster_num; j++) {
	    if (i == j) {
		PlTermv color_diff(1);
		PlTermv color_L_diff(1);
		PlTermv color_ab_diff(1);
		PlTermv args(3);
		args[0] = i;
		args[1] = j;
		args[2] = .0;
		color_diff[0] = PlCompound("color_diff", args);
		color_L_diff[0] = PlCompound("color_L_diff", args);
		color_ab_diff[0] = PlCompound("color_ab_diff", args);
		PlCall("assertz", color_diff);
		PlCall("assertz", color_L_diff);
		PlCall("assertz", color_ab_diff);
		continue;
	    }
	    // color_diff: Euclidean difference of two quantized colors
	    PlTermv color_diff(1);
	    double d = euDist(colorTable[i], colorTable[j], 1.0);
	    PlTermv args_cd(3);
	    args_cd[0] = i;
	    args_cd[1] = j;
	    args_cd[2] = d;
	    color_diff[0] = PlCompound("color_diff", args_cd);
	    PlCall("assertz", color_diff);
	    // cout << "assertz(color_diff(" << 
	    // i << ", " << j << ", " << d << ")." << endl;
	    
	    // color_L_diff: L channel (bright) difference of two colors
	    PlTermv color_L_diff(1);
	    d = abs(colorTable[i].val[0] - colorTable[j].val[0]);
	    PlTermv args_cLd(3);
	    args_cLd[0] = i;
	    args_cLd[1] = j;
	    args_cLd[2] = d;
	    color_L_diff[0] = PlCompound("color_L_diff", args_cLd);
	    PlCall("assertz", color_L_diff);
	    // cout << "assertz(color_L_diff(" << 
	    // i << ", " << j <<  ", " << d << ")." << endl;


	    // color_ab_diff: ab channel Euclidean difference of two colors
	    PlTermv color_ab_diff(1);
	    d = sqrt(
		pow(colorTable[i].val[1] - colorTable[j].val[1], 2)
		+ pow(colorTable[i].val[2] - colorTable[j].val[2], 2)
		);
	    PlTermv args_cabd(3);
	    args_cabd[0] = i;
	    args_cabd[1] = j;
	    args_cabd[2] = d;
	    color_ab_diff[0] = PlCompound("color_ab_diff", args_cabd);
	    PlCall("assertz", color_ab_diff);
	    // cout << "assertz(color_ab_diff(" << 
	    // i << ", " << j <<  ", " << d << ")." << endl;
	}
    }
    
    sleep(1);
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
	    // cout << "No line named as " << (char *) A1 << "." << endl;
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
	    // cout << "Error reading image size." << endl;
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
		printf("[CLIENT] Confirmed: Image quantized.\n");
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

// primitives

/* edge_point(X, Y, V, D):
 * X, Y: point coordinate
 * V: returned edge value
 * D: most probable edge direction, 0 for -, 1 for |, 2 for \, 3 for / (currently only 0 and 1 are supported)
 * Notice: should be used after img_quantize/1
 */

PREDICATE(edge_point, 4) {

    if (confirm_img() == FALSE)
	return FALSE;
    
    if (confirm_quant() == FALSE)
	return FALSE;

    // if value argument is variable, fail this backtracking, do not sample;
    if 	(!PL_is_variable(A3.ref) || PL_is_variable(A1.ref) || PL_is_variable(A2.ref)) {
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
	    cerr << "Error img_size." << endl;
	    return FALSE;
	}

	if (x < 0 || x >= width || y < 0 || y >= height) {
	    // cout << "Point position out of bound." << endl;
	    return FALSE;
	}
	
	// make message
	MyMessage* msg = myCreateMsg(MY_MSG_PALETTE_EDGE_POINT);
	char scktmp[256];
	msg->x = x;
	msg->y = y;
	msg->sample_on_quant_img = TRUE; // use quantized image

	// query if defined sample_window_size and l_channel_weight in prolog
	PlTermv window_size(1);

	try { 
	    PlCall("sample_window_size", window_size);
	    msg->sampler_neighbor_size = (int) window_size[0];
	} catch (PlException &ex) { 
	    // cout << "Use default window size" << endl;
	    msg->sampler_neighbor_size = LINE_SAMPLER_NEIGHBOR_SIZE;
	}

	PlTermv l_channel_weight(1);

	try { 
	    PlCall("l_channel_weight", l_channel_weight);
	    msg->l_channel_weight = (double) l_channel_weight[0];
	} catch (PlException &ex) { 
	    // cout << "Use default L channel weight" << endl;
	    msg->l_channel_weight = L_CHANNEL_WEIGHT;
	}

	if (msg->sampler_neighbor_size%2 != 1) {
	    // cout << "Neighbor size should be odd number." << endl;
	    return FALSE;
	}
	int connfd = sendMsg(msg, scktmp);
	if (connfd < 0) {
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
		// cout << "[CLIENT] Confirmed: edge point checked." << endl;

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


/* point_color(X, Y, C)
 * X, Y: point coordinate
 * C: color number
 * Notice: should be used after img_quantize/1
 */
PREDICATE(point_color, 3) {

    if (confirm_img() == FALSE)
	return FALSE;
    
    if (confirm_quant() == FALSE)
	return FALSE;

    if (PL_is_variable(A1.ref) || PL_is_variable(A2.ref))
	return FALSE;
    // check whether point out of bound
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
	cerr << "Error img_size." << endl;
	return FALSE;
    }
    if (x < 0 || x >= width || y < 0 || y >= height) {
	// cout << "Point position out of bound." << endl;
	return FALSE;
    }

    // make message
    MyMessage* msg = myCreateMsg(MY_MSG_POINT_COLOR);
    char scktmp[256];
    msg->x = x;
    msg->y = y;
    msg->sample_on_quant_img = TRUE; // use quantized image

    // send message
    int connfd = sendMsg(msg, scktmp);
    if (connfd < 0) {
	return FALSE;
    }

    // read return message
    int q_color = -1;
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
	    // cout << "[CLIENT] Confirmed: got point color." << endl;
	    q_color = (int) msg_back->scalar.val[0];
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
    return A3 = q_color;
}

/* display_point(X, Y, C)
 * Draw point at (X, Y) with color C = {y, r, g, b, w, k}
 */
PREDICATE(display_point, 3) {
    if (confirm_img() == FALSE)
	return FALSE;
    if (PL_is_variable(A1.ref) || PL_is_variable(A2.ref))
	return FALSE;

    // check whether point out of bound
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
	cerr << "Error img_size." << endl;
	return FALSE;
    }
    if (x < 0 || x >= width || y < 0 || y >= height) {
	// cout << "Point position out of bound." << endl;
	return FALSE;
    }

    MyMessage *msg = myCreateMsg(MY_MSG_DRAW_POINT);
    msg->x = x;
    msg->y = y;
    
    char *c = (char*) A3;
    switch (c[0]) {
    case 'y':
	msg->scalar = CV_RGB(255, 255, 0);
	break;
    case 'r':
	msg->scalar = CV_RGB(255, 0, 0);
	break;
    case 'g':
	msg->scalar = CV_RGB(0, 255, 0);
	break;
    case 'b':
	msg->scalar = CV_RGB(0, 0, 255);
	break;
    case 'w':
	msg->scalar = CV_RGB(255, 255, 255);
	break;
    case 'k':
	msg->scalar = CV_RGB(0, 0, 0);
	break;
    default:
	msg->scalar = CV_RGB(255, 255, 0);
	break;
    }

    // send message
    char scktmp[256];
    sprintf(scktmp, "../../tmp/scktmp%05d", getpid());
    int connfd = sendMsg(msg, scktmp);
    if (connfd < 0) {
	return FALSE;
    }

    // read return message
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
	    // cout << "[CLIENT] Confirmed: point drawed." << endl;
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

/* display_point_list(List, C)
 * Draw point list 
 */

PREDICATE(display_point_list, 2) {
    if (confirm_img() == FALSE)
	return FALSE;
    if (PL_is_variable(A1.ref) || PL_is_variable(A2.ref))
	return FALSE;

    MyMessage *msg = myCreateMsg(MY_MSG_DRAW_POINT_LIST);

    // query image size
    PlTermv size(2);
    int width = 0, height = 0;
    try {
	if (PlCall("img_size", size) == TRUE) {
	    width = (int) size[0];
	    height = (int) size[1];
	}
    } catch (PlException &ex) {
	cerr << "Error img_size." << endl;
	return FALSE;
    }
    
    PlTail tail(A1);
    PlTerm point;
    int count = 0;
    
    while(tail.next(point)) {
	PlTail tail(point);
	PlTerm pos;
	tail.next(pos);
	int x = (int) pos;
	tail.next(pos);
	int y = (int) pos;

	// check whether point out of bound
	if (x < 0 || x >= width || y < 0 || y >= height) {
	    cout << "Point position out of bound." << endl;
	    continue;
	}

	msg->highlight_point_x[count] = x;
	msg->highlight_point_y[count] = y;
	count++;
    }
    msg->highlight_point_num = count;

    char *c = (char*) A2;
    switch (c[0]) {
    case 'y':
	msg->scalar = CV_RGB(255, 255, 0);
	break;
    case 'r':
	msg->scalar = CV_RGB(255, 0, 0);
	break;
    case 'g':
	msg->scalar = CV_RGB(0, 255, 0);
	break;
    case 'b':
	msg->scalar = CV_RGB(0, 0, 255);
	break;
    case 'w':
	msg->scalar = CV_RGB(255, 255, 255);
	break;
    case 'k':
	msg->scalar = CV_RGB(0, 0, 0);
	break;
    default:
	msg->scalar = CV_RGB(255, 255, 0);
	break;
    }

    // send message
    char scktmp[256];
    sprintf(scktmp, "../../tmp/scktmp%05d", getpid());
    int connfd = sendMsg(msg, scktmp);
    if (connfd < 0) {
	return FALSE;
    }

    // read return message
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
	    // cout << "[CLIENT] Confirmed: point drawed." << endl;
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

/* displa_line
 * display line
 * display_line(start_x, start_y, end_x, end_y)
 */
PREDICATE(display_line, 5) {
    if (confirm_img() == FALSE)
	return FALSE;
    if (PL_is_variable(A1.ref) || PL_is_variable(A2.ref))
	return FALSE;

    // check whether point out of bound
    int x_1 = (int) A1;
    int y_1 = (int) A2;
    int x_2 = (int) A3;
    int y_2 = (int) A4;
    PlTermv size(2);
    int width = 0, height = 0;
    try {
	if (PlCall("img_size", size) == TRUE) {
	    width = (int) size[0];
	    height = (int) size[1];
	}
    } catch (PlException &ex) {
	cerr << "Error img_size." << endl;
	return FALSE;
    }
    if ((x_1 < 0 || x_1 >= width || y_1 < 0 || y_1 >= height) 
        || (x_2 < 0 || x_2 >= width || y_2 < 0 || y_2 >= height)) {
	// cout << "Point position out of bound." << endl;
	return FALSE;
    }

    MyMessage *msg = myCreateMsg(MY_MSG_DRAW_LINE);

    msg->line_start = CvPoint(x_1, y_1);
    msg->line_end = CvPoint(x_2, y_2);
    
    char *c = (char*) A5;
    switch (c[0]) {
    case 'y':
	msg->scalar = CV_RGB(255, 255, 0);
	break;
    case 'r':
	msg->scalar = CV_RGB(255, 0, 0);
	break;
    case 'g':
	msg->scalar = CV_RGB(0, 255, 0);
	break;
    case 'b':
	msg->scalar = CV_RGB(0, 0, 255);
	break;
    case 'w':
	msg->scalar = CV_RGB(255, 255, 255);
	break;
    case 'k':
	msg->scalar = CV_RGB(0, 0, 0);
	break;
    default:
	msg->scalar = CV_RGB(255, 255, 0);
	break;
    }

    // send message
    char scktmp[256];
    sprintf(scktmp, "../../tmp/scktmp%05d", getpid());
    int connfd = sendMsg(msg, scktmp);
    if (connfd < 0) {
	return FALSE;
    }

    // read return message
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
	    // cout << "[CLIENT] Confirmed: point drawed." << endl;
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


/* display_refresh.
 * refresh display
 */
PREDICATE(display_refresh, 0) {
    if (confirm_img() == FALSE)
	return FALSE;

    MyMessage *msg = myCreateMsg(MY_MSG_REFRESH_DISPLAY);
    
    // send message
    char scktmp[256];
    sprintf(scktmp, "../../tmp/scktmp%05d", getpid());
    int connfd = sendMsg(msg, scktmp);
    if (connfd < 0) {
	return FALSE;
    }

    // read return message
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
	    // cout << "[CLIENT] Confirmed: point drawed." << endl;
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


/* display_close.
 * close display
 * WARNING: due to the opencv bug in gtk, the predicate cannot close
 * the displaying window, only freezes it.
 */
PREDICATE(display_close, 0) {
    if (confirm_img() == FALSE)
	return FALSE;

    MyMessage *msg = myCreateMsg(MY_MSG_CLOSE_DISPLAY);
    
    // send message
    char scktmp[256];
    sprintf(scktmp, "../../tmp/scktmp%05d", getpid());
    int connfd = sendMsg(msg, scktmp);
    if (connfd < 0) {
	return FALSE;
    }

    // read return message
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
	    // cout << "[CLIENT] Confirmed: point drawed." << endl;
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
