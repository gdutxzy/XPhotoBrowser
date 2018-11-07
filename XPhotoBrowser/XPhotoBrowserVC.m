//
//  XPhotoBrowserVC.m
//  PhotoBrowserDemo
//
//  Created by XZY on 2018/9/12.
//  Copyright © 2018年 xiezongyuan. All rights reserved.
//

#import "XPhotoBrowserVC.h"
#import "XPhotoBrowserCell.h"
#import "XPhotoBrowserTransition.h"
#import <Photos/PHPhotoLibrary.h>
#import "UIView+XExtension.h"

@interface XPhotoBrowserVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIViewControllerTransitioningDelegate,XPhotoBrowserCellDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) XPhotoBrowserTransition *photoTransition;
@property (nonatomic,strong) UIPageControl *pageControl;
/// 锁定图片下标，防止旋转屏幕或3D-Touch导致的下标偏移
@property (nonatomic,assign) BOOL lockIndex;
/// 跟随手势运动的图片
@property (nonatomic,strong) UIImageView *tempImageView;
/// 跟随手势运动图片的初始Frame
@property (nonatomic,assign) CGRect tempOriginalFrame;
/// 跟随手势运动图片的X轴最小倍数
@property (nonatomic,assign) CGFloat minXScale;
/// 跟随手势运动图片的Y轴最小倍数
@property (nonatomic,assign) CGFloat minYScale;
/// 图片Y位移达到多少时，背景全透明，图片达到允许的最小值
@property (nonatomic,assign) CGFloat maxYOffset;
/// 跟随手势运动的图片与手指位置的初始X距离
@property (nonatomic,assign) CGFloat xDistance;
/// 跟随手势运动的图片与手指位置的初始Y距离
@property (nonatomic,assign) CGFloat yDistance;

@end

@implementation XPhotoBrowserVC
- (void)dealloc{
    NSLog(@">>>>>>XPhotoBrowserVC dealloc");
}
+ (instancetype)photoBrowserWithImageURLs:(nullable NSArray<NSString*> *)imageUrlArray
                                   images:(nullable NSArray<UIImage*> *)imageArray
                               imageViews:(nonnull NSArray<__kindof UIView*> *)imageViewArray
                             currentIndex:(NSInteger)currentImageIndex{
    
    currentImageIndex = currentImageIndex < 0 ? 0 : (currentImageIndex < imageViewArray.count?currentImageIndex:imageViewArray.count-1);

    XPhotoBrowserVC *vc = [[XPhotoBrowserVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext; // 保留上一层viewcontroller
    vc->_hiddenOrignView = YES;
    vc->_imageUrlArray = imageUrlArray;
    vc->_imageArray = imageArray;
    vc->_imageViewArray = imageViewArray;
    vc->_currentImageIndex = currentImageIndex;
    vc.lockIndex = NO;
    vc.transitioningDelegate = vc;
    
    // 计算预览大小
    CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds)-30;
    CGFloat maxHeight = CGRectGetHeight([UIScreen mainScreen].bounds)-120;
    CGSize size = CGSizeMake(maxWidth, maxHeight);
    UIImage *image = nil;
    if (currentImageIndex < imageArray.count) {
        image = imageArray[currentImageIndex];
    }
    if (!image) {
        if (currentImageIndex < imageViewArray.count) {
            UIImageView *imageView = imageViewArray[currentImageIndex];
            if ([imageView respondsToSelector:@selector(image)]) {
                if ([[imageView image] isKindOfClass:[UIImage class]]) {
                    image = [imageView image];
                }
            }
        }
    }
    CGSize imageSize = image.size;
    if (image && !isnan(imageSize.width) && !isnan(imageSize.height) && imageSize.width > 0 && imageSize.height > 0) {
        if (imageSize.height/imageSize.width > maxHeight/maxWidth) { // 高度长图，以高度为比例基准
            size = CGSizeMake(round(maxHeight*imageSize.width/imageSize.height), maxHeight);
        }else{ // 以宽度为比例基准
            size = CGSizeMake(maxWidth,round(maxWidth*imageSize.height/imageSize.width));
        }
    }
    vc.preferredContentSize = size;
    
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTap:)];
    [self.view addGestureRecognizer:tap];
    
    [self.view addSubview:self.collectionView];
    
    UIView *collectionView = self.collectionView;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[collectionView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[collectionView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    
    UIPageControl *pageControl = self.pageControl;
    pageControl.numberOfPages = self.imageViewArray.count;
    pageControl.currentPage = self.currentImageIndex;
    [self.view addSubview:pageControl];
    pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[pageControl]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pageControl)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageControl]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pageControl)]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setCurrentImageIndex:self.currentImageIndex];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (void)viewDidLayoutSubviews{
    if (self.lockIndex) { // 旋转屏或3D-Touch进来时，会有画面偏差
        [self setCurrentImageIndex:self.currentImageIndex];
    }
    self.lockIndex = CGRectGetHeight(self.view.bounds)<CGRectGetHeight([UIScreen mainScreen].bounds)-20;
    self.pageControl.hidden = self.lockIndex || self.tempImageView;
    XPhotoBrowserCell *cell = (XPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentImageIndex inSection:0]];
    self->_currentShowImageView = cell.imageView;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [self.collectionView reloadData];
    self.lockIndex = YES;
}

