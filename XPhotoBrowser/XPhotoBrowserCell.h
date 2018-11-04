//
//  XPhotoBrowserCell.h
//  PhotoBrowserDemo
//
//  Created by XZY on 2018/11/2.
//  Copyright © 2018 xiezongyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XPhotoBrowserCell;

@protocol XPhotoBrowserCellDelegate <NSObject>
@required
/// 单击回调
- (void)photoBrowserCellDidTap:(XPhotoBrowserCell *)cell;
/// 拖动回调
- (void)photoBrowserCellDidPan:(XPhotoBrowserCell *)cell pan:(nullable UIPanGestureRecognizer *)pan;

@end



@interface XPhotoBrowserCell : UICollectionViewCell
@property (nonatomic,strong,readonly) UIImage *image;
@property (nonatomic,strong,readonly) NSString *imageUrl;
@property (nonatomic,strong,readonly) UIImageView *imageView;

@property (nonatomic,weak) id<XPhotoBrowserCellDelegate> delegate;

- (void)updateImageUrl:(NSString *)imageUrl image:(UIImage *)image;

- (void)restoreScrollViewStatus;
@end

NS_ASSUME_NONNULL_END
