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
    CvMat* labelMat; // size: height*weight
    CvScalar* colorTable;
    int tableSize;
} MyQuantizedImage;

// color reduction
extern MyQuantizedImage* kmeansQuantization(IplImage* img, int tableSize);

extern void myCvReleaseQuantizedImage(MyQuantizedImage** q);

// get quantified image
extern IplImage* myQuantizeGetImage(MyQuantizedImage* quant);
// get quantified label of image
extern CvMat* myQuantizeGetLabel(MyQuantizedImage* quant);
// get quantified color table
extern CvScalar* myQuantizeGetColorTable(MyQuantizedImage* quant);
// get quantified color table size
extern int myQuantizeGetColorTableSize(MyQuantizedImage* quant);

#ifdef __cplusplus
}
#endif

#endif