#pragma mark - Action
- (void)dismissTap:(UITapGestureRecognizer*)tap{
    // 防止出现某些意外，而使图片浏览器无法退出
    _currentShowImageView = self.tempImageView ? self.tempImageView : _currentShowImageView;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - XPhotoBrowserCellDelegate
- (void)photoBrowserCellDidTap:(XPhotoBrowserCell *)cell{
    _currentShowImageView = cell.imageView;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoBrowserCellDidPan:(XPhotoBrowserCell *)cell pan:(UIPanGestureRecognizer *)pan {
    if (!_tempImageView) {
        _tempImageView = [[UIImageView alloc] init];
        _tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        _tempImageView.backgroundColor = [UIColor clearColor];
        _tempImageView.layer.masksToBounds = YES;
        _tempImageView.image = cell.imageView.image;
        _tempImageView.frame = [cell.imageView.superview convertRect:cell.imageView.frame toView:self.view];
        [self.view addSubview:_tempImageView];
        self.collectionView.hidden = YES;
        
        for (UIImageView *view in self.imageViewArray) {
            view.hidden = NO;
        }
        self.imageViewArray[self.currentImageIndex].hidden = self.hiddenOrignView;

        _tempOriginalFrame = _tempImageView.frame;
        _minXScale = self.imageViewArray[self.currentImageIndex].frame.size.width/_tempOriginalFrame.size.width;
        _minYScale = self.imageViewArray[self.currentImageIndex].frame.size.height/_tempOriginalFrame.size.height;
        _minXScale = isnan(_minXScale) ? 0.2 : _minXScale;
        _minYScale = isnan(_minYScale) ? 0.2 : _minYScale;
        _minXScale = _minXScale > 1 ? 1 : _minXScale;
        _minYScale = _minYScale > 1 ? 1 : _minYScale;
        
        _maxYOffset = round(CGRectGetHeight(self.view.frame)*0.38);
        CGPoint point = [pan locationInView:self.view];
        _xDistance = CGRectGetMidX(_tempOriginalFrame)-point.x;
        _yDistance = CGRectGetMidY(_tempOriginalFrame)-point.y;
    }
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed || pan.state == UIGestureRecognizerStatePossible || !pan) {
        if (self.tempImageView.y > CGRectGetHeight(self.view.frame)*0.5) {
            _currentShowImageView = self.tempImageView;
            cell.delegate = nil;
            UIImageView *imageView = self.imageViewArray[self.currentImageIndex];
            [UIView animateWithDuration:0.3 animations:^{
                self.tempImageView.frame = [imageView.superview convertRect:imageView.frame toView:self.view];
                self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            }completion:^(BOOL finished) {
                self.imageViewArray[self.currentImageIndex].hidden = NO;
                [self dismissViewControllerAnimated:NO completion:nil];
            }];
        }else{
            if (_currentShowImageView != self.tempImageView && cell.delegate && !pan) {
                [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
                    if (self.tempImageView.x > 0 || self.tempImageView.y > 0 || self.tempImageView.bottom < self.view.height || self.tempImageView.right < self.view.width) {
                        [cell restoreScrollViewStatus];
                        CGRect rect = [cell.imageView.superview convertRect:cell.imageView.frame toView:self.view];
                        self.tempImageView.frame = rect;
                    }
                    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
                } completion:^(BOOL finished) {
                    self.collectionView.hidden = NO;
                    [self.tempImageView removeFromSuperview];
                    self.tempImageView = nil;
                }];
            }
        }
    }else {
        CGPoint location = [pan locationInView:self.view];
        CGPoint translation = [pan translationInView:self.view];
        CGFloat proportion = translation.y/self.maxYOffset;
        proportion = proportion > 1.0 ? 1.0 : (proportion < 0 ? 0 : proportion);
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:(1-proportion)];
        CGFloat xscale = 1-(1-self.minXScale)*proportion;
        CGFloat yscale = 1-(1-self.minYScale)*proportion;
        self.tempImageView.width = round(CGRectGetWidth(self.tempOriginalFrame)*xscale);
        self.tempImageView.height = round(CGRectGetHeight(self.tempOriginalFrame)*yscale);
        self.tempImageView.centerX = _xDistance*xscale+location.x;
        self.tempImageView.centerY = _yDistance*yscale+location.y;
    }
    
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return collectionView.bounds.size;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageViewArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XPhotoBrowserCell" forIndexPath:indexPath];
    UIImage *image = nil;
    NSString *imageUrl = nil;
    if (self.imageArray.count > indexPath.row) {
        image = self.imageArray[indexPath.row];
    }
    if (self.imageUrlArray.count > indexPath.row) {
        imageUrl = self.imageUrlArray[indexPath.row];
    }
    if (!image) {
        UIImageView *imageView = self.imageViewArray[indexPath.row];
        if ([imageView respondsToSelector:@selector(image)]) {
            if ([[imageView image] isKindOfClass:[UIImage class]]) {
                image = [imageView image];
            }
        }
    }
    [cell updateImageUrl:imageUrl image:image];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (!self.lockIndex && scrollView.contentOffset.x > 0 && scrollView.contentOffset.x < scrollView.contentSize.width) {
        _currentImageIndex = round(scrollView.contentOffset.x/CGRectGetWidth(scrollView.bounds));
        XPhotoBrowserCell *cell = (XPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentImageIndex inSection:0]];
        self->_currentShowImageView = cell.imageView;
        self.pageControl.currentPage = _currentImageIndex;
    }
}

