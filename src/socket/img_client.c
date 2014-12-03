#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <stddef.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>

#include <opencv/cv.h>

#include "message.h"
#include "socket_server.h"

int main(void) { 
    int cluster_num = 4;

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
}

