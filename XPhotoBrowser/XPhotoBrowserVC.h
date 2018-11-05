//
//  XPhotoBrowserVC.h
//  PhotoBrowserDemo
//
//  Created by XZY on 2018/9/12.
//  Copyright © 2018年 xiezongyuan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XPhotoBrowserVC : UIViewController

@property (nonatomic,strong,readonly) NSArray<UIImage*> *imageArray;
@property (nonatomic,strong,readonly) NSArray<NSString*> *imageUrlArray;
@property (nonatomic,strong,readonly) NSArray<UIImageView*> *imageViewArray;

@property (nonatomic,assign) NSInteger currentImageIndex;
/**
 是否隐藏原图。当拖动图片进入半透明背景的跟随状态时，是否隐藏原来的图片。默认隐藏，default is YES。
 */
@property (nonatomic,assign) BOOL hiddenOrignView;

/// 当前展示的图片
@property (nonatomic,strong,readonly) UIImageView *currentShowImageView;

/**
 生成图片浏览器

 @param imageUrlArray 图片网址
 @param imageArray 图片（原图片，或者网络图片未完成前的placeholderImage）
 @param imageViewArray 图片来源view数组
 @param currentImageIndex 当前展示的下标
 @warning 除非为空，否则三个数组参数的count必须一致。
 */
+ (instancetype)photoBrowserWithImageURLs:(nullable NSArray<NSString*> *)imageUrlArray
                                   images:(nullable NSArray<UIImage*> *)imageArray
                               imageViews:(nonnull NSArray<UIImageView*> *)imageViewArray
                             currentIndex:(NSInteger)currentImageIndex;

/// 3DTouch预览图出来后，向上滑动时出现的操作列表。UIPreviewAction数组。3DTouch相关只能在iOS9以上使用。
@property (nonatomic,strong) NSArray* touchPreviewActionItems;
@end


