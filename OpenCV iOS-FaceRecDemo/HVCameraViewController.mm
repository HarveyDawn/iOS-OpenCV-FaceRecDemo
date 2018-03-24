//
//  HVCameraViewController.m
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/22.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import "UIImage+OpenCV.h"
#import "HVCameraViewController.h"
#import "HVFaceDetectorUtil.h"

@interface HVCameraViewController ()

@property (nonatomic, strong) HVFaceDetectorUtil *faceDetUtil;

@end

@implementation HVCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.faceDetUtil = [[HVFaceDetectorUtil alloc]initWithParentView:self.cameraView scale:2.0f];
    
    self.tapBtn.layer.cornerRadius = 12.0;
    self.tapBtn.layer.borderWidth = 0.9;
    self.tapBtn.layer.borderColor = [UIColor blueColor].CGColor;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - UI Actions
- (IBAction)actionStart:(id)sender;
{
    UIButton *btn = (UIButton *)sender;
    static BOOL isOpen = YES;
    if (isOpen) {
        [self.faceDetUtil startCapture];
        [btn setTitle:@"关闭" forState:UIControlStateNormal];
        isOpen = NO;
    }else
    {
        [self.faceDetUtil stopCapture];
        [btn setTitle:@"开始" forState:UIControlStateNormal];
        isOpen = YES;
    }
}


#pragma mark - cvChangeImageColor
- (void)cvChangeImageColor
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    //NSString *path = [resourcePath stringByAppendingPathComponent:@"IMG_0036.jpg"];
    NSString *path = [resourcePath stringByAppendingPathComponent:@"IMG_1038.jpg"];
    
    UIImage *bgImage = [UIImage imageWithContentsOfFile:path];
    //cv::Mat cvMat = [self cvMatFromUIImage:bgImage];
    cv::Mat cvMat = [UIImage cvMatGrayFromUIImage:bgImage];
    self.bgImageView.image = [UIImage imageFromCVMat:cvMat];
}






@end
