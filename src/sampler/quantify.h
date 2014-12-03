#ifndef _QUANTIFY_H
#define _QUANTIFY_H

#include <opencv/cv.h>

#ifdef __cplusplus
extern "C" {
#endif

#define CV_KMEANS_PP_CENTERS 2
#define CV_KMEANS_ATTEMPTS 5
#define CV_KMEANS_ACC 0.1

typedef struct {
    IplImage* qImg;
    CvMat* labelMat;
    CvScalar* colorTable;
    int tableSize;
} MyQuantifiedImage;

// color reduction
extern MyQuantifiedImage* kmeansQuantification(IplImage* img, int tableSize);

extern void myCvReleaseQuantifiedImage(MyQuantifiedImage** q);

// get quantified image
extern IplImage* myQuantifyGetImage(MyQuantifiedImage* quant);
// get quantified label of image
extern CvMat* myQuantifyGetLabel(MyQuantifiedImage* quant);
// get quantified color table
extern CvScalar* myQuantifyGetColorTable(MyQuantifiedImage* quant);
// get quantified color table size
extern int myQuantifyGetColorTableSize(MyQuantifiedImage* quant);

#ifdef __cplusplus
}
#endif

#endif
