//
//  BrowseCollectionViewController.m
//  Localite
//
//  Created by Jedd Goble on 10/15/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import "BrowseViewController.h"
#import "Photo.h"
#import "APIHandler.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationHandler.h"
#import "MapViewController.h"
#import "CustomCollectionViewCell.h"
#import "OverlayView.h"

@interface BrowseViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, APIHandlerProtocol, UISearchBarDelegate, LocationHandlerDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate, CustomCollectionViewCellDelegate, OverlayDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *displays;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) APIHandler *apiHandler;
@property (strong, nonatomic) Photo *photoHandler;
@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSMutableArray *favorites;
@property (strong, nonatomic) Photo *currentlyViewingPhoto;
@property (nonatomic) BOOL isFullscreen;
@property (strong, nonatomic) UIImageView *blurredBackground;
@property (strong, nonatomic) OverlayView *overlay;

@end

@implementation BrowseViewController

static NSString * const accessToken = @"1146404.ab103e5.44f5f336040e470e8e1d28617b05034d";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFavorites];
    
    if (self.favorites == nil) {
        self.favorites = [NSMutableArray new];
        
    }
    
    self.isFullscreen = NO;
    
    
    [[LocationHandler getSharedInstance] setDelegate:self];
    [[LocationHandler getSharedInstance] startUpdating];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    
//    [self.collectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCellID"];
    
    if (self.displays == nil) {
        self.displays = [NSMutableArray new];
    }
    
//    for (int i = 1; i < 7; i++) {
//        NSString *photoName = [NSString stringWithFormat:@"photo%i", i];
//        UIImage *image = [UIImage imageNamed:photoName];
//        
//        Photo *photo = [Photo new];
//        photo.image = image;
//        
//        [self.displays addObject:photo];
//    }
    
    self.apiHandler = [APIHandler new];
    self.apiHandler.delegate = self;
    
    double lat = 37.7833;
    double lon = -122.4167;
    
    double span = 1.0;
    
    [self.apiHandler getPhotosWithLocation:lat andLon:lon andSpan:span];
    
}

- (NSURL *) documentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

- (void) loadFavorites {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedFavorites = [userDefaults objectForKey:@"Favorites"];
    self.favorites = [NSKeyedUnarchiver unarchiveObjectWithData:encodedFavorites];
    
}

- (void) saveToFavorites {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedFavorites = [NSKeyedArchiver archivedDataWithRootObject:self.favorites];
    [userDefaults setObject:encodedFavorites forKey:@"Favorites"];
    [userDefaults synchronize];
    
}


- (void)updateUserLocation:(CLLocation *)location {
    self.userLocation = location;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.userLocation = locations.firstObject;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    MapViewController *tempVC = viewController;
    tempVC.displays = self.displays;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.apiHandler getPhotosWithKeyword:self.searchBar.text];
    
    [self.collectionView reloadData];
}


- (void)startSpinner {
    [self.spinner startAnimating];
}

- (void)stopSpinner {
    [self.spinner stopAnimating];
}

- (void)cellTapped:(CGPoint)tapLocation {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    
    self.currentlyViewingPhoto = [self.displays objectAtIndex:indexPath.item];
    
    UIImage *blurredImage = [self blurBackground:self.view];
    self.blurredBackground = [[UIImageView alloc] initWithImage:blurredImage];
    self.blurredBackground.alpha = 0.0;
    [self.view addSubview:self.blurredBackground];
    
    self.overlay = [[OverlayView alloc] initWithPhoto:self.currentlyViewingPhoto andCurrentView:self.view andText:@"Add To Collection"];
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
    [self.favorites insertObject:self.currentlyViewingPhoto atIndex:0];
    
    [self saveToFavorites];
}

- (void)exitButtonTapped {
    [self.overlay removeFromSuperview];
    
    [self.blurredBackground removeFromSuperview];
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



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.displays.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCellID" forIndexPath:indexPath];
    
    Photo *photoData = [self.displays objectAtIndex:indexPath.item];
    UIImage *image = photoData.image;
    
    CGFloat width = (self.view.frame.size.width / 2) - 3;
    double aspectRatio = image.size.height / image.size.width;
    CGFloat height = aspectRatio * width;
    UIImage *resizedImage = [photoData imageForScaling:image scaledToSize:CGSizeMake(width, height)];
    
    cell.backgroundColor = [UIColor colorWithPatternImage:resizedImage];
    
    cell.delegate = self;
    
    
    return cell;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Photo *photoData = [self.displays objectAtIndex:indexPath.row];
    UIImage *imageForCell = photoData.image;
    
    CGFloat width = (self.view.frame.size.width / 2) - 3;
    double aspectRatio = imageForCell.size.height / imageForCell.size.width;
    CGFloat height = aspectRatio * width;
    
    CGSize imageSize = CGSizeMake(width, height);
    
    return imageSize;
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 2;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    UIEdgeInsets inset = UIEdgeInsetsMake(2, 2, 2, 2);
    
    return inset;
    
}
- (IBAction)onRefreshButtonPressed:(UIButton *)sender {
    if ([self.searchBar.text isEqual:@""]) {
        [[LocationHandler getSharedInstance] startUpdating];
        
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude);
        double lat = coordinates.latitude;
        double lon = coordinates.longitude;
        
        [self.apiHandler getPhotosWithLocation:lat andLon:lon andSpan:0.5];
        
        [[LocationHandler getSharedInstance] stopUpdating];
    } else {
        [self.apiHandler getPhotosWithKeyword:self.searchBar.text];
    }

}

//Delegate method from API handler

- (void)addImageToArray:(Photo *)photo {
    
    [self.displays insertObject:photo atIndex:0];
    
    [self.collectionView reloadData];
    
}

- (void)failedWithError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not find your location. Try again later." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *bummer = [UIAlertAction actionWithTitle:@"Bummer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:bummer];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

@end
