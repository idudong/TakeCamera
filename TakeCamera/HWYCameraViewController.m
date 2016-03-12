//
//  HWYCameraViewController.m
//  TakeCamera
//
//  Created by yanghonglin on 16/3/5.
//  Copyright © 2016年 yanghonglin. All rights reserved.
//

#import "HWYCameraViewController.h"

#import "HWYTakePhotoViewController.h"

@interface HWYCameraViewController ()

@end

@implementation HWYCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (HWYCameraViewController *)presentCameViewControllerCompleteHandler:(void (^)(NSArray *imageList))completeBlock
{
    UIViewController *con = [[UIApplication sharedApplication].delegate window].rootViewController;
    if (con) {
        HWYTakePhotoViewController *takePhotoCon = [[HWYTakePhotoViewController alloc] init];
        HWYCameraViewController *cameCon = [[HWYCameraViewController alloc] initWithRootViewController:takePhotoCon];
        takePhotoCon.completeHandler = completeBlock;
        [con presentViewController:cameCon animated:YES completion:NULL];
        return cameCon;
    }
    
    return nil;

}

+ (HWYCameraViewController *)presentCameViewControllerCompleteBase64Handler:(void (^)(NSArray *imageBase64List))completeBlock
{
    UIViewController *con = [[UIApplication sharedApplication].delegate window].rootViewController;
    if (con) {
        HWYTakePhotoViewController *takePhotoCon = [[HWYTakePhotoViewController alloc] init];
        HWYCameraViewController *cameCon = [[HWYCameraViewController alloc] initWithRootViewController:takePhotoCon];
        takePhotoCon.completeBase64Handler = completeBlock;
        [con presentViewController:cameCon animated:YES completion:NULL];
        return cameCon;
    }
    
    return nil;

}

@end
