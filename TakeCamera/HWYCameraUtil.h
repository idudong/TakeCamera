//
//  HWYBundlePath.h
//  TakeCamera
//
//  Created by yanghonglin on 16/3/5.
//  Copyright © 2016年 yanghonglin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface HWYCameraUtil : NSObject

/**
 *  获取图片资源的file path
 *
 *  @param imageName 图片资源名字
 *
 *  @return file path
 */
+ (NSString *)imagePathWithName:(NSString *)imageName;
/**
 *  顺时针旋转view 90度
 *
 *  @param aview
 */
+ (void)rotationView:(UIView *)aview;
/**
 *  button 下面加一个Label;
 *
 *  @param button 被修饰的button
 *  @param title  label的text
 */
+ (void)decorateLabelWithButton:(UIButton *)button title:(NSString *)title;
+ (UIImage *)cropWithInset:(CGFloat)dxy originImage:(UIImage *)originImage;

@end
