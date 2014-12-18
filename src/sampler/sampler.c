#include <math.h>
#include <stdio.h>

#include "../sampler/sampler.h"
#include "../sampler/subimg.h"
#include "../sampler/descriptor.h"
#include "../utils/utils.h"

MyCvDirect myCvDirect(int _x, int _y) {
    MyCvDirect re;

    re.x = _x;
    re.y = _y;

    return re;
}

MyCvLine* myCvLine(IplImage* img, CvPoint _start, CvPoint _end) {

    assert((myCvInImage(img, _start) && myCvInImage(img, _end)));
    // create sequence of points
    CvMemStorage* m_storage = cvCreateMemStorage(0);
    CvSeq* seq = cvCreateSeq(CV_SEQ_ELTYPE_POINT, sizeof(CvSeq), sizeof(CvPoint), m_storage);

    // push points into sequence and count line size
    CvLineIterator iterator;
    int size = cvInitLineIterator(img, _start, _end, &iterator, 8, 0);
    int x, y, offset;
    for (int i = 0; i < size; i++) {
	offset = iterator.ptr - (uchar*)(img->imageData);
	y = offset/img->widthStep;
	x = (offset - y*img->widthStep)/(img->nChannels*sizeof(float)); 
	CvPoint p = cvPoint(x, y);
	cvSeqPush(seq, &p);

	CV_NEXT_LINE_POINT(iterator);
    }

    MyCvLine* re = NULL;

    re = malloc(sizeof(MyCvLine));
    re->size = size;
    re->start = _start;
    re->end = _end;

    re->points = seq;
    return re;
}

MyCvLine* myCvLineDir(IplImage* img, CvPoint _start, MyCvDirect _direct, int _length) {
    assert(myCvInImage(img, _start));

    MyCvLine* re = NULL;
    re = malloc(sizeof(MyCvLine));
    re->start = _start;

    CvMemStorage* m_storage = cvCreateMemStorage(0);
    CvSeq* seq = cvCreateSeq(CV_SEQ_ELTYPE_POINT, sizeof(CvSeq), sizeof(CvPoint), m_storage);
    
    CvLineIterator iterator;
    cvInitLineIterator(img, _start, cvPoint(_start.x + _direct.x, _start.y + _direct.y), &iterator, 8, 0);
    
    // keep direction and iterate
    int x, y, offset;
    int length = 0;
    //CvPoint last = cvPoint(0, 0);
    for (int i = 0; i < _length; i++) {
	offset = iterator.ptr - (uchar*)(img->imageData);
	y = offset/img->widthStep;
	x = (offset - y*img->widthStep)/(img->nChannels*sizeof(float)); 
	CvPoint p = cvPoint(x, y);
	if (i != 0 && myCvReachImageEdge(img, p)) {
	    cvSeqPush(seq, &p);
	    length++;
	    re->end = p;
	    break;
	}
	else {
	    cvSeqPush(seq, &p);
	    length++;
	}
	CV_NEXT_LINE_POINT(iterator);
    }
    re->points = seq;
    re->size = length;
    return re;
}

