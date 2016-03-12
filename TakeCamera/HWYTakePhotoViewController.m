//
//  HWYTakePhotoViewController.m
//  TakeCamera
//
//  Created by yanghonglin on 16/3/2.
//  Copyright © 2016年 yanghonglin. All rights reserved.
//

#import "HWYTakePhotoViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "HWYImagePreViewController.h"
#import "HWYCameraUtil.h"

@interface HWYTakePhotoViewController ()
<HWYImagePreViewControllerDelegate>

//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong)       AVCaptureSession            * session;
//AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong)       AVCaptureDeviceInput        * videoInput;
//照片输出流对象，当然我的照相机只有拍照功能，所以只需要这个对象就够了
@property (nonatomic, strong)       AVCaptureStillImageOutput   * stillImageOutput;
//capture device
@property (nonatomic, strong)       AVCaptureDevice             * captureDevice;
//预览图层，来显示照相机拍摄到的画面
@property (nonatomic, strong)       AVCaptureVideoPreviewLayer  * previewLayer;

@property (nonatomic)               dispatch_queue_t              sessionQueue;
//聚焦
@property (nonatomic, strong)       UIImageView                 * focusImageView;
@property (nonatomic, assign)       int                           alphaTimes;
@property (nonatomic, assign)       CGPoint                       currTouchPoint;
//拍照按钮
@property (nonatomic, strong)       IBOutlet UIButton           * toggleButton;
//取消按钮
@property (nonatomic, strong)       IBOutlet UIButton           * cancelButton;
//关闭/开启闪光灯按钮
@property (nonatomic, strong)       IBOutlet UIButton           * lightButton;
//放置预览图层的View
@property (nonatomic, strong)       IBOutlet UIView             * cameraShowView;
//闪光灯是否开启
@property (nonatomic, assign)       BOOL                          lightOn;
@property (nonatomic, strong)       NSMutableArray              * imageList;

@end

@implementation HWYTakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.imageList = [NSMutableArray array];
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;
    
    [self initialSession];
    [self setUpCameraLayer];
    [self initialBottomToolBar];
    [self initialFocusView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.session) {
        [self.session startRunning];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialSession
{
    //这个方法的执行我放在init方法里了
    self.session = [[AVCaptureSession alloc] init];
    self.captureDevice = [self backCamera];
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:nil];
    //[self fronCamera]方法会返回一个AVCaptureDevice对象，因为我初始化时是采用前摄像头，所以这么写，具体的实现方法后面会介绍
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}


- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (void) setUpCameraLayer
{
    _cameraShowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 80)];
    _cameraShowView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_cameraShowView];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    UIView *view = self.cameraShowView;
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [self.previewLayer setFrame:bounds];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [viewLayer addSublayer:self.previewLayer];
}

- (void)initialBottomToolBar
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 80, self.view.bounds.size.width, 80)];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:1.];
    //闪光灯button
    NSString *path = [HWYCameraUtil imagePathWithName:@"icon-light"];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    UIButton *ligthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [ligthButton setImage:img forState:UIControlStateNormal];
    ligthButton.frame = CGRectMake(bottomView.bounds.size.width / 4 - img.size.width / 2, (bottomView.bounds.size.height - img.size.height) / 2, img.size.width, img.size.height);
    [ligthButton addTarget:self action:@selector(didClickLightButton:) forControlEvents:UIControlEventTouchDown];
    [bottomView addSubview:ligthButton];
    self.lightButton = ligthButton;
    //拍照buttton
    path = [HWYCameraUtil imagePathWithName:@"camera2"];
    img = [[UIImage alloc] initWithContentsOfFile:path];
    UIButton *takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [takeBtn setImage:img forState:UIControlStateNormal];
    takeBtn.frame = CGRectMake(bottomView.bounds.size.width / 2 - img.size.width / 2, (bottomView.bounds.size.height - img.size.height) / 2, img.size.width, img.size.height);
    [takeBtn addTarget:self action:@selector(didClickTakeCamera:) forControlEvents:UIControlEventTouchDown];
    [bottomView addSubview:takeBtn];
    self.toggleButton = takeBtn;
    //关闭button
    path = [HWYCameraUtil imagePathWithName:@"icon-close"];
    img = [[UIImage alloc] initWithContentsOfFile:path];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:img forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(bottomView.bounds.size.width / 4 * 3 - img.size.width / 2, (bottomView.bounds.size.height - img.size.height) / 2, img.size.width, img.size.height);
    [closeBtn addTarget:self action:@selector(didClickCancelButton:) forControlEvents:UIControlEventTouchDown];
    [bottomView addSubview:closeBtn];
    self.cancelButton = closeBtn;
    
    [self.view addSubview:bottomView];
    
    [HWYCameraUtil rotationView:self.lightButton];
    [HWYCameraUtil rotationView:self.toggleButton];
    [HWYCameraUtil rotationView:self.cancelButton];
    [HWYCameraUtil decorateLabelWithButton:self.lightButton title:@"闪光灯"];
    [HWYCameraUtil decorateLabelWithButton:self.cancelButton title:@"取消"];
}

- (BOOL)authorizedForCamera
{
    if(([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized)) {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
            }];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法使用相机" message:@"请在设置中允许使用相机以用来拍照" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        return NO;
    }
    
    return YES;
}

//对焦的框
- (void)initialFocusView {
    NSString *path = [HWYCameraUtil imagePathWithName:@"icon_touch_focus"];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.alpha = 0;
    [self.view addSubview:imgView];
    self.focusImageView = imgView;
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device addObserver:self forKeyPath:ADJUSTINT_FOCUS options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
#endif
}

