#include <stdio.h>

#include <opencv/cv.h>
#include <opencv/highgui.h>

IplImage* g_image = NULL;
IplImage* g_gray = NULL;
int g_thresh = 100;
CvMemStorage* g_storage = NULL;

// Maxing out (saturating) only the “S” and “V” parts of an HSV image
void saturate_sv(IplImage* img) {
    for(int y = 0; y < img->height; y++) {
	uchar* ptr = (uchar*) (img->imageData + y * img->widthStep);
	for(int x = 0; x < img->width; x++) {
	    ptr[img->nChannels*x+1] = 255;
	    ptr[img->nChannels*x+2] = 255;
	}
    }
}

// Summing
float sum(const CvMat* mat){
float s = 0.0f;
    for(int row = 0; row < mat->rows; row++){
	const float* ptr = (const float*)(mat->data.ptr + row * mat->step);
	for(int col = 0; col < mat->cols; col++){
	    s += *ptr++;
	}
    }
    return(s);
}

void increment_pixels(IplImage* src, int x_, int y_, int height_, int width_, int add) {
    // 首先设置ROI
    cvSetImageROI(src, cvRect(x_, y_, width_, height_));
    // 然后直接对图片操作，实际上就是对ROI操作
    cvAddS(src, cvScalar(add, 0, 0, 0), src, NULL);
    // 最后重置ROI，恢复原状，否则display会只展示ROI
    cvResetImageROI(src);
    cvNamedWindow("Roi_Add", 1);
    cvShowImage("Roi_Add", src);
    cvWaitKey(0);
    cvDestroyWindow("Roi_Add");
}

void img_draw(IplImage* src) {
    CvPoint pt1 = cvPoint(100, 100);
    CvPoint pt2 = cvPoint(500, 500);
    CvScalar clr = CV_RGB(255, 255, 0);
    int thick = 10;
    int l_type = 8;
    // draw line
    cvLine(
	src,
	pt1,
	pt2,
	clr,
	thick,
	l_type,
	0
	);
    // draw circle
    cvCircle(
	src,
	cvPoint(300, 300),
	200,
	CV_RGB(255, 255, 0),
	thick,
	l_type,
	0
	);
}

void interest_rect(IplImage* interest_img, CvRect interest_rect) {
    // Assuming IplImage *interest_img; and
    // CvRect interest_rect;
    // Use widthStep to get a region of interest
    //
    // (Alternate method)
    //
    // 设置一个新img指针，并指向原图中需要修改的部分（矩形）
    // 便于同时操作多个位置
    IplImage *sub_img = cvCreateImageHeader(
	cvSize(
	    interest_rect.width,
	    interest_rect.height
	    ),
	interest_img->depth,
	interest_img->nChannels
	);
    IplImage* sub_img2 = cvCreateImageHeader(
	cvSize(
	    interest_rect.width,
	    interest_rect.height
	    ),
	interest_img->depth,
	interest_img->nChannels
	);
    sub_img->origin = interest_img->origin;
    sub_img->widthStep = interest_img->widthStep;
    sub_img->imageData = interest_img->imageData +
	(interest_rect.y) * interest_img->widthStep +
	(interest_rect.x) * interest_img->nChannels;
    sub_img2->origin = interest_img->origin;
    sub_img2->widthStep = interest_img->widthStep;
    sub_img2->imageData = interest_img->imageData +
	(interest_rect.y + 50) * interest_img->widthStep +
	(interest_rect.x + 50) * interest_img->nChannels;
    //cvAddS(sub_img, cvScalar(50, 0, 0, 0), sub_img, NULL);
    //cvAddS(sub_img2, cvScalar(50, 0, 0, 0), sub_img2, NULL);
    //cvAbsDiff(sub_img, sub_img2, sub_img);
    //cvAddWeighted(sub_img, 0.5, sub_img2, 0.5, 0, sub_img2);
    //cvReleaseImageHeader(&sub_img);
    //cvReleaseImageHeader(&sub_img2);
    //cvConvertScale(sub_img, sub_img, 0.5, 0.0);

    cvNamedWindow("Roi_Add", 1);
    cvShowImage("Roi_Add", interest_img);
    cvWaitKey(0);
    cvDestroyWindow("Roi_Add");
}

void n_display(char* name, IplImage* img) {
    cvNamedWindow(name, CV_WINDOW_AUTOSIZE);
    cvShowImage(name, img);
    
}

void sum_rgb(IplImage* src, IplImage* dst) {
    // Allocate individual image planes.
    IplImage* r = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
    IplImage* g = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
    IplImage* b = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
    // Split image onto the color planes.
    cvSplit(src, b, g, r, NULL);
    // Temporary storage.
    IplImage* s = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
    // Add equally weighted rgb values.
    cvAddWeighted(r, 1./3., g, 1./3., 0.0, s);
    cvAddWeighted(s, 2./3., b, 1./3., 0.0, s);
    // Truncate values above 100.
    cvThreshold(s, dst, 100, 100, CV_THRESH_TRUNC);
    cvReleaseImage(&r);
    cvReleaseImage(&g);
    cvReleaseImage(&b);
    cvReleaseImage(&s);
}

