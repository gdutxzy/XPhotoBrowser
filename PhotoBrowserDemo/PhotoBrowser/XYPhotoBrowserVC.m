//
//  XYPhotoBrowserVC.m
//  PhotoBrowserDemo
//
//  Created by XZY on 2018/9/12.
//  Copyright © 2018年 xiezongyuan. All rights reserved.
//

#import "XYPhotoBrowserVC.h"
#import "XYPhotoBrowserCell.h"

@interface XYPhotoBrowserVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray<NSValue*> *imageOriginalFrameArray;

@property (nonatomic,assign) BOOL hiddenStatusBar;
@end

@implementation XYPhotoBrowserVC

+ (instancetype)photoBrowserWithImageURLs:(nullable NSArray<NSString*> *)imageUrlArray
                                   images:(nullable NSArray<UIImage*> *)imageArray
                               imageViews:(nonnull NSArray<__kindof UIView*> *)imageViewArray
                             currentIndex:(NSInteger)currentImageIndex{
    XYPhotoBrowserVC *vc = [[XYPhotoBrowserVC alloc] init];
    vc->_imageUrlArray = imageUrlArray;
    vc->_imageArray = imageArray;
    vc->_imageViewArray = imageViewArray;
    vc->_currentImageIndex = currentImageIndex;
    NSMutableArray *frameArray = [NSMutableArray arrayWithCapacity:imageViewArray.count];
    for (UIView *imageView in imageViewArray) {
        CGRect rect = [imageView convertRect:imageView.frame toView:[UIApplication sharedApplication].delegate.window];
        [frameArray addObject:[NSValue valueWithCGRect:rect]];
    }
    vc.imageOriginalFrameArray = frameArray;
    
    return vc;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext; // 保留上一层viewcontroller
        self.hiddenStatusBar = [UIApplication sharedApplication].statusBarHidden;
    }
    return self;
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
    [cell updateImageUrl:imageUrl image:image];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.x > 0 && scrollView.contentOffset.x < scrollView.contentSize.width) {
        _currentImageIndex = floor(scrollView.contentOffset.x/CGRectGetWidth(scrollView.bounds));
    }
}


#pragma mark - getter
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
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
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


- (BOOL)prefersStatusBarHidden{
    return YES;
}
@end