- (IBAction)didClickLightButton:(id)sender {
    if ([self authorizedForCamera]) {
        if([self.captureDevice hasFlash])
        {
            [self.captureDevice lockForConfiguration:nil];
            if (self.captureDevice.flashMode == AVCaptureFlashModeOff) {
                self.captureDevice.flashMode = AVCaptureFlashModeOn;
            } else if (self.captureDevice.flashMode == AVCaptureFlashModeOn) {
                self.captureDevice.flashMode = AVCaptureFlashModeAuto;
            } else if (self.captureDevice.flashMode == AVCaptureFlashModeAuto) {
                self.captureDevice.flashMode = AVCaptureFlashModeOff;
            }
            [self.captureDevice unlockForConfiguration];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的设备没有闪光灯功能" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (IBAction)didClickTakeCamera:(id)sender {
    AVCaptureConnection *myVideoConnection = nil;
    //从 AVCaptureStillImageOutput 中取得正确类型的 AVCaptureConnection
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                
                myVideoConnection = connection;
                break;
            }
        }
    }
    
    __weak HWYTakePhotoViewController *weakSelf = self;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:myVideoConnection
                                                       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                           if (imageDataSampleBuffer && !error) {
                                                               NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                               
                                                               //取得的静态影像
                                                               UIImage *myImage = [[UIImage alloc] initWithData:imageData];
                                                               //剪切到指定的大小
                                                               UIImage *croppedImage = [HWYCameraUtil cropWithInset:cropInset originImage:myImage];
                                                               @synchronized(weakSelf) {
                                                                   [weakSelf.imageList addObject:croppedImage];
                                                               }
                                                               HWYImagePreViewController *preImgController = [[HWYImagePreViewController alloc] init];
                                                               preImgController.lastImage = [weakSelf.imageList lastObject];
                                                               preImgController.delegate = weakSelf;
                                                               preImgController.imageNumber = [weakSelf.imageList count];
                                                               [weakSelf.navigationController pushViewController:preImgController animated:NO];
                                                           }
                                                       }];
}

- (IBAction)didClickCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.session.isRunning) [self.session stopRunning];
}

#pragma mark - notification handler

- (void)applicationWillResignActive {
    if (self.session.isRunning) [self.session stopRunning];
}

- (void)applicationDidBecomeActive {
    if (!self.session.isRunning) [self.session startRunning];
}

#pragma mark - 到处符合要求的图片
// 通过抽样缓存数据创建一个UIImage对象
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return image;
}

#pragma mark - preview delegate

- (void)retakeCamera
{
    @synchronized(self) {
        [self.imageList removeLastObject];
    }
}

- (void)finishTakeCamera
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    if (_completeBase64Handler) {
        NSArray *list = _imageList.copy;
        _imageList = nil;
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *base64List = [NSMutableArray arrayWithCapacity:list.count];
        [list enumerateObjectsUsingBlock:^(UIImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *imageData = UIImageJPEGRepresentation(obj, 1.0f);
            NSString *base64Str = [imageData base64EncodedStringWithOptions:0];
            [base64List addObject:base64Str];
        }];
        
        //            dispatch_async(dispatch_get_main_queue(), ^{
        _completeBase64Handler(base64List.copy);
        //            });
        //        });
    } else if (_completeHandler) {
        _completeHandler(_imageList.copy);
    }
}

#pragma mark - focus

#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
//监听对焦是否完成了
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ADJUSTINT_FOCUS]) {
        BOOL isAdjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        if (!isAdjustingFocus) {
            alphaTimes = -1;
        }
    }
}

- (void)showFocusInPoint:(CGPoint)touchPoint {
    
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        int alphaNum = (alphaTimes % 2 == 0 ? HIGH_ALPHA : LOW_ALPHA);
        self.focusImageView.alpha = alphaNum;
        alphaTimes++;
        
    } completion:^(BOOL finished) {
        
        if (alphaTimes != -1) {
            [self showFocusInPoint:currTouchPoint];
        } else {
            self.focusImageView.alpha = 0.0f;
        }
    }];
}
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //    [super touchesBegan:touches withEvent:event];
    
    _alphaTimes = -1;
    
    UITouch *touch = [touches anyObject];
    _currTouchPoint = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(self.previewLayer.bounds, _currTouchPoint) == NO) {
        return;
    }
    
    [self focusInPoint:_currTouchPoint];
    
    //对焦框
    [_focusImageView setCenter:_currTouchPoint];
    _focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    [UIView animateWithDuration:0.1f animations:^{
        _focusImageView.alpha = HIGH_ALPHA;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [self showFocusInPoint:currTouchPoint];
    }];
#else
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _focusImageView.alpha = 1.f;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _focusImageView.alpha = 0.f;
        } completion:nil];
    }];
#endif
}

- (void)focusInPoint:(CGPoint)devicePoint {
    devicePoint = [self convertToPointOfInterestFromViewCoordinates:devicePoint];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    __weak HWYTakePhotoViewController *weakSelf = self;
    dispatch_async(_sessionQueue, ^{
        AVCaptureDevice *device = weakSelf.captureDevice;
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@", error);
        }
    });
}

/**
 *  外部的point转换为camera需要的point(外部point/相机页面的frame)
 *
 *  @param viewCoordinates 外部的point
 *
 *  @return 相对位置的point
 */
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _previewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.previewLayer;
    
    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for(AVCaptureInputPort *port in [[self.session.inputs lastObject]ports]) {
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

@end
