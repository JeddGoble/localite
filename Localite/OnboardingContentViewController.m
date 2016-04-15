//
//  OboardingContentViewController.m
//  Localite
//
//  Created by Jedd Goble on 4/15/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

#import "OnboardingContentViewController.h"

@interface OnboardingContentViewController ()

@end

@implementation OnboardingContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.onboardingImageView.image = [UIImage imageNamed:self.imageFile];
    
    
    
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

@end
