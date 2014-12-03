#include "sampler/subimg.h"
#include "sampler/sampler.h"
#include "sampler/quantify.h"
#include "utils/utils.h"

#include <stdio.h>
#include <opencv/cv.h>
#include <opencv/highgui.h>

int main(int argc, char** argv) {
    IplImage* img = myReadImg2Lab(argv[1]);
//    IplImage* img = cvLoadImage(argv[1], CV_LOAD_IMAGE_ANYCOLOR);

    int clusterNum = atoi(argv[2]);
    int neighborSize = atoi(argv[3]);

    MyQuantifiedImage* quant = kmeansQuantification(img, clusterNum);

    //IplImage* sub = sub_rect(img, cvPoint(500, 200), 300, 100);
    MyCvLine* line = myCvLineDir(img, cvPoint(0, 200), myCvDirect(1, 0), 1600);

    MyCvLineSampler* line_sampler = myCvLineSampler(quant, &line, MY_CV_SAMPLE_DESCRIPTOR_PALETTE, neighborSize);
    
    for (int i = 0; i < line_sampler->size; i++) {
	CvPoint *p = myCvGetLineSamplerPoint(line_sampler, i);
	printf("(%d, %d)\t", p->x, p->y);
	MyCvDescriptor d = (line_sampler->descriptors)[i];
	MyCvPalette* palette = (MyCvPalette*) d.data;
	printf("(");
	for (int color = 0; color < clusterNum; color++) {
	    printf("%f ", palette->proportion[color]);
	}
	printf(")\n");
    }
    
    MyCvDescriptor d = (line_sampler->descriptors)[0];
    MyCvPalette* palette = (MyCvPalette*) d.data;

    printf("Color table:\n");
    for (int color = 0; color < clusterNum; color++) {
	CvScalar c = palette->colorTable[color];
	printf("(%f, %f, %f)\n", c.val[0], c.val[1], c.val[2]);
    }
    
    //myCvHighVariancePointOnLine(line_sampler);

    for (int p = 0; p < line->size; p++) {
	CvPoint* point = (CvPoint*) cvGetSeqElem(line->points, p);
	printf ("(%d, %d)\t ", point->x, point->y);

	//TODO: debug myCvDV & ANNF
	CvScalar ss = myCvDV(myQuantifyGetImage(quant), *point, 3, 3, .3, 1);
	for (int i = 0; i < 4; i++) {
	    printf("%f ", ss.val[i]);
	}
	printf("\n");
    }
    
    // test ANNF contour
    IplImage* contour = cvCreateImage(
	cvSize(img->width, img->height),
	IPL_DEPTH_8U,
	3
	);
    cvZero(contour); // to black
    int palette_window = atoi(argv[4]);
    for (int i = 0; i < img->width; i++) {
	for (int j = 0; j < img->height; j++) {
	    CvPoint point = cvPoint(i, j);
	    //CvScalar ss = myCvDV(myQuantifyGetImage(quant), point, 5, 3, .3, 1);
	    //CvScalar ss = myCvDV(img, point, 5, 3, .3, 1);
	    CvScalar ss = myCvPaletteDV(quant, point, 5, palette_window, 0.3, 1);

	    double max = .0;
	    int max_k = -1;
	    for (int k = 0; k < 4; k++) {
		if (ss.val[k] > max) {
		    max = ss.val[k];
		    max_k = k;
		}
	    }
	    if (max < atoi(argv[5]))
		continue;
	    switch (max_k) {
	    case 0:
	    {
		CvPoint start = myCvHandleEdgePoint(cvPoint(i - 1, j), img->width, img->height);
		CvPoint end = myCvHandleEdgePoint(cvPoint(i + 1, j), img->width, img->height);
		cvLine(contour, start, end, cvScalar(255, 0, 0, 0), 1, 8, 0);
		break;
	    }
	    case 1:
	    {
		CvPoint start = myCvHandleEdgePoint(cvPoint(i, j - 1), img->width, img->height);
		CvPoint end = myCvHandleEdgePoint(cvPoint(i, j + 1), img->width, img->height);
		cvLine(contour, start, end, cvScalar(0, 255, 0, 0), 1, 8, 0);
		break;
	    }
	    case 2:
	    {
		CvPoint start = myCvHandleEdgePoint(cvPoint(i + 1, j - 1), img->width, img->height);
		CvPoint end = myCvHandleEdgePoint(cvPoint(i - 1, j + 1), img->width, img->height);
		cvLine(contour, start, end, cvScalar(0, 0, 255, 0), 1, 8, 0);
		break;
	    }
	    case 3:
	    {
		CvPoint start = myCvHandleEdgePoint(cvPoint(i - 1, j - 1), img->width, img->height);
		CvPoint end = myCvHandleEdgePoint(cvPoint(i + 1, j + 1), img->width, img->height);
		cvLine(contour, start, end, cvScalar(255, 255, 0, 0), 1, 8, 0);
		break;
	    }

	    }
	}
    }
  
//    cvLine(img, cvPoint(242, 400), cvPoint(256, 400), cvScalar(0, 0, 0, 0), 2, 8, 0);

    myDisplayLabImg("src", img);

    myDisplayLabImg("quant", myQuantifyGetImage(quant));
    
    myDisplayImg("contour", contour);

    cvReleaseImage(&img);
    cvReleaseImage(&contour);
    myCvReleaseQuantifiedImage(&quant);
    myCvReleaseLine(&line);
    myCvReleaseLineSampler(&line_sampler);
    return 0;
}
