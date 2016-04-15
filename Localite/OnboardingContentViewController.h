//
//  OboardingContentViewController.h
//  Localite
//
//  Created by Jedd Goble on 4/15/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardingContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *onboardingImageView;

@property NSUInteger pageIndex;
@property NSString *imageFile;


@end
