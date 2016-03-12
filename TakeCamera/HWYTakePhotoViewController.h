//
//  HWYTakePhotoViewController.h
//  TakeCamera
//
//  Created by yanghonglin on 16/3/2.
//  Copyright © 2016年 yanghonglin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ImageListCompleteHandler) (NSArray *imageList);
typedef void (^ImageBase64ListCompleteHandler) (NSArray *imageBase64List);

@interface HWYTakePhotoViewController : UIViewController

@property (nonatomic, copy)     ImageListCompleteHandler            completeHandler;
@property (nonatomic, copy)     ImageBase64ListCompleteHandler      completeBase64Handler;

@end
