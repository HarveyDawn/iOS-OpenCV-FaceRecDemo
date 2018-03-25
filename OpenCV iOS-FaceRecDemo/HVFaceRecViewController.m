//
//  HVFaceRecViewController.m
//  OpenCV iOS-FaceRecDemo
//
//  Created by Harvey Huang on 2018/3/26.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import "HVFaceRecViewController.h"
#import "HVFaceRecognizerUtil.h"
#import "NSString+addition.h"

@interface HVFaceRecViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *confidenceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inputImageView;

@property (nonatomic, strong) HVFaceRecognizerUtil *faceModel;

@end

@implementation HVFaceRecViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _inputImageView.image = _inputImage;
    
    NSString *modelPath = [self faceModelFilePath];
    self.faceModel = [HVFaceRecognizerUtil faceRecWithFile:modelPath];
    
    
    if (_faceModel.labels.count == 0) {
        [_faceModel updateFace:_inputImage name:@"Person 1"];
    }
    
    double confidence;
    NSString *name = [_faceModel predict:_inputImage confidence:&confidence];
    
    _nameLabel.text = name;
    _confidenceLabel.text = [@(confidence) stringValue];
}

- (NSString *)faceModelFilePath {
    NSString *modelPath = [NSString pathFromFlieName:@"face-model.xml"];
    return modelPath;
}


- (IBAction)didTapCorrect:(id)sender {
    //Positive feedback for the correct prediction
    
    [_faceModel updateFace:_inputImage name:_nameLabel.text];
    [_faceModel writeFaceRecParamatersToFile:[self faceModelFilePath]];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapWrong:(id)sender {
    //Update our face model with the new person
    NSString *name = [@"Person " stringByAppendingFormat:@"%lu", (unsigned long)_faceModel.labels.count];
    [_faceModel updateFace:_inputImage name:name];
    [_faceModel writeFaceRecParamatersToFile:[self faceModelFilePath]];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
