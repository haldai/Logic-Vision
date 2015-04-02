#include <stdio.h>

#include "../socket/image_process.h"
#include "../sampler/sampler.h"

int return_message(MyMessage* msg_back, int connfd) {
    // return a message
    if (msg_back == NULL)
	msg_back = myCreateMsg(MY_MSG_MSGGOT);
    char* buffer = (char *) malloc(sizeof(MyMessage));
    memcpy(buffer, msg_back, sizeof(MyMessage));
    int backmsg_size = send(connfd, buffer, sizeof(MyMessage), 0);
    free(buffer);
    buffer = NULL;
    free(msg_back);
    msg_back = NULL;
    return backmsg_size;
}

MyQuantizedImage* image_quantize(IplImage* img, MyMessage* msg, int connfd) {
    assert(msg->msg_type == MY_MSG_QTZ_IMG);
    int cluster_num = msg->palette_size;
    MyQuantizedImage *quant_img = kmeansQuantization(img, cluster_num);

    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    msg_back->palette_size = quant_img->tableSize;
    
    for (int i = 0; i < quant_img->tableSize; i++) {
	msg_back->colorTable[i] = cvScalar(
	    quant_img->colorTable[i].val[0],
	    quant_img->colorTable[i].val[1],
	    quant_img->colorTable[i].val[2],
	    quant_img->colorTable[i].val[3]
	    );
    }

    int backmsg_size = return_message(msg_back, connfd);
    if (backmsg_size < 0) {
	perror("[SERVER] ERROR sending message to client");
	return NULL;
    }
    return quant_img;
}

int send_size(IplImage* img, MyMessage *msg, int connfd) {
    assert(msg->msg_type == MY_MSG_REQUIRE_SIZE);

    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    // return image size
    msg_back->x = img->width;
    msg_back->y = img->height;
    
    printf("[IMG] Image size: %d, %d\n", img->width, img->height);

    char* buffer = (char *) malloc(sizeof(MyMessage));
    memcpy(buffer, msg_back, sizeof(MyMessage));
    int backmsg_size = send(connfd, buffer, sizeof(MyMessage), 0);
    free(buffer);
    buffer = NULL;
    free(msg_back);
    msg_back = NULL;
    return backmsg_size;
}

int palette_edge_sampler(MyQuantizedImage* quant_img, MyMessage* msg, int connfd) {
    assert(msg->msg_type == MY_MSG_PALETTE_EDGE_POINT);
    CvPoint point = cvPoint(msg->x, msg->y);
    // printf("point: %d, %d\n", msg->x, msg->y); //debug
    int window_size = msg->sampler_neighbor_size;
    // printf("weight: %f\n", msg->l_channel_weight); //debug
    // printf("size: %d\n", msg->sampler_neighbor_size); //debug

    double l_channel_weight = msg->l_channel_weight;
    CvScalar dv = myCvPaletteDV(quant_img, point, 5, window_size, l_channel_weight, 1);
    /*
    for (int i = 0; i < 4; i++) {
	    printf("%f ", dv.val[i]);
    }
    printf("\n");
    */
    
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

int quant_point_color(MyQuantizedImage* quant_img, MyMessage* msg, int connfd) {
    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    int q_color = (int) cvGetReal2D(quant_img->labelMat, msg->y, msg->x);
    msg_back->scalar = cvScalar(q_color, 0, 0, 0);
    return return_message(msg_back, connfd);
}

int draw_point(IplImage **img, MyMessage *msg, int connfd) {
    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    CvScalar color = msg->scalar;
    CvPoint point = cvPoint(msg->x, msg->y);
    cvCircle(*img, point, 3, color, 2, 8, 0);
    return return_message(msg_back, connfd);
}

int draw_point_list(IplImage **img, MyMessage *msg, int connfd) {
    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    CvScalar color = msg->scalar;
    for (int i = 0; i < msg->highlight_point_num; i++) {
	CvPoint point = cvPoint(msg->highlight_point_x[i], 
				msg->highlight_point_y[i]);
	cvCircle(*img, point, 1, color, 2, 8, 0);
    }
    return return_message(msg_back, connfd);
}

int draw_line(IplImage **img, MyMessage *msg, int connfd) {
    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    CvScalar color = msg->scalar;
    cvLine(*img, msg->line_start, msg->line_end, color, 2, 8, 0);
    return return_message(msg_back, connfd);
}

int redraw(MyMessage *msg, int connfd) {
    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    return return_message(msg_back, connfd);
}

int exit_display(MyMessage *msg, int connfd) {
    MyMessage *msg_back = myCreateMsg(MY_MSG_MSGGOT);
    return return_message(msg_back, connfd);
}
