//
//  LocationHandler.m
//  SushiHunter
//
//  Created by Jedd Goble on 10/14/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import "LocationHandler.h"
#import <MapKit/MapKit.h>

static LocationHandler *DefaultManager = nil;

@interface LocationHandler ()

- (void) initiate;

@end

@implementation LocationHandler

+ (id)getSharedInstance {
    if (!DefaultManager) {
        DefaultManager = [[self allocWithZone:NULL] init];
        [DefaultManager initiate];
    }
    return DefaultManager;
}

- (void)initiate{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
}

- (void)startUpdating{
    locationManager.delegate = self;
    
    [locationManager startUpdatingLocation];
}

- (void) stopUpdating{
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:
(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.delegate failedWithError:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.delegate updateUserLocation:locations.firstObject];
    
    
    
    
//    [locationManager stopUpdatingLocation];
}




@end
