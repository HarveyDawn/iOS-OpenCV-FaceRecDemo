//
//  HVCameraViewController.m
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/22.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import "UIImage+OpenCV.h"
#import "HVCameraViewController.h"
#import "HVFaceRecViewController.h"
#import "HVFaceDetectorUtil.h"

@interface HVCameraViewController ()

@property (nonatomic, strong) HVFaceDetectorUtil *faceDetUtil;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation HVCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.faceDetUtil = [[HVFaceDetectorUtil alloc]initWithParentView:self.cameraView scale:2.0f];
    
    self.tapBtn.layer.cornerRadius = 12.0;
    self.tapBtn.layer.borderWidth = 0.9;
    self.tapBtn.layer.borderColor = [UIColor blueColor].CGColor;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(handleTap:)];
    
    [self.view addGestureRecognizer:_tapGestureRecognizer];
    self.view.userInteractionEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.faceDetUtil stopCapture];
}


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


- (void)handleTap:(UITapGestureRecognizer *)tapGesture {
    
    NSArray *detectedFaces = [self.faceDetUtil.detectedFaces copy];
    CGSize windowSize = self.view.bounds.size;
    
    for (NSValue *val in detectedFaces) {
        CGRect faceRect = [val CGRectValue];
        
        CGPoint tapPoint = [tapGesture locationInView:nil];
        //scale tap point to 0.0 to 1.0
        CGPoint scaledPoint = CGPointMake(tapPoint.x/windowSize.width, tapPoint.y/windowSize.height);
        if(CGRectContainsPoint(faceRect, scaledPoint)){
            NSLog(@"tapped on face: %@", NSStringFromCGRect(faceRect));
            UIImage *img = [self.faceDetUtil faceWithIndex:[detectedFaces indexOfObject:val]];
            [self performSegueWithIdentifier:@"RecognizeFace" sender:img];
        }
        else {
            NSLog(@"tapped on no face");
        }
    }
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"RecognizeFace"]) {
        NSAssert([sender isKindOfClass:[UIImage class]],@"RecognizeFace segue MUST be sent with an image");
        HVFaceRecViewController *frvc = segue.destinationViewController;
        frvc.inputImage = sender;
        
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