MyCvLineSampler* myCvLineSampler(void* img, MyCvLine** lineAdd, int _descriptor_type, int _neighbor_size) {

    MyCvLine* line = *lineAdd;

    assert((_descriptor_type <= 4) &&
	   (_descriptor_type >= 0) &&
	   (_neighbor_size >= 0) &&
	   (line->size > 0));

    MyCvLineSampler* re = NULL;
    re = malloc(sizeof(MyCvLineSampler));
    re->line = lineAdd;
    re->descriptor_type = _descriptor_type;
    re->size = line->size;
    
    re->descriptors = calloc(line->size, sizeof(MyCvDescriptor));



    switch(_descriptor_type) {
    case MY_CV_SAMPLE_DESCRIPTOR_PIXEL: 
    {
	// the pixel
	re->neighbor_size = 0;
	for (int i = 0; i < line->size; i++) {
	    CvPoint* p = (CvPoint*) cvGetSeqElem(line->points, i);
	    MyCvDescriptor *d = myCvCreateDescriptor(MY_DESCRIPTOR_TYPE_COLOR);
	    myCvPixelColorDescriptor((IplImage*) img, d, *p);
	    (re->descriptors)[i] = *d;
	}
    }
	break;
    case MY_CV_SAMPLE_DESCRIPTOR_AVG_PIXEL:
    {
	// average pixel value
	re->neighbor_size = _neighbor_size;

	for (int i = 0; i < line->size; i++) {
	    CvPoint* p = (CvPoint*) cvGetSeqElem(line->points, i); // MyCvLine is stored as a sequence
	    MyCvDescriptor* d = myCvCreateDescriptor(MY_DESCRIPTOR_TYPE_COLOR);
	    myCvPixelAvgColorDescriptor((IplImage*) img, d, *p, _neighbor_size);
	    (re->descriptors)[i] = *d;
	}
    }
	break;
    case MY_CV_SAMPLE_DESCRIPTOR_MED_PIXEL:
    {
	// median pixel value
	re->neighbor_size = _neighbor_size;
	for (int i = 0; i < line->size; i++) {
	    CvPoint* p = (CvPoint*) cvGetSeqElem(line->points, i);
	    MyCvDescriptor* d = myCvCreateDescriptor(MY_DESCRIPTOR_TYPE_COLOR);
	    myCvPixelMedColorDescriptor((IplImage*) img, d, *p, _neighbor_size);
	    (re->descriptors)[i] = *d;
	}
    }
	break;
    case MY_CV_SAMPLE_DESCRIPTOR_PALETTE:
    {
	re->neighbor_size = _neighbor_size;
	for (int i = 0; i < line->size; i++) {
	    CvPoint *p = (CvPoint*) cvGetSeqElem(line->points, i);
	    MyCvDescriptor* d = myCvCreateDescriptor(MY_DESCRIPTOR_TYPE_PALETTE);
	    myCvPixelPaletteDescriptor((MyQuantizedImage*) img, d, *p, _neighbor_size);
	    (re->descriptors)[i] = *d;
	}
    }
	break;
    }

    return re;
}

CvPoint* myCvGetLineSamplerPoint(MyCvLineSampler* ls, int i) {
    return (CvPoint*) cvGetSeqElem((*(ls->line))->points, i);
}

void myCvReleaseLine(MyCvLine** l) {
    if (*l != NULL) {
	cvClearMemStorage((*l)->points->storage);
	cvReleaseMemStorage(&((*l)->points->storage));
	(*l)->points = NULL;
	free(*l);
	*l = NULL;
    }
}

void myCvReleaseLineSampler(MyCvLineSampler** s) {
    if (*s != NULL) {
	for (int i = 0; i < (*s)->size; i++) {
	    MyCvDescriptor* d = &(((*s)->descriptors)[i]);
	    myCvReleaseDescriptor(&d);
	}
	free((*s)->descriptors);
	(*s)->descriptors = NULL;
	myCvReleaseLine((*s)->line);
	free(*s);
	*s = NULL;
    }
}

/* compute difference between two palette discriptor
 * TODO_LATER: palette with different color tables
 */
float paletteDescriptorDiff(MyCvPalette *palette1, MyCvPalette *palette2, int same_color_table, double l_channel_weight) {
    CvScalar* color_table_1 = palette1->colorTable;
    //CvScalar* color_table_2 = palette2->colorTable;
    float* proportion_1 = palette1->proportion;
    float* proportion_2 = palette2->proportion;
    int length1 = palette1->length;
//    int length2 = palette2->length;

    if (same_color_table) {
	// same color table, different proportion
	int length = length1;
	CvScalar avg_1 = cvScalar(0, 0, 0, 0);
	CvScalar avg_2 = cvScalar(0, 0, 0, 0);

	for (int clr = 0; clr < length; clr++) {
	    avg_1.val[0] += l_channel_weight*proportion_1[clr]*color_table_1[clr].val[0];
	    avg_2.val[0] += l_channel_weight*proportion_2[clr]*color_table_1[clr].val[0];
	    for (int i = 1; i < 4; i++) {
		avg_1.val[i] += proportion_1[clr]*color_table_1[clr].val[i];
		avg_2.val[i] += proportion_2[clr]*color_table_1[clr].val[i];
	    }
	}
	float re = 0.0;
	for (int i = 0; i < 4; i++) {
	    re += pow((avg_1.val[i] - avg_2.val[i]), 2);
	}
	return sqrt(re);
    } else {
	return .0;
    }
}

