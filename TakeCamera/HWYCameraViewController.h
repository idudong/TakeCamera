//
//  HWYCameraViewController.h
//  TakeCamera
//
//  Created by yanghonglin on 16/3/5.
//  Copyright © 2016年 yanghonglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWYCameraViewController : UINavigationController

+ (HWYCameraViewController *)presentCameViewControllerCompleteHandler:(void (^)(NSArray *imageList))completeBlock;
+ (HWYCameraViewController *)presentCameViewControllerCompleteBase64Handler:(void (^)(NSArray *imageBase64List))completeBlock;

@end
