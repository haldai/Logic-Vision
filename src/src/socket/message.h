#ifndef _MESSAGE_H
#define _MESSAGE_H

#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>

#include <opencv/cv.h>

#include "../../include/SWI-Prolog.h"
#include "../sampler/descriptor.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_ARG_NUM 10
#define MAX_ARG_LEN 256
#define MAX_PALETTE_SIZE 16
#define MAX_HIGHLIGHT_POINT_SIZE 2000

#define SAMPLE_ON_QUANT_IMG 0
#define SAMPLE_ON_ORG_IMG 1

#define MY_MSG_MSGGOT -1
#define MY_MSG_RLS_IMG 0
#define MY_MSG_POINT_COLOR 1
#define MY_MSG_POINT_AVG_COLOR 2
#define MY_MSG_POINT_PALETTE 3
#define MY_MSG_POINT_AVG_PALETTE 4
#define MY_MSG_EDGE_POINT 5
#define MY_MSG_PALETTE_EDGE_POINT 6
#define MY_MSG_QTZ_IMG 7
#define MY_MSG_RLS_QTZ_IMG 8
#define MY_MSG_LINE_SAMPLER 9
#define MY_MSG_REQUIRE_SIZE 10
#define MY_MSG_DRAW_POINT 11
#define MY_MSG_CLOSE_DISPLAY 12
#define MY_MSG_REFRESH_DISPLAY 13
#define MY_MSG_DRAW_LINE 14
#define MY_MSG_DRAW_POINT_LIST 15

#define PIC_DISPLAY_NAME "HAL9001_MONITOR"

#define LINE_SAMPLER_NEIGHBOR_SIZE 7
#define L_CHANNEL_WEIGHT 0.3

typedef struct {
    // argument of message type
    int msg_type;
    // whether sample on quantified image
    int sample_on_quant_img;
    // coordiate or size of image
    int x, y;
    // weight fo L channel
    double l_channel_weight;
    // argument scalar
    CvScalar scalar;
    // argument for sampler
    int line_length;
    CvPoint line_start;
    CvPoint line_end;
    CvPoint line_dir;
    int highlight_point_num;
    CvPoint line_direction;
    int sampler_neighbor_size;
    int sampler_type;

    int highlight_point_x[MAX_HIGHLIGHT_POINT_SIZE]; // return points
    int highlight_point_y[MAX_HIGHLIGHT_POINT_SIZE]; // return points
    // argument for quantification
    int palette_size;
    CvScalar colorTable[MAX_PALETTE_SIZE];
    float colorProportion[MAX_PALETTE_SIZE];
    // argument of answer
    int ans_bool;
    
} MyMessage;

extern MyMessage* myCreateMsg(int msg_type);

#ifdef __cplusplus
}
#endif

#endif
