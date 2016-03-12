//
//  HWYImagePreViewController.m
//  TakeCamera
//
//  Created by yanghonglin on 16/3/5.
//  Copyright © 2016年 yanghonglin. All rights reserved.
//

#import "HWYImagePreViewController.h"

#import "HWYCameraUtil.h"

@interface HWYImagePreViewController ()

@property (strong, nonatomic)       IBOutlet UIImageView        * preview;

//拍照按钮
@property (nonatomic, strong)       IBOutlet UIButton           * finishButton;
//取消按钮
@property (nonatomic, strong)       IBOutlet UIButton           * nextButton;
//关闭/开启闪光灯按钮
@property (nonatomic, strong)       IBOutlet UIButton           * retakeButton;
//数字label
@property (nonatomic, strong)       IBOutlet UILabel            * numberLabel;
//数字label背景圆点
@property (nonatomic, strong)       IBOutlet UIView             * numberBackView;
@property (nonatomic, strong)       IBOutlet UIView             * bottomView;

@end

@implementation HWYImagePreViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initialPreivew];
    [self initialBottomToolBar];
    [self initialNumberLabel];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialPreivew
{
    CGRect originFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 80);
    CGRect insetFrame = CGRectInset(originFrame, cropInset, cropInset);
    _preview = [[UIImageView alloc] initWithFrame:insetFrame];
    [self.view addSubview:_preview];
    _preview.contentMode = UIViewContentModeScaleAspectFill;
    _preview.image = _lastImage;
}

- (void)initialBottomToolBar
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 80, self.view.bounds.size.width, 80)];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:1.];
    self.bottomView = bottomView;
    //完成button
    NSString *path = [HWYCameraUtil imagePathWithName:@"icon-end"];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setImage:img forState:UIControlStateNormal];
    finishButton.frame = CGRectMake(bottomView.bounds.size.width / 4 * 3 - img.size.width / 2, (bottomView.bounds.size.height - img.size.height) / 2, img.size.width, img.size.height);
    [finishButton addTarget:self action:@selector(didClickFinishButton:) forControlEvents:UIControlEventTouchDown];
    [bottomView addSubview:finishButton];
    self.finishButton = finishButton;
    //下一张 buttton
    path = [HWYCameraUtil imagePathWithName:@"icon-next"];
    img = [[UIImage alloc] initWithContentsOfFile:path];
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setImage:img forState:UIControlStateNormal];
    nextBtn.frame = CGRectMake(bottomView.bounds.size.width / 2 - img.size.width / 2, (bottomView.bounds.size.height - img.size.height) / 2, img.size.width, img.size.height);
    [nextBtn addTarget:self action:@selector(didClickNextButton:) forControlEvents:UIControlEventTouchDown];
    [bottomView addSubview:nextBtn];
    self.nextButton = nextBtn;
    //关闭button
    path = [HWYCameraUtil imagePathWithName:@"icon-camera2"];
    img = [[UIImage alloc] initWithContentsOfFile:path];
    UIButton *retakeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [retakeBtn setImage:img forState:UIControlStateNormal];
    retakeBtn.frame = CGRectMake(bottomView.bounds.size.width / 4 - img.size.width / 2, (bottomView.bounds.size.height - img.size.height) / 2, img.size.width, img.size.height);
    [retakeBtn addTarget:self action:@selector(didClickRetakeButton:) forControlEvents:UIControlEventTouchDown];
    [bottomView addSubview:retakeBtn];
    self.retakeButton = retakeBtn;
    
    [self.view addSubview:bottomView];
    
    [HWYCameraUtil rotationView:self.finishButton];
    [HWYCameraUtil rotationView:self.nextButton];
    [HWYCameraUtil rotationView:self.retakeButton];
    [HWYCameraUtil decorateLabelWithButton:self.finishButton title:@"完成"];
    [HWYCameraUtil decorateLabelWithButton:self.nextButton title:@"下一张"];
    [HWYCameraUtil decorateLabelWithButton:self.retakeButton title:@"重拍"];
}

- (void)initialNumberLabel
{
    NSString *text = [NSString stringWithFormat:@"%d", (int)_imageNumber];
    UIFont *font = [UIFont systemFontOfSize:10];
    CGSize size = [text boundingRectWithSize:CGSizeMake(30, 20)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:font}
                                     context:NULL].size;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.nextButton.frame),
                                                                CGRectGetMaxY(self.nextButton.frame),
                                                                MAX(size.width + 6, 12), 12)];
    backView.layer.cornerRadius = 6;
    backView.layer.masksToBounds = YES;
    backView.center = CGPointMake(CGRectGetMaxX(self.nextButton.frame) - 3, CGRectGetMaxY(self.nextButton.frame));
    backView.backgroundColor = [UIColor colorWithRed:18./255. green:102./255. blue:196./255. alpha:1.0];
    self.numberBackView = backView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:backView.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = font;
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    self.numberLabel = label;
    
    [backView addSubview:label];
    [self.bottomView addSubview:backView];
    
    [HWYCameraUtil rotationView:backView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - action

- (void)didClickFinishButton:(id)sender
{
    [self.delegate finishTakeCamera];
}

- (void)didClickNextButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didClickRetakeButton:(id)sender
{
    [self.delegate retakeCamera];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
