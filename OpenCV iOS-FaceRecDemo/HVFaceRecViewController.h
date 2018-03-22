//
//  HVFaceRecViewController.h
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/22.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>


@interface HVFaceRecViewController : UIViewController

@property (nonatomic, retain) CvVideoCamera *videoCamera;
@property (weak, nonatomic) IBOutlet UIImageView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *tapBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

- (IBAction)actionStart:(id)sender;
@end
