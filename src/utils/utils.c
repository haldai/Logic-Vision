#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <math.h>

#include "../utils/utils.h"

#define ELEM_SWAP(a,b) { register float t = (a); (a) = (b); (b) = t; }

/* 
 * This Quickselect routine is based on the algorithm described in 
 * "Numerical recipes in C", Second Edition, Cambridge University Press, 
 * 1992, Section 8.5, ISBN 0-521-43108-5 This code by Nicolas Devillard 
 * - 1998. Public domain.
 */
extern float quick_select(float arr[], int n) {
    int low, high;
    int median;
    int middle, ll, hh;

    low = 0 ; high = n-1 ; median = (low + high) / 2;
    for (;;) {
        if (high <= low) /* One element only */
            return arr[median] ;

        if (high == low + 1) {  /* Two elements only */
            if (arr[low] > arr[high])
                ELEM_SWAP(arr[low], arr[high]) ;
            return arr[median] ;
        }

	/* Find median of low, middle and high items; swap into position low */
	middle = (low + high) / 2;
	if (arr[middle] > arr[high])    ELEM_SWAP(arr[middle], arr[high]) ;
	if (arr[low] > arr[high])       ELEM_SWAP(arr[low], arr[high]) ;
	if (arr[middle] > arr[low])     ELEM_SWAP(arr[middle], arr[low]) ;

	/* Swap low item (now in position middle) into position (low+1) */
	ELEM_SWAP(arr[middle], arr[low+1]) ;

	/* Nibble from each end towards middle, swapping items when stuck */
	ll = low + 1;
	hh = high;
	for (;;) {
	    do ll++; while (arr[low] > arr[ll]) ;
	    do hh--; while (arr[hh]  > arr[low]) ;
	    
	    if (hh < ll)
		break;
	    
	    ELEM_SWAP(arr[ll], arr[hh]) ;
	}

	/* Swap middle item (in position low) back into correct position */
	ELEM_SWAP(arr[low], arr[hh]) ;
	
	/* Re-set active partition */
	if (hh <= median)
	    low = ll;
        if (hh >= median)
	    high = hh - 1;
    }
}
#undef ELEM_SWAP

// convert image to 32f
IplImage* convert_to_float32(IplImage* img) {
    IplImage* img32f = cvCreateImage(cvGetSize(img), IPL_DEPTH_32F, img->nChannels);

    for (int i = 0; i < img->height; i++) {
        for(int j = 0; j < img->width; j++) {
            cvSet2D(img32f, i, j, cvGet2D(img, i, j));
        }
    }

    // opencv store 32f within 0.0 - 1.0, so scale it by dividing 255.0
    cvScale(img32f, img32f, 1.0/255.0, 0);

    return img32f;
}

IplImage* myReadImg2Lab(char* path) {
    // load image, change to 32F CvMat for L*a*b* convertion
    IplImage* src = cvLoadImage(path, CV_LOAD_IMAGE_UNCHANGED);

    IplImage* src32F = convert_to_float32(src);

    IplImage* img = cvCreateImage(cvGetSize(src32F), IPL_DEPTH_32F, 3);

    cvCvtColor(src32F, img, CV_BGR2Lab);

    cvReleaseImage(&src32F);

    return img;
}

void myDisplayLabImg(char* name, IplImage* img) {
    IplImage* bgr = cvCreateImage(cvGetSize(img), IPL_DEPTH_32F, 3);
    cvCvtColor(img, bgr, CV_Lab2BGR);
    
    cvNamedWindow(name, CV_WINDOW_AUTOSIZE);
    cvShowImage(name, bgr);
    cvWaitKey(0);
    cvDestroyWindow(name);
}

void myDisplayImg(char* name, IplImage* img) {
    cvNamedWindow(name, CV_WINDOW_AUTOSIZE);
    cvShowImage(name, img);
    cvWaitKey(0);
    cvDestroyWindow(name);
}

int myCvInImage(IplImage* img, CvPoint point) {
    if (
	(point.x < img->width) &&
	(point.x >= 0) &&
	(point.y < img->height) &&
	(point.y >= 0)
	)
	return 1;
    else
	return 0;
}

int myCvReachImageEdge(IplImage* img, CvPoint point) {
    if (
	(point.x == img->width - 1) ||
	(point.x == 0) ||
	(point.y == img->height - 1) ||
	(point.y == 0)
	)
	return 1;
    else
	return 0;
}

