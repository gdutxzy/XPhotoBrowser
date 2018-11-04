//
//  XYPhotoBrowserCell.h
//  PhotoBrowserDemo
//
//  Created by XZY on 2018/11/2.
//  Copyright © 2018 xiezongyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XYPhotoBrowserCell;

@protocol XYPhotoBrowserCellDelegate <NSObject>
@required
/// 单击回调
- (void)photoBrowserCellDidTap:(XYPhotoBrowserCell *)cell;
/// 拖动回调,用于控制背景透明度
- (void)photoBrowserCellDidPanProportion:(CGFloat)proportion;

@end



@interface XYPhotoBrowserCell : UICollectionViewCell
@property (nonatomic,strong,readonly) UIImage *image;
@property (nonatomic,strong,readonly) NSString *imageUrl;
@property (nonatomic,strong,readonly) UIImageView *imageView;

@property (nonatomic,weak) id<XYPhotoBrowserCellDelegate> delegate;

- (void)updateImageUrl:(NSString *)imageUrl image:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
