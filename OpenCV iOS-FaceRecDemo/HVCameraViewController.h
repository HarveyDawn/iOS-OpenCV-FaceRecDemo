//
//  HVCameraViewController.h
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/22.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HVCameraViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *tapBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

- (IBAction)actionStart:(id)sender;
@end
