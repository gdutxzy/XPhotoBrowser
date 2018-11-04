#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UIView+XYExtension.h"
#import "XYPhotoBrowser.h"
#import "XYPhotoBrowserCell.h"
#import "XYPhotoBrowserTransition.h"
#import "XYPhotoBrowserVC.h"

FOUNDATION_EXPORT double XYPhotoBrowserVersionNumber;
FOUNDATION_EXPORT const unsigned char XYPhotoBrowserVersionString[];

