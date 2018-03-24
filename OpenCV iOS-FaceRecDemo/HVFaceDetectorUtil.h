//
//  HVFaceDetectorUtil.h
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/23.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import <opencv2/videoio/cap_ios.h>
#import <Foundation/Foundation.h>

@interface HVFaceDetectorUtil : NSObject

- (instancetype)initWithParentView:(UIImageView *)parentView scale:(CGFloat)scale;

- (void)startCapture;
- (void)stopCapture;

- (NSArray *)detectedFaces;
- (UIImage *)faceWithIndex:(NSInteger)idx;

@end
