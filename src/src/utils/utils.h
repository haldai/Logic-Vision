#ifndef _UTILS_H
#define _UTILS_H

#include <opencv/cv.h>

#ifdef __cplusplus
extern "C" {
#endif

#define NELEMS(x) (sizeof(x) / sizeof(x[0]))

// QuickSelect the median value
extern float quick_select(float arr[], int n);
// read image and convert it to Lab channel
extern IplImage* myReadImg2Lab(char* path);
// convert back to BGR image then display iplimage
extern void myDisplayLabImg(char* name, IplImage* img);
// display BGR image
extern void myDisplayImg(char* name, IplImage* img);
// judge wether a point is in the image or reaches the edge
extern int myCvInImage(IplImage*img, CvPoint point);
extern int myCvReachImageEdge(IplImage* img, CvPoint point);
extern CvPoint myCvHandleEdgePoint(CvPoint p, int width, int height);
// get median value of an given image
extern CvScalar myCvMedian(IplImage* img);
// get mean value of an given image
extern CvScalar myCvMean(IplImage* img);
// Euclidean & ANNF distance between points
extern double euDist(CvScalar s1, CvScalar s2, double l_channel_weight);
extern double myCvPointEuDist(IplImage* img, CvPoint p1, CvPoint p2, double l_channel_weight);
extern double myCvPointANNFDist(IplImage* img, CvPoint p1, CvPoint p2, int size, double l_channel_weight);
// Adaptive Nearest-Neighbor Filter of a point
extern CvScalar myCvPointANNF(IplImage* img, CvPoint p, int size, double l_channel_weight);

#ifdef __cplusplus
}
#endif

#endif
