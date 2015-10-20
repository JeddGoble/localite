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

@end

@implementation LocationHandler

+ (id)getSharedInstance {
    static LocationHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 30; // meters
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)startUpdating {
    NSLog(@"Location updates started");
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
}

- (void) stopUpdating{
    NSLog(@"Location updates stopped");
    [self.locationManager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"Delegate method should be getting called now");
    [self.delegate updateUserLocation:locations.firstObject];
    [self setCurrentLocation:locations.firstObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.delegate failedWithError:error];
}




@end
