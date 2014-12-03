#include "../sampler/descriptor.h"
#include "../sampler/subimg.h"
#include "../utils/utils.h"

#include <stdio.h>
#include <opencv/highgui.h>

MyCvDescriptor* myCvCreateDescriptor(int _descriptor_type) {
    
    MyCvDescriptor* re = NULL;
    re = malloc(sizeof(MyCvDescriptor));
    re->type = _descriptor_type;

    switch(_descriptor_type) {

    case MY_DESCRIPTOR_TYPE_COLOR:
    {
	re->data = (CvScalar*) malloc(sizeof(CvScalar));
	CvScalar color = cvScalar(0, 0, 0, 0);
	re->data = &color;
	break;
    }
    case MY_DESCRIPTOR_TYPE_PALETTE:
    {
	re->data = (MyCvPalette*) malloc(sizeof(MyCvPalette));
	MyCvPalette *palette = myCvCreatePalette(0);
	re->data = palette;
	break;
    }

    } 
    
    return re;
}

void myCvReleaseDescriptor(MyCvDescriptor** d) {
    if (*d != NULL) {
	if ((*d)->type == MY_DESCRIPTOR_TYPE_COLOR) {
	    free((*d)->data);
	    (*d)->data = NULL;
	} else if ((*d)->type == MY_DESCRIPTOR_TYPE_PALETTE) {
	    myCvReleasePalette((MyCvPalette**) &((*d)->data));
	}
    }
}

MyCvPalette* myCvCreatePalette(int _length) {
    MyCvPalette* re = malloc(sizeof(MyCvPalette)); 
    re->length = _length;
    float* pro = (float*) calloc(_length, sizeof(float));
    CvScalar* ct = (CvScalar*) calloc(_length, sizeof(CvScalar));
    
    for (int i = 0; i < _length; i++) {
	pro[i] = .0;
	ct[i] = cvScalar(0, 0, 0, 0);
    }

    re->proportion = pro;
    re->colorTable = ct;
    return re;
}

void myCvReleasePalette(MyCvPalette** p) {
    if (*p != NULL) {
	free((*p)->colorTable);
	free((*p)->proportion);
	(*p)->proportion = NULL;
	(*p)->colorTable = NULL;
	free(*p);
	*p = NULL;
    }
}

void myCvPixelColorDescriptor(IplImage* img, MyCvDescriptor* _descriptor, CvPoint _pixel) {
    assert(_descriptor->type == MY_DESCRIPTOR_TYPE_COLOR);
    CvScalar *color = malloc(sizeof(CvScalar));
    *color = cvGet2D(img, _pixel.y, _pixel.x);
    _descriptor->data = color;
}

void myCvPixelAvgColorDescriptor(IplImage* img, MyCvDescriptor* _descriptor, CvPoint _pixel, int _neighbor_size) {
    assert((_descriptor->type == MY_DESCRIPTOR_TYPE_COLOR) && (_neighbor_size >= 0));

    IplImage *subimg = sub_square(img, _pixel, _neighbor_size);
    CvScalar *color = malloc(sizeof(CvScalar));
    *color = cvAvg(subimg, NULL);
    _descriptor->data = color;
}

// get median value of an given image
CvScalar myCvMedianColor(IplImage* img) {
        // split into 3 channels
    CvMat *L = cvCreateMat(img->height, img->width, CV_32FC1), 
	*a = cvCreateMat(img->height, img->width, CV_32FC1),
	*b = cvCreateMat(img->height, img->width, CV_32FC1);
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
    int n = size;
    float medL = quick_select(arrL, n),
	meda = quick_select(arra, n),
	medb = quick_select(arrb, n);
    CvScalar re = cvScalar(medL, meda, medb, 0);

    return re;
}

void myCvPixelMedColorDescriptor(IplImage* img, MyCvDescriptor* _descriptor, CvPoint _pixel, int _neighbor_size) {
    assert((_descriptor->type == MY_DESCRIPTOR_TYPE_COLOR) && (_neighbor_size >= 0));

    IplImage *sub_img = sub_square(img, _pixel, _neighbor_size);
    
    CvScalar *color = malloc(sizeof(CvScalar));
    *color = myCvMedianColor(sub_img);

    _descriptor->data = color;
}

void myCvPixelPaletteDescriptor(MyQuantifiedImage* quant, MyCvDescriptor* _descriptor, CvPoint _pixel, int _neighbor_size) {
    assert((_descriptor->type == MY_DESCRIPTOR_TYPE_PALETTE) && (_neighbor_size >= 0));

    // initialization
    CvMat* labelMat = quant->labelMat;
    int paletteSize = quant->tableSize;

    MyCvPalette* palette = myCvCreatePalette(paletteSize);
    CvScalar* ct = calloc(quant->tableSize, sizeof(CvScalar));

    float* proportion = calloc(quant->tableSize, sizeof(float));
    for (int i = 0; i < quant->tableSize; i++) {
	proportion[i] = .0;
	ct[i] = (quant->colorTable)[i];
    }

    CvMat* interest_rect = sub_square_mat(labelMat, _pixel, _neighbor_size);
    for (int row = 0; row < interest_rect->rows; row++) {
	//const int* ptr = (const int*) (interest_rect->data.ptr) + row*interest_rect->step;
	for (int col = 0; col < interest_rect->cols; col++) {
	    int label = (int) cvGetReal2D(interest_rect, row, col);
	    proportion[label] += 1;
	}
    }
    
    int size = interest_rect->rows*interest_rect->cols;
    for (int i = 0; i < quant->tableSize; i++) {
	proportion[i] = proportion[i]/size;
    }
    palette->proportion = proportion;
    palette->colorTable = ct;

    _descriptor->data = palette;
}

