#include <opencv/cv.h>

#include "../socket/socket_server.h"
#include "../socket/message.h"
#include "../socket/image_process.h"
#include "../utils/utils.h"

int main(int argc, char** argv) { 
    if (argc < 2) {
	printf("Usage: %s [path of image file]\n", argv[0]);
	exit(EXIT_FAILURE);
    }

    char* image_path = argv[1];

    int listenfd, connfd;
    listenfd = unix_socket_listen("../../tmp/img_server.sock");

    IplImage* img = myReadImg2Lab(image_path);
    MyQuantizedImage* quant_img = NULL;

    while (1) {
	uid_t uid;
	connfd = unix_socket_accept(listenfd, &uid);

	int msg_size;
	MyMessage *msg = (MyMessage *) malloc(sizeof(MyMessage));
	char* buffer = (char *) malloc(sizeof(MyMessage));
	msg_size = recv(connfd, buffer, sizeof(MyMessage), 0);

	if(msg_size < 0) {
	    perror("[SERVER] Error reading from socket.\n");	 
	    break;		
	}

	memcpy(msg, buffer, sizeof(MyMessage));
	free(buffer);
	buffer = NULL;

	switch(msg->msg_type) {
	case MY_MSG_RLS_IMG:
	{
	    // printf("[SERVER] Recieved: release image.\n");
	    cvReleaseImage(&img);
	    if (quant_img != NULL) {
		myCvReleaseQuantizedImage(&quant_img);
	    }
	    unix_socket_close(listenfd);
	    // return a message
	    int backmsg_size = return_message(NULL, connfd);
	    if (backmsg_size < 0) {
		perror("[SERVER] ERROR responding to client");
		exit(EXIT_FAILURE);
	    } else {
		exit(EXIT_SUCCESS);
		return 1;
	    }
	    break;
	}
	case MY_MSG_QTZ_IMG:
	{
	    quant_img = image_quantize(img, msg, connfd);
	    break;
	}
	case MY_MSG_REQUIRE_SIZE:
	{
	    if (send_size(img, msg, connfd) < 0) {
		perror("[SERVER] ERROR responsing to client");
	    }
	    break;
	}
	case MY_MSG_PALETTE_EDGE_POINT:
	{
	    if (quant_img == NULL) {
		perror("[SERVER] ERROR no quantified image");
	    } else {
		if (palette_edge_sampler(quant_img, msg, connfd) < 0) {
		    perror("[SERVER] ERROR responsing to client");
		}
	    }
	    break;
	}
	case MY_MSG_POINT_COLOR:
	{
	    if (quant_img == NULL) {
		perror("[SERVER] ERROR no quantified image");
	    } else {
		if (quant_point_color(quant_img, msg, connfd) < 0) {
		    perror("[SERVER] ERROR responsing to client");
		}
	    }
	}
	default:
	    break;
	}
	unix_socket_close(connfd);
    }
    return 1;
}