double myCvPaletteDistance(MyQuantizedImage* quant, CvPoint p1, CvPoint p2, int filter_size, double l_channel_weight) {

    assert(filter_size%2 == 1);
    
    int half_width = (filter_size - 1)/2;
    
    CvMat* s1 = sub_square_mat(quant->labelMat, p1, half_width);
    CvMat* s2 = sub_square_mat(quant->labelMat, p2, half_width);
    
    MyCvPalette* palette1 = myCvCreatePalette(quant->tableSize);
    MyCvPalette* palette2 = myCvCreatePalette(quant->tableSize);

    CvScalar* ct1 = calloc(quant->tableSize, sizeof(CvScalar));
    CvScalar* ct2 = calloc(quant->tableSize, sizeof(CvScalar));


    float* prop1 = calloc(quant->tableSize, sizeof(float));
    float* prop2 = calloc(quant->tableSize, sizeof(float));
    
    for (int i = 0; i < quant->tableSize; i++) {
	prop1[i] = .0;
	prop2[i] = .0;
	ct1[i] = (quant->colorTable)[i];
	ct2[i] = (quant->colorTable)[i];
    }

    for (int row = 0; row < s1->rows; row++) {
	for (int col = 0; col < s1->cols; col++) {
	    int label = (int) cvGetReal2D(s1, row, col);
	    prop1[label] += 1;
	}
    }

    for (int row = 0; row < s2->rows; row++) {
	for (int col = 0; col < s2->cols; col++) {
	    int label = (int) cvGetReal2D(s2, row, col);
	    prop2[label] += 1;
	}
    }

    
    int size1 = s1->rows*s1->cols;
    int size2 = s2->rows*s2->cols;
    for (int i = 0; i < quant->tableSize; i++) {
	prop1[i] = prop1[i]/size1;
	prop2[i] = prop2[i]/size2;
    }

    // two palettes
    palette1->proportion = prop1;
    palette2->proportion = prop2;
    palette1->colorTable = ct1;
    palette2->colorTable = ct2;

    return paletteDescriptorDiff(palette1, palette2, 1, l_channel_weight);
}

// Use Euclidean distance to get edge point
CvPoint* myCvHighVariancePointOnLine(MyCvLineSampler* line_sampler) {
    if (line_sampler->descriptor_type == MY_CV_SAMPLE_DESCRIPTOR_PALETTE) {
	//MyCvPalette *palette = (MyCvPalette*) d.data;
	
	float diff_1[line_sampler->size - 1];
	/* color component difference */
	for (int i = 0; i < line_sampler->size - 1; i++) {
	    MyCvDescriptor d1 = (line_sampler->descriptors)[i];
	    MyCvDescriptor d2 = (line_sampler->descriptors)[i + 1];
	    MyCvPalette *palette1 = (MyCvPalette*) d1.data;
	    MyCvPalette *palette2 = (MyCvPalette*) d2.data;
	    diff_1[i] = paletteDescriptorDiff(palette1, palette2, 0.3, 1);
	}
	// TODO: find optimum
	for (int i = 0; i < line_sampler->size - 1; i++) {
	    printf("%d, %f\n", i, diff_1[i]);
	}

	return NULL;
    } else {
	// TODO: color descriptor
	return NULL;
    }
}