// get median value of an given image
CvScalar myCvMedian(IplImage* img) {
    // split into 3 channels
    CvMat *L = cvCreateMat(img->width, img->height, CV_8UC1), 
	*a = cvCreateMat(img->width, img->height, CV_8UC1),
	*b = cvCreateMat(img->width, img->height, CV_8UC1);
    cvSplit(img, L, a, b, NULL);
    
    int size = img->width*img->height;
    float arrL[size], arra[size], arrb[size];
    // convert to array
    int i = 0;
    for(int row = 0; row < L->rows; row++) {
	const float* ptr = (const float*)(L->data.ptr + row*L->step);
	for(int col = 0; col < L->cols; col++) {
	    arrL[i++] = *ptr++;
	}
    }
    i = 0;
    for(int row = 0; row < a->rows; row++) {
	const float* ptr = (const float*)(a->data.ptr + row*a->step);
	for(int col = 0; col < a->cols; col++) {
	    arra[i++] = *ptr++;
	}
    }
    i = 0;
    for(int row = 0; row < b->rows; row++) {
	const float* ptr = (const float*)(b->data.ptr + row*b->step);
	for(int col = 0; col < b->cols; col++) {
	    arrb[i++] = *ptr++;
	}
    }
    // get median of each array
    int n = NELEMS(arrL);
    int medL = quick_select(arrL, n),
	meda = quick_select(arra, n),
	medb = quick_select(arrb, n);

    CvScalar re = cvScalar(medL, meda, medb, 0);

    cvReleaseMat(&L);
    cvReleaseMat(&a);
    cvReleaseMat(&b);

    return re;
}

// if exceed edge, select the closest edge point
CvPoint myCvHandleEdgePoint(CvPoint p, int width, int height) {
    int x = p.x, y = p.y;
    x = x < 0 ? 0 : (x >= width ? width - 1 : x);
    y = y < 0 ? 0 : (y >= height ? height - 1 : y);
    return cvPoint(x, y);
}

double myCvPointEuDist(IplImage* img, CvPoint p1, CvPoint p2, double l_channel_weight) {
    CvScalar s1 = cvGet2D(img, p1.y, p1.x);
    CvScalar s2 = cvGet2D(img, p2.y, p2.x);
    return euDist(s1, s2, l_channel_weight);
}

double myCvPointANNFDist(IplImage* img, CvPoint p1, CvPoint p2, int size, double l_channel_weight) {
    CvScalar s1 = myCvPointANNF(img, p1, size, l_channel_weight);
    CvScalar s2 = myCvPointANNF(img, p2, size, l_channel_weight);
    return euDist(s1, s2, l_channel_weight);
}

CvScalar myCvPointANNF(IplImage* img, CvPoint p, int size, double l_channel_weight) {
    assert(size%2 == 1);
    CvMat* mat = cvCreateMat(size, size, CV_32FC3);
    CvMat* d = cvCreateMat(size, size, CV_32FC1); 
//    CvMat* w = cvCreateMat(size, size, CV_32FC1);
    
    int rad = (size - 1)/2;

    for (int r = -rad; r <= rad; r++) { // y-axis
	CvPoint center = cvPoint(p.x, p.y + r);
	int y = rad + r;
	for (int rr = -rad; rr <= rad; rr++) { // x-axis
	    CvPoint this = myCvHandleEdgePoint(
		cvPoint(center.x + rr, center.y),
		img->width,
		img->height
		);
	    int x = rad + r;
	    cvSet2D(mat, x, y, cvGet2D(img, this.y, this.x)); // inversed xy
	}
    }
    
    double max_d = .0;
    double sum = .0;
    for (int i = 0; i < size; i++) {
	for (int j = 0; j < size; j++) {
	    double dd = .0;
	    // compute d(i, j)
	    for (int k = 0; k < size; k++) {
		for (int l = 0; l < size; l++) {
		    if (!(k == i && l == j)) {
			dd += euDist(cvGet2D(mat, i, j), cvGet2D(mat, k, l), l_channel_weight);
		    }
		}
	    }
	    if (dd > max_d)
		max_d = dd;
	    sum += dd;
	    cvSetReal2D(d, i, j, dd);
	}
    }

    double denom = max_d*size*size - sum;

    CvScalar re = cvScalar(0, 0, 0, 0);
    for (int i = 0; i < size; i++) {
	for (int j = 0; j < size; j++) {
	    // compute weight
	    double ww = (max_d - cvGetReal2D(d, i, j))/denom;
	    for (int k = 0; k < 4; k++) {
		re.val[k] += ww*cvGet2D(mat, i, j).val[k];
	    }
	}
    }

    cvReleaseMat(&mat);
    cvReleaseMat(&d);

    return re;
}

double euDist(CvScalar s1, CvScalar s2, double l_channel_weight) {
    double re = .0;
    // weight L channel difference (brightness difference)
    re += l_channel_weight*pow((s1.val[0] - s2.val[0]), 2);
    for (int i = 1; i < 4; i++) {
	re += pow((s1.val[i] - s2.val[i]), 2);
    }
    return sqrt(re);
}
