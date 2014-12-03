#ifndef _IMAGE_PROCESS_H
#define _IMAGE_PROCESS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <opencv/cv.h>

#include "../socket/message.h"
#include "../sampler/quantify.h"

extern int return_message(int connfd);

extern MyQuantifiedImage* image_quantify(IplImage* img, MyMessage* msg, int connfd);

extern int send_size(IplImage* img, MyMessage* msg, int connfd);
extern int palette_edge_sampler(MyQuantifiedImage* quant_img, MyMessage* msg, int connfd);

#ifdef __cplusplus
}
#endif

#endif














