#include <stdio.h>

#include "../socket/image_process.h"
#include "../sampler/sampler.h"

int return_message(int connfd) {
    // return a message
    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    char* buffer = (char *) malloc(sizeof(MyMessage));
    memcpy(buffer, msg_back, sizeof(MyMessage));
    int backmsg_size = send(connfd, buffer, sizeof(MyMessage), 0);
    free(buffer);
    buffer = NULL;
    free(msg_back);
    msg_back = NULL;
    return backmsg_size;
}

MyQuantifiedImage* image_quantify(IplImage* img, MyMessage* msg, int connfd) {
    assert(msg->msg_type == MY_MSG_QTFY_IMG);
    int cluster_num = msg->palette_size;
    printf("[SERVER] Recieved: quantify image to %d colors.\n", 
	   cluster_num);
    MyQuantifiedImage *quant_img = kmeansQuantification(img, cluster_num);
    int backmsg_size = return_message(connfd);
    if (backmsg_size < 0) {
	perror("[SERVER] ERROR sending message to client");
    }
    return quant_img;
}

int send_size(IplImage* img, MyMessage *msg, int connfd) {
    assert(msg->msg_type == MY_MSG_REQUIRE_SIZE);

    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    // return image size
    msg_back->x = img->width;
    msg_back->y = img->height;

    char* buffer = (char *) malloc(sizeof(MyMessage));
    memcpy(buffer, msg_back, sizeof(MyMessage));
    int backmsg_size = send(connfd, buffer, sizeof(MyMessage), 0);
    free(buffer);
    buffer = NULL;
    free(msg_back);
    msg_back = NULL;
    return backmsg_size;
}

int palette_edge_sampler(MyQuantifiedImage* quant_img, MyMessage* msg, int connfd) {
    assert(msg->msg_type == MY_MSG_PALETTE_EDGE_POINT);
    CvPoint point = cvPoint(msg->x, msg->y);
    printf("point: %d, %d\n", msg->x, msg->y); //debug
    int window_size = msg->sampler_neighbor_size;
    printf("weight: %f\n", msg->l_channel_weight); //debug
    printf("size: %d\n", msg->sampler_neighbor_size); //debug

    double l_channel_weight = msg->l_channel_weight;
    CvScalar dv = myCvPaletteDV(quant_img, point, 5, window_size, l_channel_weight, 1);
    
    for (int i = 0; i < 4; i++) {
	    printf("%f ", dv.val[i]);
    }
    printf("\n");
    
    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    // return image size
    msg_back->scalar = dv;
    
    char* buffer = (char *) malloc(sizeof(MyMessage));
    memcpy(buffer, msg_back, sizeof(MyMessage));
    int backmsg_size = send(connfd, buffer, sizeof(MyMessage), 0);
    free(buffer);
    buffer = NULL;
    free(msg_back);
    msg_back = NULL;

    return backmsg_size;
}