void process(IplImage* src, IplImage* dst) {
    //cvSmooth(src, dst, CV_GAUSSIAN, 7, 7, 0, 0);
    //cvSmooth(src, dst, CV_MEDIAN, 5, 3, 0, 0);
    

    IplConvKernel* kernel = cvCreateStructuringElementEx(
	3,
	3,
	1,
	1,
	CV_SHAPE_RECT,
	NULL
	);


    //cvErode(src, dst, kernel, 3);
    cvDilate(src, dst, kernel, 3);

    IplImage* temp = cvCreateImageHeader(cvGetSize(src), IPL_DEPTH_8U, 3);
    //cvMorphologyEx(src, dst, temp, kernel, CV_MOP_CLOSE, 5);

    //cvFloodFill(src, cvPoint(500,500), CV_RGB(255, 255, 0), cvScalar(7, 0, 0, 0), cvScalar(7, 0, 0, 0), NULL, 4, NULL);

    //IplImage* dst_ = cvCreateImage(cvSize(src->width/2.0, src->height/2.0), IPL_DEPTH_8U, 3);
    //cvResize(src, dst_, CV_INTER_LINEAR);

    //sum_rgb(src, dst);
}

void transform(IplImage* src, IplImage* dst) {
    // Canny edge detector
    //cvCanny(src, dst, 150, 200, 3);

    // Sobel gradient transformer
    //cvSobel(src, dst, 0, 1, 3);
    
    // Laplace filter
    cvLaplace(src, dst, 5);
}

// Finding contours based on a trackbar’s location; the contours are updated whenever the trackbar is moved

void on_trackbar() {
    if (g_storage == NULL) {
	g_gray = cvCreateImage(cvGetSize(g_image), 8, 1);
	g_storage = cvCreateMemStorage(0);
    } else {
	cvClearMemStorage(g_storage);
    }
    CvSeq* contours = 0;
    cvCvtColor(g_image, g_gray, CV_RGB2GRAY);
    cvThreshold(g_gray, g_gray, g_thresh, 255, CV_THRESH_BINARY);
    cvFindContours(g_gray, g_storage, &contours, sizeof(CvContour), CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cvPoint(0,0));
    cvZero(g_gray);
    if (contours) {
	cvDrawContours(g_gray, contours, cvScalar(255, 0, 0, 0), cvScalar(255, 0, 0, 0), 100, 1, 8, cvPoint(0, 0));
	cvShowImage("Contours", g_gray);
    }
}

void contour(IplImage* src) {
    //CvMemStorage* storage = cvCreateMemStorage(10);
    //cvReleaseMemStorage(&storage);
    //cvClearMemStorage(storage);
    g_image = src;
    cvNamedWindow("Contours", 1 );
    cvCreateTrackbar(
	"Threshold",
	"Contours",
	&g_thresh,
	255,
	on_trackbar
	);
    on_trackbar();
    cvWaitKey(0);
}

int main(int argc, char** argv) {
    IplImage* img = cvLoadImage(argv[1], CV_LOAD_IMAGE_COLOR);
    IplImage* aft = cvCreateImage(cvGetSize(img), IPL_DEPTH_8U, 1);
    IplImage* dst = cvCreateImage(cvGetSize(img), IPL_DEPTH_8U, 3);

    float vals[] = {0.866025, -0.500000, 0.500000, -0.866026};
    CvMat rotMat;
    cvInitMatHeader(&rotMat, 2, 2, CV_32FC1, vals, CV_AUTOSTEP);

    CvMat* mat = cvCreateMat(5, 5, CV_32FC1);
    float element = CV_MAT_ELEM(rotMat, float, 0, 0);
    
    *((float*)CV_MAT_ELEM_PTR(*mat, 3, 2)) = element;
    
    printf("element in mat: %f\n", CV_MAT_ELEM(*mat, float, 3, 2));

    printf("%d\n", cvGetElemType(&rotMat));
    printf("%d\n", cvGetDims(&rotMat, NULL));
    printf("sum is: %f\n", sum(&rotMat));

    //printf("dimension %d\n", cvGetDims(img, NULL));

    CvSize size = cvGetSize(img);
    printf("size: %d, %d\n", size.width, size.height);
    
    /* convert image to gray scale */
    //cvCvtColor(img, aft, CV_RGB2GRAY);
    
    // img_draw(img);
    
    // process(img, dst);
    
    // transform(dst, dst);

    // contour(dst);

    cvCvtColor(img, dst, CV_BGR2Lab);
    CvScalar scalar = cvGet2D(dst, 100, 100);
    printf("%f, %f, %f\n", scalar.val[0], scalar.val[1], scalar.val[2]);
    
    n_display("test1", img);
    n_display("test2", dst);

    cvWaitKey(0);
    cvReleaseImage(&img);
    cvDestroyWindow("test1");
    cvReleaseImage(&dst);
    cvDestroyWindow("test2");


    
    //cvNormalize(img, img, 1.0, 0.0, CV_L2, NULL);

    // saturate_sv(img);

    // increment_pixels(aft, 100, 100, 400, 400, -30);
    // CvRect rect = cvRect(100, 100, 100, 100);
    // interest_rect(aft, rect);

    /*
    cvNamedWindow("Example1", CV_WINDOW_AUTOSIZE);
    cvShowImage("Example1", img);
    cvNamedWindow("Example2", CV_WINDOW_AUTOSIZE);
    cvShowImage("Example2", aft);

    printf("Image size = %d x %d\n ", (*aft).height, (*aft).width);
    
    cvWaitKey(0);
    cvReleaseImage(&aft);
    cvReleaseImage(&img);
    cvDestroyWindow("Example1");
    cvDestroyWindow("Example2");
    */
    return 0;
}
