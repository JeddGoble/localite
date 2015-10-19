//
//  Photo.h
//  Localite
//
//  Created by Jedd Goble on 10/15/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>




@interface Photo : NSObject

@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) CLLocationCoordinate2D coordinates;
@property (strong, nonatomic) NSString *photoID;
@property (nonatomic) BOOL inFavorites;

- (UIImage *)imageForScaling:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
