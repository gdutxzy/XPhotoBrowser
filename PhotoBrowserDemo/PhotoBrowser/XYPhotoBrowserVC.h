//
//  XYPhotoBrowserVC.h
//  PhotoBrowserDemo
//
//  Created by XZY on 2018/9/12.
//  Copyright © 2018年 xiezongyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYPhotoBrowserVC : UIViewController
@property (nonatomic,strong,readonly) NSArray<UIImage*> *imageArray;
@property (nonatomic,strong,readonly) NSArray<NSString*> *imageUrlArray;
@property (nonatomic,strong,readonly) NSArray<__kindof UIView*> *imageViewArray;

@end
