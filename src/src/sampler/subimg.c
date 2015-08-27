#include "../sampler/subimg.h"
#include "../utils/utils.h"

#include <opencv/cv.h>

IplImage* myInterestRect(IplImage* src, CvPoint _pos, int width, int height) {
    assert((_pos.y < src->width) && (_pos.x < src->height));

    CvPoint pos = cvPoint(
	(_pos.x >= 0) ? _pos.x : 0,
	(_pos.y >= 0) ? _pos.y : 0
	);
    int _width = (pos.x + width < src->width) ? width : src->width - pos.x,
	_height = (pos.y + height < src->height) ? height : src->height - pos.y;

    cvSetImageROI(src, cvRect(pos.x, pos.y, _width, _height));
    IplImage *sub_img = cvCreateImage(cvSize(_width, _height), src->depth, src->nChannels);
    cvCopy(src, sub_img, NULL);
    cvResetImageROI(src);

    return sub_img;
}

IplImage* myInterestCircle(IplImage* src, CvPoint center, int rad) {
    assert(myCvInImage(src, center));

    IplImage *res, *roi;
    res = cvCreateImage(cvGetSize(src), IPL_DEPTH_32F, 3);
    roi = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
    
    // prepare roi
    cvZero(roi);
    cvZero(res);
    
    // prepare mask
    cvCircle(
	roi,
	center,
	rad,
	CV_RGB(255, 255, 255),
	-1, 8, 0
	);
    // extract subimage
    cvAnd(src, src, res, roi);

    int pos_x = (center.x - rad >= 0) ? center.x - rad : 0, 
	pos_y = (center.y - rad >= 0) ? center.y - rad : 0,
	_width = (center.x + rad < src->width) ? (center.x + rad) - pos_x : src->width - pos_x,
	_height = (center.y + rad < src->height) ? (center.y + rad) - pos_y : src->height - pos_y;

    IplImage* re = myInterestRect(res, cvPoint(pos_x, pos_y), _width, _height);
    
    return re;
}

IplImage* sub_rect(IplImage* src, CvPoint pos, int width, int height) {
    assert(myCvInImage(src, pos));

    IplImage* interest_rect = myInterestRect(src, pos, width, height);
    IplImage* re = cvCreateImage(
	cvGetSize(interest_rect),
	src->depth,
	src->nChannels
	);
    cvCopy(interest_rect, re, NULL);
    cvReleaseImage(&interest_rect);
    return re;
}

// a circular sub-image
IplImage* sub_circle(IplImage* src, CvPoint center, int rad) {
    IplImage* interest_rect = myInterestCircle(src, center, rad);
    IplImage* re = cvCreateImage(
	cvGetSize(interest_rect),
	interest_rect->depth,
	interest_rect->nChannels
	);
    cvCopy(interest_rect, re, NULL);
    cvReleaseImage(&interest_rect);
    return re;
}

// a square sub-image
IplImage* sub_square(IplImage* src, CvPoint center, int half_width) {
    assert(myCvInImage(src, center));
    CvPoint pos = cvPoint(
	center.x - half_width,
	center.y - half_width
	);
    int width = half_width*2 + 1, height = half_width*2 + 1;
    IplImage* interest_rect = myInterestRect(src, pos, width, height);
    IplImage* re = cvCreateImage(
	cvGetSize(interest_rect),
	interest_rect->depth,
	interest_rect->nChannels
	);
    cvCopy(interest_rect, re, NULL);
    cvReleaseImage(&interest_rect);
    return re;
}

// a square sub cvmat for building palette from label mat
CvMat* sub_square_mat(CvMat* src, CvPoint center, int half_width) {
    assert((center.y < src->rows) &&
	   (center.x < src->cols) &&
	   (center.y >= 0) &&
	   (center.x >= 0));

    CvPoint _pos = cvPoint(
	center.x - half_width,
	center.y - half_width
	);

    CvPoint pos = cvPoint(
	(_pos.x >= 0) ? _pos.x : 0,
	(_pos.y >= 0) ? _pos.y : 0
	);

    CvPoint end = cvPoint(
	(_pos.x + 2*half_width + 1 < src->cols) ? _pos.x + 2*half_width : src->cols - 1,
	(_pos.y + 2*half_width + 1 < src->rows) ? _pos.y + 2*half_width : src->rows - 1
	);
    int width =  end.x - pos.x + 1;
    int height = end.y - pos.y + 1;
    
    CvMat* re = cvCreateMat(height, width, src->type);
    
    int i, j;
    for (int row = pos.x; row <= end.x; row++) {
	i = row - pos.x;
	for (int col = pos.y; col <= end.y; col++) {
	    j = col - pos.y;
	    float v = cvGetReal2D(src, col, row);
	    cvSetReal2D(re, j, i, v);
	}
    }

    return re;
}

