CvScalar myCvDV(IplImage* img, CvPoint point, int size, int filter_size, double l_channel_weight, int hv) {
    // size must be an odd number
    assert(size%2 == 1);
    int rad = (size - 1)/2; // radius
    
    // differential of -, |, \ and / direction
    CvScalar result = cvScalar(0, 0, 0, 0);
    int x = point.x, y = point.y; // anchor point
    // compute deviation of vectors for different direction
    for (int r = 1; r <= rad; r++) {
	// 0 degree and 90 degree
	CvPoint p_0_1 = myCvHandleEdgePoint(cvPoint(x, y + r), 
					    img->width, img->height);
	CvPoint p_0_2 = myCvHandleEdgePoint(cvPoint(x, y - r), 
					    img->width, img->height);
	CvPoint p_90_1 = myCvHandleEdgePoint(cvPoint(x + r, y), 
					     img->width, img->height);
	CvPoint p_90_2 = myCvHandleEdgePoint(cvPoint(x - r, y), 
					     img->width, img->height);
	result.val[0] += myCvPointANNFDist(img, p_0_1, p_0_2, filter_size, l_channel_weight);
	result.val[1] += myCvPointANNFDist(img, p_90_1, p_90_2, filter_size, l_channel_weight);
	// if not hv, then add two more direction
	if (!hv) {
	    CvPoint p_45_1 = myCvHandleEdgePoint(cvPoint(x + r, y - r),
						 img->width, img->height);
	    CvPoint p_45_2 = myCvHandleEdgePoint(cvPoint(x - r, y + r),
						 img->width, img->height);
	    CvPoint p_135_1 = myCvHandleEdgePoint(cvPoint(x - r, y - r),
						  img->width, img->height);
	    CvPoint p_135_2 = myCvHandleEdgePoint(cvPoint(x + r, y + r),
						  img->width, img->height);
	    result.val[2] += myCvPointANNFDist(img, p_45_1, p_45_2, filter_size, l_channel_weight);
	    result.val[3] += myCvPointANNFDist(img, p_135_1, p_135_2, filter_size, l_channel_weight);
	}
    }
    
    for (int i = 0; i < 4; i++) {
	result.val[i] = result.val[i]/rad;
    }
    return result;
}

CvScalar myCvPaletteDV(MyQuantizedImage* quant, CvPoint point, int size, int filter_size, double l_channel_weight, int hv) {
    // size must be an odd number
    assert(size%2 == 1);
    int rad = (size - 1)/2; // radius
    
    IplImage* img = quant->qImg;
    // differential of -, |, \ and / direction
    CvScalar result = cvScalar(0, 0, 0, 0);
    int x = point.x, y = point.y; // anchor point
    // compute deviation of vectors for different direction
    for (int r = 1; r <= rad; r++) {
	// 0 degree and 90 degree
	CvPoint p_0_1 = myCvHandleEdgePoint(cvPoint(x, y + r), 
					    img->width, img->height);
	CvPoint p_0_2 = myCvHandleEdgePoint(cvPoint(x, y - r), 
					    img->width, img->height);
	CvPoint p_90_1 = myCvHandleEdgePoint(cvPoint(x + r, y), 
					     img->width, img->height);
	CvPoint p_90_2 = myCvHandleEdgePoint(cvPoint(x - r, y), 
					     img->width, img->height);
	result.val[0] += myCvPaletteDistance(quant, p_0_1, p_0_2, filter_size, l_channel_weight);
	result.val[1] += myCvPaletteDistance(quant, p_90_1, p_90_2, filter_size, l_channel_weight);
	// if not hv, then add two more direction
	if (!hv) {
	    CvPoint p_45_1 = myCvHandleEdgePoint(cvPoint(x + r, y - r),
						 img->width, img->height);
	    CvPoint p_45_2 = myCvHandleEdgePoint(cvPoint(x - r, y + r),
						 img->width, img->height);
	    CvPoint p_135_1 = myCvHandleEdgePoint(cvPoint(x - r, y - r),
						  img->width, img->height);
	    CvPoint p_135_2 = myCvHandleEdgePoint(cvPoint(x + r, y + r),
						  img->width, img->height);
	    result.val[2] += myCvPaletteDistance(quant, p_45_1, p_45_2, filter_size, l_channel_weight);
	    result.val[3] += myCvPaletteDistance(quant, p_135_1, p_135_2, filter_size, l_channel_weight);
	}
    }
    
    for (int i = 0; i < 4; i++) {
	result.val[i] = result.val[i]/rad;
    }
    return result;
}

