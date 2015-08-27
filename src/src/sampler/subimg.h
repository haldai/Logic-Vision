/* sub images are deep cloned*/

#ifndef _SUBIMG_H
#define _SUBIMG_H

#include <opencv/cv.h>

#ifdef __cplusplus
extern "C" {
#endif

// rectangle region of interest
extern IplImage* myInterestRect(IplImage* src, CvPoint pos, int width, int height);
// circle region of interest
extern IplImage* myInterestCircle(IplImage*, CvPoint pos, int rad);
// rectangle subimage
extern IplImage* sub_rect(IplImage* src, CvPoint pos, int width, int height);
// circle subimage
extern IplImage* sub_circle(IplImage* src, CvPoint center, int rad);
// square subimage
extern IplImage* sub_square(IplImage* src, CvPoint center, int half_width);
extern CvMat* sub_square_mat(CvMat* src, CvPoint center, int half_width);

#ifdef __cplusplus
}
#endif

#endif
