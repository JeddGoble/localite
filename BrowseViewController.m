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
#import "GalleryViewController.h"

@interface BrowseViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, APIHandlerProtocol, UISearchBarDelegate, LocationHandlerDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate, CustomCollectionViewCellDelegate, OverlayDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) LocationHandler *locationHandler;
@property (strong, nonatomic) APIHandler *apiHandler;
@property (strong, nonatomic) Photo *photoHandler;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) Photo *currentlyViewingPhoto;
@property (strong, nonatomic) UIImageView *blurredBackground;
@property (strong, nonatomic) OverlayView *overlay;
@property (strong, nonatomic) IBOutlet UISegmentedControl *userHashtagSegControl;

@end

@implementation BrowseViewController

static NSString * const accessToken = @"1146404.ab103e5.44f5f336040e470e8e1d28617b05034d";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:37.0 / 255.0 green:122.0 / 255.0 blue:103.0 / 255.0 alpha:1.0]];
    
    
    if (self.displays == nil) {
        self.displays = [NSMutableArray new];
    }
    
    self.userHashtagSegControl.alpha = 0;
    self.userHashtagSegControl.hidden = YES;
    
    if (self.favorites == nil) {
        self.favorites = [NSMutableArray new];
        
    }

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
        self.userLocation = location;
        [self.apiHandler getPhotosWithLocation:location.coordinate.latitude andLon:location.coordinate.longitude andSpan:0.5];
    } else {
        NSError *error = [NSError new];
        [self failedWithError:error];
    }
    
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


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if (self.userHashtagSegControl.selectedSegmentIndex == 0) {
        [self.apiHandler getPhotosWithKeyword:self.searchBar.text hashtagOrUser:YES];
    } else {
        [self.apiHandler getPhotosWithUsername:self.searchBar.text];
    }
    
    [self.searchBar resignFirstResponder];
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

    for (Photo *photo in self.favorites) {
        if ([photo.photoID isEqual:self.currentlyViewingPhoto.photoID]) {
            self.currentlyViewingPhoto.inFavorites = YES;
        }
    }
    
    UIImage *blurredImage = [self blurBackground:self.view];
    self.blurredBackground = [[UIImageView alloc] initWithImage:blurredImage];
    self.blurredBackground.alpha = 0.0;
    [self.view addSubview:self.blurredBackground];
    
    self.overlay = [[OverlayView alloc] initWithPhoto:self.currentlyViewingPhoto andCurrentView:self.view];
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

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.userHashtagSegControl.alpha = 0.0;
    self.userHashtagSegControl.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.userHashtagSegControl.alpha = 0.9;
    }];
    
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.userHashtagSegControl.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.userHashtagSegControl.hidden = YES;
    }];
    
    [self.searchBar resignFirstResponder];
    
}


- (IBAction)onRefreshButtonPressed:(UIButton *)sender {
    if ([self.searchBar.text isEqual:@""]) {
        [[LocationHandler getSharedInstance] startUpdating];
        
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude);
        double lat = coordinates.latitude;
        double lon = coordinates.longitude;
        
        [self.apiHandler getPhotosWithLocation:lat andLon:lon andSpan:0.5];
        
        [self.searchBar resignFirstResponder];
    } else {
        if (self.userHashtagSegControl.selectedSegmentIndex == 0) {
            [self.apiHandler getPhotosWithKeyword:self.searchBar.text hashtagOrUser:YES];

        } else {
            [self.apiHandler getPhotosWithUsername:self.searchBar.text];;
        }
        

    }
    
    [self.searchBar resignFirstResponder];

}

//Delegate method from API handler

- (void)addImageToArray:(Photo *)photo {
    
    [self.displays insertObject:photo atIndex:0];
    
    [self.collectionView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self saveToFavorites];
}

- (void)failedWithError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not find your location. Try again later." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *bummer = [UIAlertAction actionWithTitle:@"Bummer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:bummer];
    
    [self presentViewController:alertController animated:YES completion:nil];
}





@end
