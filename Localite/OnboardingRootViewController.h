//
//  OnboardingRootViewController.h
//  Localite
//
//  Created by Jedd Goble on 4/15/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardingRootViewController : UIViewController <UIPageViewControllerDataSource>

- (IBAction)onConnectInstagramButtonTapped:(UIButton *)sender;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImages;


@end
