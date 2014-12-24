#ifndef _IMAGE_PROCESS_H
#define _IMAGE_PROCESS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <opencv/cv.h>

#include "../socket/message.h"
#include "../sampler/quantize.h"

extern int return_message(MyMessage* msg_back, int connfd);
extern MyQuantizedImage* image_quantize(IplImage* img, MyMessage* msg, int connfd);
extern int send_size(IplImage* img, MyMessage* msg, int connfd);
extern int palette_edge_sampler(MyQuantizedImage* quant_img, MyMessage* msg, int connfd);
extern int quant_point_color(MyQuantizedImage* quant_img, MyMessage* msg, int connfd);
extern int draw_point(IplImage **img, MyMessage *msg, int connfd);
extern int redraw(MyMessage *msg, int connfd);
extern int exit_display(MyMessage *msg, int connfd);

#ifdef __cplusplus
}
#endif

#endif














