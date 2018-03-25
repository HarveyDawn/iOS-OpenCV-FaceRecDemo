//
//  HVFaceRecognizerUtil.m
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/24.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/face.hpp>
#endif

#import "HVFaceRecognizerUtil.h"
#import "NSString+addition.h"
#import "UIImage+OpenCV.h"

using namespace cv;
using namespace face;

@interface HVFaceRecognizerUtil()
{
    Ptr< LBPHFaceRecognizer> _faceRecognizer;
}

@property (nonatomic,copy) NSMutableDictionary *labelsDic;

@end

@implementation HVFaceRecognizerUtil

+ (HVFaceRecognizerUtil *)faceRecWithFile:(NSString *)path
{
    HVFaceRecognizerUtil *faceRec = [HVFaceRecognizerUtil new];
    
    //3.x:createLBPHFaceRecognizer()-->LBPHFaceRecognizer::create();
    faceRec->_faceRecognizer = LBPHFaceRecognizer::create();
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (path && [fm fileExistsAtPath:path]) {
        
        [faceRec readFaceRecParamatersFromFile:path];
        
    }else
    {
        faceRec.labelsDic = [NSMutableDictionary dictionary];
        NSLog(@"could not load paramaters file: %@", path);
    }
    return faceRec;
}


#pragma mark - FaceRec read/write

- (BOOL)readFaceRecParamatersFromFile:(NSString *)path
{
    self->_faceRecognizer->read(path.UTF8String);
    
    NSDictionary *unarchiverNames = [NSKeyedUnarchiver
                                     unarchiveObjectWithFile:[path stringByAppendingString:@".names"]];
    
    self.labelsDic = [NSMutableDictionary dictionaryWithDictionary:unarchiverNames];
    
    return YES;
}

- (BOOL)writeFaceRecParamatersToFile:(NSString *)path
{
    self->_faceRecognizer->write(path.UTF8String);
    
    [NSKeyedArchiver archiveRootObject:self.labelsDic toFile:[path stringByAppendingString:@".names"]];
    return YES;
}



#pragma mark - FaceRec predict/update

//根据脸部图片的灰度图匹配出对应的标签，通过对应的标签获取人名
- (NSString *)predict:(UIImage *)image confidence:(double *)confidence
{
    //原图转成灰度图
    cv::Mat src = [UIImage cvMatFromUIImage:image];
    int label;
    
    //@param src:样本图像得到一个预测。
    //@param label:给定的图像标记预测的标签。
    //@param confidence:对预测标签的信心(例如距离)。
    self->_faceRecognizer->predict(src, label, *confidence);
    
    //返回标签对应的人名
    return self.labelsDic[@(label)];
}

- (void)updateFace:(UIImage *)faceImg name:(NSString *)name
{
    //原图转成灰度图
    cv::Mat src = [UIImage cvMatFromUIImage:faceImg];
    
    NSSet *keys = [self.labelsDic keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        return [name isEqual:obj];
    }];
    
    NSInteger label;
    
    if (keys.count) {
        label = [[keys anyObject] integerValue];
    }else
    {
        label = self.labelsDic.allKeys.count;
        self.labelsDic[@(label)] = name;
    }
    
    std::vector<Mat> newImages = std::vector<cv::Mat>();;
    std::vector<int> newLabels = std::vector<int>();
    
    newImages.push_back(src);
    newLabels.push_back((int)label);
    
    _faceRecognizer->update(newImages, newImages);
    
    [self labels];
}

- (NSArray *)labels
{
    cv::Mat labels = _faceRecognizer->getLabels();
    if (labels.total() == 0) {
        return @[];
    }
    else {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (MatConstIterator_<int> itr = labels.begin<int>(); itr != labels.end<int>(); ++itr ) {
            int lbl = *itr;
            [mutableArray addObject:@(lbl)];
        }
        return [NSArray arrayWithArray:mutableArray];
    }
}
@end
