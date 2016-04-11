//
//  TutorialContentViewController.h
//  Localite
//
//  Created by Jedd Goble on 11/11/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic) NSUInteger pageIndex;
@property (strong, nonatomic) NSString *imageFile;

@end
