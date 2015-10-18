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


@interface MapViewController () <MKMapViewDelegate, LocationHandlerDelegate, APIHandlerProtocol, CLLocationManagerDelegate, OverlayDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) APIHandler *apiHandler;
@property (strong, nonatomic) LocationHandler *locationHandler;
@property (strong, nonatomic) UIImage *imageForAnnotation;
@property (strong, nonatomic) UIView *borderForImage;
@property (strong, nonatomic) UIImageView *fullScreenImage;
@property (strong, nonatomic) UILabel *addToGallery;
@property (strong, nonatomic) OverlayView *overlay;
@property (strong, nonatomic) UIImageView *blurredBackground;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[LocationHandler getSharedInstance] setDelegate:self];
    [[LocationHandler getSharedInstance] startUpdating];
    
    self.mapView.delegate = self;
    self.apiHandler = [APIHandler new];
    self.apiHandler.delegate = self;
    
    self.mapView.showsUserLocation = YES;
    
    
}

- (void)updateUserLocation:(CLLocation *)location {
    
    double span;
    
    if (self.mapView.region.span.longitudeDelta > 1.0) {
        span = 0.01;
    } else {
        span = self.mapView.region.span.longitudeDelta;
    }
    
    
    CLLocationCoordinate2D userLocation = [location coordinate];
    
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = span;
    coordinateSpan.longitudeDelta = span;
    
    MKCoordinateRegion region;
    region.center = userLocation;
    region.span = coordinateSpan;
    
    if (self.displays == nil) {
        self.displays = [[NSMutableArray alloc] init];
    }

    
    [self.apiHandler getPhotosWithLocation:userLocation.latitude andLon:userLocation.longitude andSpan:0.1];
    
    
    [self.mapView setRegion:region animated:YES];
    
    [[LocationHandler getSharedInstance] stopUpdating];
    
    
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
    
    self.overlay = [[OverlayView alloc] initWithPhoto:view.photo andCurrentView:self.view andText:@"Add To Collection"];
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
    
    // Apply Affine-Clamp filter to stretch the image so that it does not
    // look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Apply gaussian blur filter with radius of 30
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@20 forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, self.view.frame, cgImage);
    
    // Apply dark tint
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor);
    CGContextFillRect(outputContext, self.view.frame);
    CGContextRestoreGState(outputContext);
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}




- (void)failedWithError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not find your location. Try again later." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *bummer = [UIAlertAction actionWithTitle:@"Bummer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:bummer];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
