//
//  XViewController.m
//  XPhotoBrowser
//
//  Created by gdutxzy on 11/05/2018.
//  Copyright (c) 2018 gdutxzy. All rights reserved.
//

#import "XViewController.h"
#import <XPhotoBrowser.h>
#import <UIImageView+WebCache.h>

@interface XViewController ()<UIViewControllerPreviewingDelegate>
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViewArray;
@property (strong,nonatomic) NSArray<NSString *> *urlArray;
@end

@implementation XViewController
- (IBAction)imageViewTap:(UITapGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;
    
    NSArray *urlArray = self.urlArray;
    NSArray *imageViewArray = self.imageViewArray;
    NSInteger index = [imageViewArray indexOfObject:imageView];
    index = index == NSNotFound ? 0:index;
    
    XPhotoBrowserVC *vc = [XPhotoBrowserVC photoBrowserWithImageURLs:urlArray images:nil imageViews:imageViewArray currentIndex:index];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.urlArray = @[@"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2064500517,3561753544&fm=26&gp=0.jpg",@"http://img5.imgtn.bdimg.com/it/u=1505624731,3616873916&fm=27&gp=0.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1541410039728&di=4f0f197fbe21041d177487f4dc72704a&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01cb11599aaeea0000002129536e52.gif"];
    
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
    for (NSInteger i = 0; i<self.imageViewArray.count; i++) {
        UIImageView *imageView = self.imageViewArray[i];
        if (i < self.urlArray.count) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.urlArray[i]]];
            if (@available(iOS 9.0, *)) {
                [self registerForPreviewingWithDelegate:self sourceView:imageView];
            }
        }
    }


   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSArray *urlArray = self.urlArray;
    NSArray *imageViewArray = self.imageViewArray;
    NSInteger index = [imageViewArray indexOfObject:previewingContext.sourceView];
    index = index == NSNotFound ? 0:index;
    
    XPhotoBrowserVC *vc = [XPhotoBrowserVC photoBrowserWithImageURLs:urlArray images:nil imageViews:imageViewArray currentIndex:index];
    
    /*** 3dTouch 操作列表替换 ***/
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"action1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@">>>UIPreviewAction1 click");
    }];
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"action2" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@">>>UIPreviewAction2 click");
    }];
    switch (arc4random()%3) {
        case 0:
            vc.touchPreviewActionItems = @[action1,action2];
            break;
        case 1:
            // 如果要清除内置的"保存图片"按钮，将其置用数组替代。
            vc.touchPreviewActionItems = @[];
            break;
        case 2:
            // 默认会显示"保存图片"按钮
            vc.touchPreviewActionItems = nil;
            break;
        default:
            vc.touchPreviewActionItems = nil;
            break;
    }

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
