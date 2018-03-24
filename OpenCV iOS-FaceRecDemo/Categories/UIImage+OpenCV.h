//
//  UIImage+OpenCV.h
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/25.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import <UIKit/UIKit.h>

@interface UIImage (OpenCV)

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)imageFromCVMat:(cv::Mat)cvMat;

@end
