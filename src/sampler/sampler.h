#ifndef _SAMPLER_H
#define _SAMPLER_H

#include <opencv/cv.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "../sampler/descriptor.h"
#include "../sampler/quantify.h"
#include "../utils/utils.h"

// store a line and pointer of points on this line
typedef struct {
    CvPoint start;
    CvPoint end;
    int size;
    CvSeq* points;
} MyCvLine;

// direction of a 2d vector
typedef struct {
    int x;
    int y;
} MyCvDirect;

extern MyCvDirect myCvDirect(int _x, int _y);

// create line with start and end point
extern MyCvLine* myCvLine(IplImage* img, CvPoint _start, CvPoint _end);
// create line with start point, direction and length
extern MyCvLine* myCvLineDir(IplImage* img, CvPoint _start, MyCvDirect direct, int length);

extern void myCvReleaseLine(MyCvLine** l);

#define MY_CV_SAMPLE_DESCRIPTOR_PIXEL 0
#define MY_CV_SAMPLE_DESCRIPTOR_AVG_PIXEL 1
#define MY_CV_SAMPLE_DESCRIPTOR_MED_PIXEL 2
#define MY_CV_SAMPLE_DESCRIPTOR_PALETTE 3 // must be used with MyQuantifiedImg

// store a MyCvLine and its descriptor
typedef struct {
    int descriptor_type;
    int neighbor_size;
    
    MyCvLine** line;
    int size;
    MyCvDescriptor* descriptors;
} MyCvLineSampler;

extern MyCvLineSampler* myCvLineSampler(void* img, MyCvLine** line, int _descriptor_type, int _neighbor_size);

extern CvPoint* myCvGetLineSamplerPoint(MyCvLineSampler* ls, int i);

extern CvPoint* myCvHighVariancePointOnLine(MyCvLineSampler* line_sampler);

extern void myCvReleaseLineSampler(MyCvLineSampler** s);

// use quantified image palette to measure distance of two points
extern double myCvPaletteDistance(MyQuantifiedImage* quant, CvPoint p1, CvPoint p2, int size, double l_channel_weight);

// vector difference of a point, size: window size, hv: whether only use horizontal and vertical difference
extern CvScalar myCvDV(IplImage* img, CvPoint point, int size, int filter_size, double l_channel_weight, int hv);
extern CvScalar myCvPaletteDV(MyQuantifiedImage* quant, CvPoint point, int size, int filter_size, double l_channel_weight, int hv);

#ifdef __cplusplus
}
#endif

#endif










