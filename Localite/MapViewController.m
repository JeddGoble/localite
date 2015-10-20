//
//  SecondViewController.m
//  Localite
//
//  Created by Jedd Goble on 10/15/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationHandler.h"
#import "Photo.h"
#import "APIHandler.h"
#import "CustomPointAnnotation.h"
#import "CustomAnnotationView.h"
#import <CoreImage/CoreImage.h>
#import "OverlayView.h"


@interface MapViewController () <MKMapViewDelegate, LocationHandlerDelegate, APIHandlerProtocol, CLLocationManagerDelegate, OverlayDelegate, UITabBarControllerDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) APIHandler *apiHandler;
@property (strong, nonatomic) UIImage *imageForAnnotation;
@property (strong, nonatomic) UIView *borderForImage;
@property (strong, nonatomic) UIImageView *fullScreenImage;
@property (strong, nonatomic) OverlayView *overlay;
@property (strong, nonatomic) UIImageView *blurredBackground;
@property (strong, nonatomic) Photo *currentlyViewingPhoto;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self loadFavorites];
    
    [[LocationHandler getSharedInstance] startUpdating];
    [[LocationHandler getSharedInstance] setDelegate:self];
    
    self.apiHandler = [APIHandler new];
    self.apiHandler.delegate = self;

}

- (void)updateUserLocation:(CLLocation *)location {
    if (location.coordinate.latitude != 0.0) {
        [self.apiHandler getPhotosWithLocation:location.coordinate.latitude andLon:location.coordinate.longitude andSpan:0.5];
    } else {
        NSError *error = [NSError new];
        [self failedWithError:error];
    }
}



- (void) loadFavorites {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedFavorites = [userDefaults objectForKey:@"Favorites"];
    self.favorites = [NSKeyedUnarchiver unarchiveObjectWithData:encodedFavorites];
    
}

- (void)startSpinner {
    [self.spinner startAnimating];
}

- (void)stopSpinner {
    [self.spinner stopAnimating];
}

- (void)addImageToArray:(Photo *)photo {
    
    [self.displays addObject:photo];
    
    [self addPinToMap:photo];
    
}

- (void) addPinToMap:(Photo *)photo {
    CustomPointAnnotation *annotation = [CustomPointAnnotation new];
    
    annotation.coordinate = photo.coordinates;

    annotation.photo = photo;
    
    
    [self.mapView addAnnotation:annotation];
}

- (CustomAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(CustomPointAnnotation *)annotation {
    
    
    CustomAnnotationView *pin = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    
    if ([annotation isEqual:mapView.userLocation]) {
        return nil;
    }
    
    pin.photo = annotation.photo;
    
    pin.image = [annotation.photo imageForScaling:annotation.photo.image scaledToSize:CGSizeMake(40.0, 40.0)];

    
    return pin;
    
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(CustomAnnotationView *)view {
    
    UIImage *blurredImage = [self blurBackground:self.view];
    self.blurredBackground = [[UIImageView alloc] initWithImage:blurredImage];
    self.blurredBackground.alpha = 0.0;
    [self.view addSubview:self.blurredBackground];
    
    self.currentlyViewingPhoto = [Photo new];
    self.currentlyViewingPhoto = view.photo;
    
    self.overlay = [[OverlayView alloc] initWithPhoto:view.photo andCurrentView:self.view];
    self.overlay.delegate = self;
//    
//    self.overlay.frame = CGRectMake(0.0, 0.0, self.overlay.frame.size.width, self.overlay.frame.size.height);
    
    self.overlay.alpha = 0.0;
    [self.view addSubview:self.overlay];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.blurredBackground.alpha = 1.0;
        self.overlay.alpha = 1.0;
//        self.overlay.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.width);
    } completion:nil];
    
}

- (void)addOrRemoveTapped {
    if (self.currentlyViewingPhoto.inFavorites) {
        [self.favorites removeObjectIdenticalTo:self.currentlyViewingPhoto];
        self.currentlyViewingPhoto.inFavorites = NO;
        self.overlay.addOrRemoveLabel.text = [NSString stringWithFormat:@"Add To Collection"];
        self.overlay.addOrRemoveLabel.textColor = [UIColor colorWithRed:155.0 / 255.0 green: 107.0 / 255.0 blue:25.0 / 255.0 alpha:1.0];
    } else {
        [self.favorites addObject:self.currentlyViewingPhoto];
        self.currentlyViewingPhoto.inFavorites = YES;
        self.overlay.addOrRemoveLabel.text = [NSString stringWithFormat:@"Remove From Collection"];
        self.overlay.addOrRemoveLabel.textColor = [UIColor redColor];
    }
    
    [self saveToFavorites];
    
}

- (void) saveToFavorites {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedFavorites = [NSKeyedArchiver archivedDataWithRootObject:self.favorites];
    [userDefaults setObject:encodedFavorites forKey:@"Favorites"];
    [userDefaults synchronize];
    
}

- (void)exitButtonTapped {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.overlay.alpha = 0.0;
        self.blurredBackground.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.overlay removeFromSuperview];
        [self.blurredBackground removeFromSuperview];
    }];
}




- (UIImage *)blurBackground:(UIView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    CIImage *inputImage = [CIImage imageWithCGImage:snapshot.CGImage];
    
    UIImage *blurredBackground = [OverlayView blurImage:self.view andSnapshop:inputImage];
    
    return blurredBackground;
}

- (IBAction)onRefreshButtonTapped:(UIButton *)sender {
    
    [[LocationHandler getSharedInstance] startUpdating];
    
}

- (IBAction)onTargetButtonTapped:(UIButton *)sender {
    if (self.mapView.userLocation.coordinate.latitude != 0.0) {
        
        double span;
        
        if (self.mapView.region.span.longitudeDelta > 0.5) {
            span = 0.01;
        } else {
            span = self.mapView.region.span.longitudeDelta;
        }
        
        MKCoordinateSpan coordinateSpan;
        coordinateSpan.latitudeDelta = span;
        coordinateSpan.longitudeDelta = span;
        
        MKCoordinateRegion region;
        region.center = self.mapView.userLocation.coordinate;
        region.span = coordinateSpan;
        
        [self.mapView setRegion:region animated:YES];
    } else {
        NSError *error = [NSError new];
        [self failedWithError:error];
    }
    
}


- (void)failedWithError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not find your location. Try again later." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *bummer = [UIAlertAction actionWithTitle:@"Bummer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:bummer];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