#pragma mark -- UIViewControllerTransitioningDelegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self.photoTransition;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self.photoTransition;
}
#pragma mark - setter
- (void)setCurrentImageIndex:(NSInteger)currentImageIndex{
    currentImageIndex = currentImageIndex < 0 ? 0 : (currentImageIndex < _imageViewArray.count?currentImageIndex:_imageViewArray.count-1);

    _currentImageIndex = currentImageIndex;
    if (currentImageIndex < [self.collectionView numberOfItemsInSection:0]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentImageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

#pragma mark - getter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.headerReferenceSize = CGSizeZero;
        layout.footerReferenceSize = CGSizeZero;
        layout.sectionInset = UIEdgeInsetsZero;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        [_collectionView registerClass:[XPhotoBrowserCell class] forCellWithReuseIdentifier:@"XPhotoBrowserCell"];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.bounces = YES;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
    }
    return _collectionView;
}

- (XPhotoBrowserTransition *)photoTransition{
    if (!_photoTransition) {
        _photoTransition = [[XPhotoBrowserTransition alloc] init];
    }
    return _photoTransition;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    if (_touchPreviewActionItems) {
        return _touchPreviewActionItems;
    }
    NSMutableArray *arrItem = [NSMutableArray array];
    UIPreviewAction *saveImageAction = [UIPreviewAction actionWithTitle:@"保存图片" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        if (self.currentImageIndex < [self.collectionView numberOfItemsInSection:0]) {
            XPhotoBrowserCell *cell = (XPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentImageIndex inSection:0]];
            UIImage *image = cell.image;
            if (image) {
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
            }
        }
    }];
    [arrItem addObjectsFromArray:@[saveImageAction]];
    return arrItem;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"图片保存失败" message:@"请检查相册授权设置是否打开" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [alert addAction:cancelAction];
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}



@end
