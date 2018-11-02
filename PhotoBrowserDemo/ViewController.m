//
//  ViewController.m
//  PhotoBrowserDemo
//
//  Created by XZY on 2018/9/12.
//  Copyright © 2018年 xiezongyuan. All rights reserved.
//

#import "ViewController.h"
#import <UIImageView+WebCache.h>
#import "XYPhotoBrowserVC.h"

@interface ViewController ()<UIViewControllerPreviewingDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation ViewController
- (IBAction)imageViewTap:(UITapGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;
    NSArray *urlArray = @[@"http://g.hiphotos.baidu.com/image/h%3D300/sign=6f4318466e2762d09f3ea2bf90ed0849/5243fbf2b211931376d158d568380cd790238dc1.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1541175831662&di=b73bbc36860f1784d3350f59327dc539&imgtype=0&src=http%3A%2F%2Fimg1.coin163.com%2F70%2F27%2FeIjq6r.gif"];
    NSArray *imageArray = @[self.imageView1,self.imageView2];
    NSInteger index = [imageArray indexOfObject:imageView];
    index = index == NSNotFound ? 0:index;
    
    XYPhotoBrowserVC *vc = [XYPhotoBrowserVC photoBrowserWithImageURLs:urlArray images:nil imageViews:imageArray currentIndex:index];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        [[SDWebImageDownloader sharedDownloader] setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    
    [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:@"http://img5.imgtn.bdimg.com/it/u=1505624731,3616873916&fm=27&gp=0.jpg"]];
    [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:@"http://g.hiphotos.baidu.com/image/h%3D300/sign=6f4318466e2762d09f3ea2bf90ed0849/5243fbf2b211931376d158d568380cd790238dc1.jpg"]];

    [self registerForPreviewingWithDelegate:self sourceView:self.imageView1];
    [self registerForPreviewingWithDelegate:self sourceView:self.imageView2];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSArray *urlArray = @[@"http://g.hiphotos.baidu.com/image/h%3D300/sign=6f4318466e2762d09f3ea2bf90ed0849/5243fbf2b211931376d158d568380cd790238dc1.jpg",@"http://img5.imgtn.bdimg.com/it/u=1505624731,3616873916&fm=27&gp=0.jpg"];
    NSArray *imageArray = @[self.imageView1,self.imageView2];
    NSInteger index = [imageArray indexOfObject:previewingContext.sourceView];
    index = index == NSNotFound ? 0:index;

    XYPhotoBrowserVC *vc = [XYPhotoBrowserVC photoBrowserWithImageURLs:urlArray images:nil imageViews:imageArray currentIndex:index];
    

    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:^{
        
    }];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
