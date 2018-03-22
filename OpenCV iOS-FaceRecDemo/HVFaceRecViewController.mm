//
//  HVFaceRecViewController.m
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/22.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import "HVFaceRecViewController.h"

@interface HVFaceRecViewController ()<CvVideoCameraDelegate>
{
    cv::CascadeClassifier _faceDetector;
    std::vector<cv::Rect> _faceRects;
    std::vector<cv::Mat> _faceImgs;
}
@property (nonatomic, assign) CGFloat scale;

@end

@implementation HVFaceRecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_cameraView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
    self.scale = 2.0;
    
    self.tapBtn.layer.cornerRadius = 12.0;
    self.tapBtn.layer.borderWidth = 0.9;
    self.tapBtn.layer.borderColor = [UIColor blueColor].CGColor;
    
    NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2"
                 ofType:@"xml"];
    
    const CFIndex CASCADE_NAME_LEN = 2048;
    char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
    CFStringGetFileSystemRepresentation( (CFStringRef)faceCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
    
    _faceDetector.load(CASCADE_NAME);
    
    free(CASCADE_NAME);
    
}


#pragma mark - Protocol CvVideoCameraDelegate
- (void)processImage:(cv::Mat &)image {
    // Do some OpenCV stuff with the image
//    cv::Mat image_copy;
//    cvtColor(image, image_copy, cv::COLOR_BGR2GRAY);
//    // invert image
//    bitwise_not(image_copy, image_copy);
//    //Convert BGR to BGRA (three channel to four channel)
//    cv::Mat bgr;
//    cvtColor(image_copy, bgr, cv::COLOR_GRAY2BGR);
//    cvtColor(bgr, image, cv::COLOR_BGR2BGRA);
    
    [self detectAndDrawFacesOn:image scale:self.scale];
}

- (void)detectAndDrawFacesOn:(cv::Mat&)img scale:(double) scale
{
    int i = 0;
    double t = 0;
    
    const static cv::Scalar colors[] =  { CV_RGB(0,0,255),
        CV_RGB(0,128,255),
        CV_RGB(0,255,255),
        CV_RGB(0,255,0),
        CV_RGB(255,128,0),
        CV_RGB(255,255,0),
        CV_RGB(255,0,0),
        CV_RGB(255,0,255)} ;
    cv::Mat gray, smallImg( cvRound (img.rows/scale), cvRound(img.cols/scale), CV_8UC1 );
    
    cvtColor( img, gray, cv::COLOR_BGR2GRAY );
    resize( gray, smallImg, smallImg.size(), 0, 0, cv::INTER_LINEAR );
    equalizeHist( smallImg, smallImg );
    
    
    
    t = (double)cvGetTickCount();
    double scalingFactor = 1.1;
    int minRects = 2;
    cv::Size minSize(30,30);
    
    self->_faceDetector.detectMultiScale( smallImg, self->_faceRects,
                                         scalingFactor, minRects, 0,
                                         minSize );
    
    t = (double)cvGetTickCount() - t;
    //    printf( "detection time = %g ms\n", t/((double)cvGetTickFrequency()*1000.) );
    std::vector<cv::Mat> faceImages;
    
    for( std::vector<cv::Rect>::const_iterator r = _faceRects.begin(); r != _faceRects.end(); r++, i++ )
    {
        cv::Mat smallImgROI;
        cv::Point center;
        cv::Scalar color = colors[i%8];
        std::vector<cv::Rect> nestedObjects;
        rectangle(img,
                  cvPoint(cvRound(r->x*scale), cvRound(r->y*scale)),
                  cvPoint(cvRound((r->x + r->width-1)*scale), cvRound((r->y + r->height-1)*scale)),
                  color, 1, 8, 0);
        
        smallImgROI = smallImg(*r);
        
        faceImages.push_back(smallImgROI.clone());
        
    }
    
    @synchronized(self) {
        self->_faceImgs = faceImages;
    }
}

- (NSArray *)detectedFaces {
    NSMutableArray *facesArray = [NSMutableArray array];
    for( std::vector<cv::Rect>::const_iterator r = _faceRects.begin(); r != _faceRects.end(); r++ )
    {
        CGRect faceRect = CGRectMake(_scale*r->x/480., _scale*r->y/640., _scale*r->width/480., _scale*r->height/640.);
        [facesArray addObject:[NSValue valueWithCGRect:faceRect]];
    }
    return facesArray;
}

- (UIImage *)faceWithIndex:(NSInteger)idx {
    
    cv::Mat img = self->_faceImgs[idx];
    
    UIImage *ret = [self UIImageFromCVMat:img];
    
    return ret;
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
        [self.videoCamera start];
        [btn setTitle:@"关闭" forState:UIControlStateNormal];
        isOpen = NO;
    }else
    {
        [self.videoCamera stop];
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
    cv::Mat cvMat = [self cvMatGrayFromUIImage:bgImage];
    self.bgImageView.image = [self UIImageFromCVMat:cvMat];
}


- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC(1)); // 8 bits per component, 1 channels
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}

@end
