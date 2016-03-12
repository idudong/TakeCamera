//
//  HWYImagePreViewController.h
//  TakeCamera
//
//  Created by yanghonglin on 16/3/5.
//  Copyright © 2016年 yanghonglin. All rights reserved.
//

#import <UIKit/UIKit.h>

//拍照剪切的区域为
static CGFloat const cropInset = 0;

@protocol HWYImagePreViewControllerDelegate <NSObject>

//重新拍照
- (void)retakeCamera;
//完成拍照
- (void)finishTakeCamera;

@end

@interface HWYImagePreViewController : UIViewController

@property (nonatomic, assign)       NSInteger                                     imageNumber;
@property (nonatomic, weak)         id<HWYImagePreViewControllerDelegate>         delegate;
@property (nonatomic, strong)       UIImage                                     * lastImage;

@end
