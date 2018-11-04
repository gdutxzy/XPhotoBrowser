//
//  XPhotoBrowserCell.m
//  PhotoBrowserDemo
//
//  Created by XZY on 2018/11/2.
//  Copyright © 2018 xiezongyuan. All rights reserved.
//

#import "XPhotoBrowserCell.h"
#import "UIView+XExtension.h"
#import "UIImageView+WebCache.h"

@interface XPhotoBrowserCell ()<UIScrollViewDelegate>{
    UIImageView *_imageView;
}
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic,strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic,strong) UITapGestureRecognizer *singleTap;


/// 开始手势跟随退场动画
@property (nonatomic,assign) BOOL dismissPan;
/// 退场拖动手势开始时，scrollView的x偏移量
@property (nonatomic,assign) CGFloat offsetX;
/// 退场拖动手势开始时，scrollView的放大倍数
@property (nonatomic,assign) CGFloat zoomScale;

@end

@implementation XPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.dismissPan = NO;
        [self setupView];
        [self addGestureRecognizer:self.doubleTap];
        [self addGestureRecognizer:self.singleTap];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self addSubview:self.loadingView];
    
    UIView *scrollView = self.scrollView;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[scrollView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(scrollView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[scrollView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(scrollView)]];
    
    self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)updateImageUrl:(NSString *)imageUrl image:(UIImage *)image{
    _imageUrl = imageUrl;

    if (!image) {
        image = [UIView imageWithColor:[UIColor colorWithWhite:0.8 alpha:1]];
    }
    [self setImage:image];
    if (imageUrl.length > 0) {
        __weak typeof(self) weakSelf = self;
        [self.loadingView startAnimating];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [weakSelf.loadingView stopAnimating];
            if (image) {
                [weakSelf setImage:image];
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
- (void)doubleTapAction:(UITapGestureRecognizer *)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self.imageView];
    if (self.scrollView.zoomScale <= 1.0){
        CGFloat scaleX = touchPoint.x + self.scrollView.contentOffset.x;//需要放大的图片的X点
        CGFloat sacleY = touchPoint.y + self.scrollView.contentOffset.y;//需要放大的图片的Y点
        [self.scrollView zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
    }else{
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}


- (void)singleTapAction:(UITapGestureRecognizer *)recognizer {
    [self.delegate photoBrowserCellDidTap:self];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    UIPanGestureRecognizer *pan = scrollView.panGestureRecognizer;
    if (scrollView.contentOffset.y < 0 && pan.numberOfTouches == 1) {
        self.dismissPan = YES;
        self.offsetX = scrollView.contentOffset.x;
        self.zoomScale = scrollView.zoomScale;
    }
    if (self.dismissPan) {
        if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
            self.dismissPan = NO;
        }
        [self.delegate photoBrowserCellDidPan:self pan:pan];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.dismissPan) {
        self.dismissPan = NO;
        [self.delegate photoBrowserCellDidPan:self pan:nil];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
}


- (void)restoreScrollViewStatus{
    self.imageView.center = [self centerOfScrollViewContent:_scrollView];
    CGFloat x = self.offsetX>0?self.offsetX:0;
    CGFloat width = self.scrollView.contentSize.width < self.scrollView.width ? self.scrollView.width : self.scrollView.contentSize.width;
    if (x > width - self.scrollView.width ) {
        x = width - self.scrollView.width;
    }
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:NO];
}

#pragma mark - setter
- (void)setImage:(UIImage * _Nonnull)image{
    _image = image;

    CGFloat maxWidth = CGRectGetWidth(self.bounds);
    CGFloat maxHeight = CGRectGetHeight(self.bounds);
    CGSize size = CGSizeMake(maxWidth, maxHeight);
    CGSize imageSize = image.size;
    if (image && !isnan(imageSize.width) && !isnan(imageSize.height) && imageSize.width>0 && imageSize.height > 0) {
        if (imageSize.height/imageSize.width > maxHeight/maxWidth && imageSize.height/imageSize.width <= 5) { // 高度长图，以高度为比例基准。如果高宽比大于5，则认为是超长高图，则不执行。
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
- (UIScrollView *)scrollView {
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

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    }
    return _loadingView;
}


- (UIImageView *)imageView {
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}


- (UITapGestureRecognizer *)doubleTap {
    if (!_doubleTap)
    {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired  =1;
    }
    return _doubleTap;
}

- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap)
    {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
        [_singleTap requireGestureRecognizerToFail:self.doubleTap];
    }
    return _singleTap;
}


- (UIView *)photoVCView{
    UIView * vcView = nil;
    UIView * superView = self.superview;
    NSInteger i = 0;
    while (!vcView || i < 6) {
        if ([superView.nextResponder isKindOfClass:NSClassFromString(@"XPhotoBrowserVC")]) {
            vcView = superView;
            break;
        }
        superView = superView.superview;
        if (!superView) {
            break;
        }
        i++;
    }
    return vcView;
}
@end
