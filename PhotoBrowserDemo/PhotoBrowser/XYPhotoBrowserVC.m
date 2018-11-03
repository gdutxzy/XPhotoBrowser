//
//  XYPhotoBrowserVC.m
//  PhotoBrowserDemo
//
//  Created by XZY on 2018/9/12.
//  Copyright © 2018年 xiezongyuan. All rights reserved.
//

#import "XYPhotoBrowserVC.h"
#import "XYPhotoBrowserCell.h"
#import "XYPhotoBrowserTransition.h"
#import <Photos/PHPhotoLibrary.h>


@interface XYPhotoBrowserVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIViewControllerTransitioningDelegate,XYPhotoBrowserCellDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) XYPhotoBrowserTransition *photoTransition;
/// 锁定图片下标，防止旋转屏幕或3D-Touch导致的下标偏移
@property (nonatomic,assign) BOOL lockIndex;
@end

@implementation XYPhotoBrowserVC

+ (instancetype)photoBrowserWithImageURLs:(nullable NSArray<NSString*> *)imageUrlArray
                                   images:(nullable NSArray<UIImage*> *)imageArray
                               imageViews:(nonnull NSArray<UIImageView*> *)imageViewArray
                             currentIndex:(NSInteger)currentImageIndex{
    
    currentImageIndex = currentImageIndex < 0 ? 0 : (currentImageIndex < imageViewArray.count?currentImageIndex:imageViewArray.count-1);

    XYPhotoBrowserVC *vc = [[XYPhotoBrowserVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext; // 保留上一层viewcontroller
    vc->_hiddenOrignView = YES;
    vc->_imageUrlArray = imageUrlArray;
    vc->_imageArray = imageArray;
    vc->_imageViewArray = imageViewArray;
    vc->_currentImageIndex = currentImageIndex;
    vc.lockIndex = NO;
    vc.transitioningDelegate = vc;

//    NSMutableArray *frameArray = [NSMutableArray arrayWithCapacity:imageViewArray.count];
//    for (UIView *imageView in imageViewArray) {
//        CGRect rect = [imageView.superview convertRect:imageView.frame toView:[UIApplication sharedApplication].delegate.window.rootViewController.view];
//        [frameArray addObject:[NSValue valueWithCGRect:rect]];
//    }
//    vc->_imageOriginalFrameArray = frameArray;
    
    // 计算预览大小
    CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds)-30;
    CGFloat maxHeight = CGRectGetHeight([UIScreen mainScreen].bounds)-60;
    CGSize size = CGSizeMake(maxWidth, maxHeight);
    if (currentImageIndex < imageViewArray.count) {
        UIImage *image = imageViewArray[currentImageIndex].image;
        CGSize imageSize = image.size;
        if (image && !isnan(imageSize.width) && !isnan(imageSize.height) && imageSize.width > 0 && imageSize.height > 0) {
            if (imageSize.height/imageSize.width > maxHeight/maxWidth) { // 高度长图，以高度为比例基准
                size = CGSizeMake(round(maxHeight*imageSize.width/imageSize.height), maxHeight);
            }else{ // 以宽度为比例基准
                size = CGSizeMake(maxWidth,round(maxWidth*imageSize.height/imageSize.width));
            }
        }
    }
    vc.preferredContentSize = size;
    
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collectionView];
    
    UIView *collectionView = self.collectionView;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[collectionView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[collectionView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
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
    XYPhotoBrowserCell *cell = (XYPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentImageIndex inSection:0]];
    self->_currentShowImageView = cell.imageView;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [self.collectionView reloadData];
    self.lockIndex = YES;
}



#pragma mark - XYPhotoBrowserCellDelegate
- (void)photoBrowserCellDidTap:(XYPhotoBrowserCell *)cell{
    _currentShowImageView = cell.imageView;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoBrowserCellDidPan:(UIPanGestureRecognizer *)pan cell:(XYPhotoBrowserCell *)cell{
    if (pan.state == UIGestureRecognizerStateChanged || pan.state == UIGestureRecognizerStateBegan) {
        self.collectionView.hidden = YES;

    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.collectionView.hidden = NO;

        });

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
    XYPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XYPhotoBrowserCell" forIndexPath:indexPath];
    UIImage *image = nil;
    NSString *imageUrl = nil;
    if (self.imageArray.count > indexPath.row) {
        image = self.imageArray[indexPath.row];
    }
    if (self.imageUrlArray.count > indexPath.row) {
        imageUrl = self.imageUrlArray[indexPath.row];
    }
    if (!image) {
        image = self.imageViewArray[indexPath.row].image;
    }
    [cell updateImageUrl:imageUrl image:image];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (!self.lockIndex && scrollView.contentOffset.x > 0 && scrollView.contentOffset.x < scrollView.contentSize.width) {
        _currentImageIndex = floor(scrollView.contentOffset.x/CGRectGetWidth(scrollView.bounds));
        XYPhotoBrowserCell *cell = (XYPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentImageIndex inSection:0]];
        self->_currentShowImageView = cell.imageView;
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
        [_collectionView registerClass:[XYPhotoBrowserCell class] forCellWithReuseIdentifier:@"XYPhotoBrowserCell"];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.bounces = YES;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
    }
    return _collectionView;
}

- (XYPhotoBrowserTransition *)photoTransition{
    if (!_photoTransition) {
        _photoTransition = [[XYPhotoBrowserTransition alloc] init];
    }
    return _photoTransition;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    NSMutableArray *arrItem = [NSMutableArray array];
    UIPreviewAction *saveImageAction = [UIPreviewAction actionWithTitle:@"保存图片" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        if (self.currentImageIndex < [self.collectionView numberOfItemsInSection:0]) {
            XYPhotoBrowserCell *cell = (XYPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentImageIndex inSection:0]];
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [alert addAction:cancelAction];
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}



@end
