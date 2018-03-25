//
//  HVFaceRecognizerUtil.h
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/24.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HVFaceRecognizerUtil : NSObject

+ (HVFaceRecognizerUtil *)faceRecWithFile:(NSString *)path;

- (BOOL)writeFaceRecParamatersToFile:(NSString *)path;

- (NSString *)predict:(UIImage *)image confidence:(double *)confidence;

- (void)updateFace:(UIImage *)faceImg name:(NSString *)name;

- (NSArray *)labels;

@end
