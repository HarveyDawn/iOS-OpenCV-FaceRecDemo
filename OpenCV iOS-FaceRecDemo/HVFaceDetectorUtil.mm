//
//  HVFaceDetectorUtil.m
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/23.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/face.hpp>
#endif

#import "HVFaceDetectorUtil.h"

#import "NSString+addition.h"
#import "UIImage+OpenCV.h"

@interface HVFaceDetectorUtil()<CvVideoCameraDelegate>
{
    cv::CascadeClassifier _faceDetector;
    cv::CascadeClassifier _eyesDetector;
    
    std::vector<cv::Rect> _faceRects;
    std::vector<cv::Mat> _faceImgs;
    
    cv::Ptr<cv::face::LBPHFaceRecognizer> _faceRecognizer;
}

@property (nonatomic, retain) CvVideoCamera *videoCamera;
@property (nonatomic, assign) CGFloat scale;

@end


@implementation HVFaceDetectorUtil

- (instancetype)initWithParentView:(UIImageView *)parentView scale:(CGFloat)scale
{
    self = [super init];
    if (self) {
        
        _videoCamera = [[CvVideoCamera alloc] initWithParentView:parentView];
        _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
        _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        _videoCamera.defaultFPS = 30;
        _videoCamera.grayscaleMode = NO;
        _videoCamera.delegate = self;
        _scale = scale;
        
        
        //Haar Cascade常用来做人脸检测，其实它可以检测任何对象。
        //OpenCV 项目源码中有很多训练好的Haar分类器。
        
        //加载项目中训练好的Haar分类器
        NSString *faceCascadePath = [[NSBundle mainBundle]
                                     pathForResource:@"haarcascade_frontalface_alt2"
                                     ofType:@"xml"];
        
        _faceDetector.load([faceCascadePath UTF8String]);
        
        
        NSString *eyesCascadePath = [[NSBundle mainBundle]
                                     pathForResource:@"haarcascade_eye_tree_eyeglasses"
                                     ofType:@"xml"];
        
        _eyesDetector.load([eyesCascadePath UTF8String]);
        
    }
    
    return self;
}

- (void)startCapture
{
    [self.videoCamera start];
}

- (void)stopCapture
{
    [self.videoCamera stop];
}

#pragma mark - Protocol CvVideoCameraDelegate
- (void)processImage:(cv::Mat &)image {
    // Do some OpenCV stuff with the image
    
    //摄像头的帧率被设置为 30 帧每秒，实现的 processImage 函数将每秒被调用 30 次。
    //因为要持续不断地检测人脸，所以在这个函数里实现人脸的检测。
    //要注意的是，如果对某一帧进行人脸检测的时间超过 1/30 秒，就会产生掉帧现象。
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
    
    //将图片转成灰度图
    cvtColor( img, gray, cv::COLOR_BGR2GRAY );
    
    //压缩图片尺寸，成小图
    resize( gray, smallImg, smallImg.size(), 0, 0, cv::INTER_LINEAR );
    equalizeHist( smallImg, smallImg );
    
    //开启时间计时器
    t = (double)cvGetTickCount();
    
    //决定每次遍历分类器后尺度会变大多少倍
    double scalingFactor = 1.1;
    
    //指定一个符合条件的人脸区域应该有多少个符合条件的邻居像素才被认为是一个可能的人脸区域，
    //拥有少于 minNeighbors 个符合条件的邻居像素的人脸区域会被拒绝掉。
    int minNeighbors = 3;
    
    //设定检测人脸区域范围的最小值
    cv::Size minSize(20,20);
    //设定检测人脸区域范围的最大值
    cv::Size maxSize(180,180);
    
    self->_faceDetector.detectMultiScale(smallImg, self->_faceRects,
                                         scalingFactor, minNeighbors, 0,
                                         minSize,maxSize);
    
    //计时器计算检测所花费的时间
    t = (double)cvGetTickCount() - t;
    // printf( "detection time = %g ms\n", t/((double)cvGetTickFrequency()*1000.) );
    
    std::vector<cv::Mat> faceImages;
    
    for( std::vector<cv::Rect>::const_iterator r = _faceRects.begin(); r != _faceRects.end(); r++, i++ )
    {
        cv::Mat smallImgROI;
        cv::Point center;
        cv::Scalar color = colors[i%8];
        std::vector<cv::Rect> nestedObjects;
        
        //画正方形
        rectangle(img,
                  cvPoint(cvRound(r->x*scale), cvRound(r->y*scale)),
                  cvPoint(cvRound((r->x + r->width-1)*scale), cvRound((r->y + r->height-1)*scale)),
                  color, 1, 8, 0);
        
        //eye detection is pretty low accuracy
        if(self->_eyesDetector.empty())
            continue;
        
        
        smallImgROI = smallImg(*r);
        
        faceImages.push_back(smallImgROI.clone());
        
        
        self->_eyesDetector.detectMultiScale( smallImgROI,
                                             nestedObjects,
                                             1.1, 2, 0,
                                             cv::Size(1, 1) );
        
        for( std::vector<cv::Rect>::const_iterator nr = nestedObjects.begin(); nr != nestedObjects.end(); nr++ )
        {
            center.x = cvRound((r->x + nr->x + nr->width*0.5)*scale);
            center.y = cvRound((r->y + nr->y + nr->height*0.5)*scale);
            int radius = cvRound((nr->width + nr->height)*0.25*scale);
            circle( img, center, radius, color, 1, 8, 0 );
        }
        
    }
    
    
    @synchronized(self) {
        self->_faceImgs = faceImages;
    }
}

- (NSArray *)detectedFaces {
    NSMutableArray *facesArray = [NSMutableArray array];
    for( std::vector<cv::Rect>::const_iterator r = _faceRects.begin(); r != _faceRects.end(); r++ )
    {
        CGRect faceRect = CGRectMake(_scale*r->x/480.,
                                     _scale*r->y/640.,
                                     _scale*r->width/480.,
                                     _scale*r->height/640.);
        [facesArray addObject:[NSValue valueWithCGRect:faceRect]];
    }
    return facesArray;
}

- (UIImage *)faceWithIndex:(NSInteger)idx {
    
    cv::Mat img = self->_faceImgs[idx];
    
    UIImage *ret = [UIImage imageFromCVMat:img];
    
    return ret;
}


@end
