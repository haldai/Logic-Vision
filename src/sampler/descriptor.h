#ifndef _DESCRIPTOR_H
#define _DESCRIPTOR_H

#include <opencv/cv.h>

#include "quantify.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MY_DESCRIPTOR_TYPE_COLOR 0 // only store one CvScalar as color
#define MY_DESCRIPTOR_TYPE_PALETTE 1 // palette, list of colors and their proportions

typedef struct {
    int type;
    void* data; // pointer to descriptor data
} MyCvDescriptor;

typedef struct {
    int length;
    float* proportion;
    CvScalar* colorTable;
} MyCvPalette;

extern MyCvDescriptor* myCvCreateDescriptor(int _descriptor_type);

extern void myCvReleaseDescriptor(MyCvDescriptor** d);

extern MyCvPalette* myCvCreatePalette(int _length);

extern void myCvReleasePalette(MyCvPalette** p);

extern void myCvPixelColorDescriptor(IplImage* img, MyCvDescriptor* _descriptor, CvPoint _pixel);

extern void myCvPixelAvgColorDescriptor(IplImage* img, MyCvDescriptor* _descriptor, CvPoint _pixel, int _neighbor_size); // neighbor type: square or circular

extern void myCvPixelMedColorDescriptor(IplImage* img, MyCvDescriptor* _descriptor, CvPoint _pixel, int _neighbor_size);

extern void myCvPixelPaletteDescriptor(MyQuantifiedImage* quant, MyCvDescriptor* _descriptor, CvPoint _pixel, int _neighbor_size);

#ifdef __cplusplus
}
#endif

#endif
