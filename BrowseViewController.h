//
//  BrowseViewController.h
//  Localite
//
//  Created by Jedd Goble on 10/15/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLLocation;

@interface BrowseViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *displays;
@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) NSMutableArray *favorites;

@end
