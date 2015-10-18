//
//  CustomPointAnnotation.h
//  Localite
//
//  Created by Jedd Goble on 10/16/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Photo;

@interface CustomPointAnnotation : MKPointAnnotation

@property (strong, nonatomic) Photo *photo;

@end
