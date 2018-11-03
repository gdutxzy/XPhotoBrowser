//
//  XYPhotoBrowserCell.m
//  PhotoBrowserDemo
//
//  Created by XZY on 2018/11/2.
//  Copyright © 2018 xiezongyuan. All rights reserved.
//

#import "XYPhotoBrowserCell.h"
#import "UIView+XYExtension.h"
#import <UIImageView+WebCache.h>

@interface XYPhotoBrowserCell ()<UIScrollViewDelegate>{
    UIImageView *_imageView;
}
@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic,strong) UITapGestureRecognizer *singleTap;

/// 缩放中
@property (nonatomic,assign) BOOL doingZoom;

@end

@implementation XYPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self addGestureRecognizer:self.doubleTap];
        [self addGestureRecognizer:self.singleTap];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];

    UIView *scrollView = self.scrollView;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[scrollView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(scrollView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[scrollView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(scrollView)]];
}

- (void)updateImageUrl:(NSString *)imageUrl image:(UIImage *)image{
    _imageUrl = imageUrl;

    if (!image) {
        image = [UIView imageWithColor:[UIColor colorWithWhite:0.8 alpha:1]];
    }
    [self setImage:image];
    if (imageUrl.length > 0) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                [self setImage:image];
            }
        }];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setImage:self.image];
}

/// 计算imageview的center
- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY);
    
    return actualCenter;
}



#pragma mark - Action
- (void)doubleTapAction:(UITapGestureRecognizer *)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:self.imageView];
    if (self.scrollView.zoomScale <= 1.0){
        CGFloat scaleX = touchPoint.x + self.scrollView.contentOffset.x;//需要放大的图片的X点
        CGFloat sacleY = touchPoint.y + self.scrollView.contentOffset.y;//需要放大的图片的Y点
        [self.scrollView zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
    }else{
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}


- (void)singleTapAction:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(photoBrowserCellDidTap:)]) {
        CGFloat imageW = self.imageView.width;
        CGFloat imageH = self.imageView.height;
        [self.delegate photoBrowserCellDidTap:self];
    }
//    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserSubScrollViewDoSingleTapWithImageFrame:)])
//    {
//        CGFloat imageW = self.mainImageView.width;
//        CGFloat imageH = self.mainImageView.height;
//        //计算图片imageY需要考虑到图片此时的高
//        CGFloat imageY = (imageH < KDECEIVE_HEIGHT) ? (KDECEIVE_HEIGHT - imageH) * 0.5 : 0.0;
//        imageY = imageY - self.mainScrollView.contentOffset.y;
//        //centerX需要考虑到offset
//        CGFloat imageX = -self.mainScrollView.contentOffset.x;
//        [self.delegate photoBrowserSubScrollViewDoSingleTapWithImageFrame:CGRectMake(imageX, imageY, imageW, imageH)];
//    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
    self.doingZoom = NO;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.doingZoom = YES;
}


#pragma mark - setter
- (void)setImage:(UIImage * _Nonnull)image{
    _image = image;

    CGFloat maxWidth = CGRectGetWidth(self.bounds);
    CGFloat maxHeight = CGRectGetHeight(self.bounds);
    CGSize size = CGSizeMake(maxWidth, maxHeight);
    CGSize imageSize = image.size;
    if (image && !isnan(imageSize.width) && !isnan(imageSize.height) && imageSize.width>0 && imageSize.height > 0) {
        if (imageSize.height/imageSize.width > maxHeight/maxWidth) { // 高度长图，以高度为比例基准
            size = CGSizeMake(round(maxHeight*imageSize.width/imageSize.height), maxHeight);
        }else{ // 以宽度为比例基准
            size = CGSizeMake(maxWidth,round(maxWidth*imageSize.height/imageSize.width));
        }
    }

    self.imageView.width = size.width;
    self.imageView.height = size.height;
    self.imageView.image = image;
    self.scrollView.contentSize = self.imageView.bounds.size;
   
    self.imageView.center = [self centerOfScrollViewContent:_scrollView];
  
}


#pragma mark - getter
- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, self.width, self.height);
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.clipsToBounds = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        if (@available(iOS 11.0, *))
        {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollView.contentSize = _scrollView.bounds.size;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 4.0;
        _scrollView.zoomScale = 1.0f;
        _scrollView.contentOffset = CGPointZero;
    }
    return _scrollView;
}


- (UIImageView *)imageView
{
    
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}


- (UITapGestureRecognizer *)doubleTap
{
    if (!_doubleTap)
    {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired  =1;
    }
    return _doubleTap;
}

- (UITapGestureRecognizer *)singleTap
{
    if (!_singleTap)
    {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
        [_singleTap requireGestureRecognizerToFail:self.doubleTap];
    }
    return _singleTap;
}
@end
