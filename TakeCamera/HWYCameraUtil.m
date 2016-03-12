//
//  HWYBundlePath.m
//  TakeCamera
//
//  Created by yanghonglin on 16/3/5.
//  Copyright © 2016年 yanghonglin. All rights reserved.
//

#import "HWYCameraUtil.h"

#define kTakeCameraBundleName  @"HJTakeCamera.bundle"
#define kTakeCameraBundlePath [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kTakeCameraBundleName]
#define kTakeCameraBundle [NSBundle bundleWithPath:kTakeCameraBundlePath]


@implementation HWYCameraUtil

+ (NSString *)imagePathWithName:(NSString *)imageName
{
    NSBundle *libBundle = kTakeCameraBundle;
    if ( libBundle && imageName ){
        NSString *path =[[libBundle resourcePath ] stringByAppendingPathComponent:imageName];
        return path;
    }
    
    return nil;
}

+ (void)rotationView:(UIView *)aview
{
    aview.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1.);
}

+ (void)decorateLabelWithButton:(UIButton *)button title:(NSString *)title
{
    UIFont *font = [UIFont systemFontOfSize:9];
    CGSize size = [title boundingRectWithSize:CGSizeMake(100, 20)
                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                   attributes:@{NSFontAttributeName:font}
                                      context:NULL].size;
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(button.frame),
                                                               CGRectGetMidY(button.frame),
                                                               size.width, size.height)];
    lable.center = CGPointMake(CGRectGetMinX(button.frame) - 15, CGRectGetMidY(button.frame));
    lable.font = font;
    lable.backgroundColor = [UIColor clearColor];
    lable.textColor = [UIColor colorWithRed:0x99/255. green:0x99/255. blue:0x99/255. alpha:1.];
    lable.text = title;
    [button.superview addSubview:lable];
    [[self class] rotationView:lable];
}

+ (UIImage *)cropWithInset:(CGFloat)dxy originImage:(UIImage *)originImage
{
    if (dxy == 0) {
        return  originImage;
    }
    CGImageRef imageRef = [originImage CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(imageRef, CGRectInset(CGRectMake(0, 0, originImage.size.width, originImage.size.height), dxy, dxy));
    UIImage *croppedImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

@end
