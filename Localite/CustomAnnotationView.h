//
//  CustomAnnotationView.h
//  Localite
//
//  Created by Jedd Goble on 10/18/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Photo;

@interface CustomAnnotationView : MKAnnotationView

@property (strong, nonatomic) Photo *photo;

@end
