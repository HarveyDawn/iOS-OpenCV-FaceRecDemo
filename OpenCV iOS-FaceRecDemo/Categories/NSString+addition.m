//
//  NSString+addition.m
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/25.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import "NSString+addition.h"

@implementation NSString (addition)

+ (NSString *)documentPath
{
   return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)pathFromFlieName:(NSString *)fileName
{
    return [[NSString documentPath] stringByAppendingPathComponent:fileName];
}

@end
