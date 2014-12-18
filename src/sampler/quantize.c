#include "quantize.h"

#include <opencv/cv.h>
#include <opencv/highgui.h>

// use k-means to reduce color number
MyQuantizedImage* kmeansQuantization(IplImage* img, int tableSize) {

    // step 1: transfer image to kmeans samples
    int sample_count = img->height * img->width;
    CvMat* samples = cvCreateMat(sample_count, 1, CV_32FC3);
    CvRNG rng = cvRNG(0xffffffff);

    int idx = 0;
    for (int i = 0; i < img->height; i++) {
	for (int j = 0; j < img->width; j++) {
	    cvSet1D(samples, idx++, cvGet2D(img, i, j));
	}
    }
    
    // step 2: apply kmeans;
    CvMat* labels = cvCreateMat(sample_count, 1, CV_32SC1);
    CvMat* centers = cvCreateMat(tableSize, 1, CV_32FC3);
    cvSetZero(labels);
    cvSetZero(centers);
    
    cvKMeans2(samples, tableSize, labels,
	      cvTermCriteria(CV_TERMCRIT_ITER + CV_TERMCRIT_EPS, 
			     10, CV_KMEANS_ACC), 
	      CV_KMEANS_ATTEMPTS, &rng,
	      CV_KMEANS_PP_CENTERS, centers, 0); // flag = KMEANS_PP_CENTERS

    // step 3: rebuild the image
    IplImage* quantImg = cvCreateImage(cvGetSize(img), IPL_DEPTH_32F, 3);
    CvMat* labelImg = cvCreateMat(img->height, img->width, CV_32SC1);
    cvSetZero(quantImg);
    cvSetZero(labelImg);
    
    idx = 0;
    for (int i = 0; i < img->height; i++) {
	for (int j = 0; j < img->width; j++) {
	    int cluster_idx = labels->data.i[idx++];
	    CvScalar color = cvGet1D(centers, cluster_idx);
	    cvSet2D(quantImg, i, j, color);
	    cvSetReal2D(labelImg, i, j, (double) cluster_idx); // y, x
	}
    }

    MyQuantizedImage* re = malloc(sizeof(MyQuantizedImage));
    re->labelMat = labelImg;
    re->qImg = quantImg;
    re->tableSize = tableSize;
    
    CvScalar* colorTable = calloc(tableSize, sizeof(CvScalar));
    for (int i = 0; i < tableSize; i++) {
	colorTable[i] = cvGet1D(centers, i);
    }
    re->colorTable = colorTable;


    return re;
}

void myCvReleaseQuantizedImage(MyQuantizedImage** q) {
    if (*q != NULL) {
	cvReleaseImage(&((*q)->qImg));
	cvReleaseMat(&((*q)->labelMat));
	free((*q)->colorTable);
	(*q)->colorTable = NULL;
	free(*q);
	(*q) = NULL;
    }
}

IplImage* myQuantizeGetImage(MyQuantizedImage* quant) {
    return quant->qImg;
}

CvMat* myQuantizeGetLabel(MyQuantizedImage* quant) {
    return quant->labelMat;
}

CvScalar* myQuantizeGetColorTable(MyQuantizedImage* quant) {
    return quant->colorTable;
}

int myQuantizeGetColorTableSize(MyQuantizedImage* quant) {
    return quant->tableSize;
}
