//
//  GalleryViewController.m
//  Localite
//
//  Created by Jedd Goble on 10/15/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import "GalleryViewController.h"
#import "CustomCollectionViewCell.h"
#import "Photo.h"
#import "OverlayView.h"


@interface GalleryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CustomCollectionViewCellDelegate, OverlayDelegate>

@property (strong, nonatomic) NSMutableArray *favorites;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) Photo *currentlyViewingPhoto;
@property (strong, nonatomic) UIView *borderForImage;
@property (strong, nonatomic) UIImageView *fullScreenImage;
@property (strong, nonatomic) UILabel *removeFromGallery;
@property (strong, nonatomic) UIImageView *blurredBackground;
@property (strong, nonatomic) OverlayView *overlay;

@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFavorites];
    
}



- (void)cellTapped:(CGPoint)tapLocation {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    
    self.currentlyViewingPhoto = [self.favorites objectAtIndex:indexPath.item];
    
    UIImage *blurredImage = [self blurBackground:self.view];
    self.blurredBackground = [[UIImageView alloc] initWithImage:blurredImage];
    self.blurredBackground.alpha = 0.0;
    [self.view addSubview:self.blurredBackground];
    
    self.overlay = [[OverlayView alloc] initWithPhoto:self.currentlyViewingPhoto andCurrentView:self.view andText:@"Remove From Collection"];
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
    [self.favorites removeObjectIdenticalTo:self.currentlyViewingPhoto];
    
    [self saveToFavorites];
    
    [self.collectionView reloadData];
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


- (void) removeFromFavorites {
    [self.favorites removeObjectIdenticalTo:self.currentlyViewingPhoto];
    [self.collectionView reloadData];
    [self saveToFavorites];
}

- (void) saveToFavorites {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedFavorites = [NSKeyedArchiver archivedDataWithRootObject:self.favorites];
    [userDefaults setObject:encodedFavorites forKey:@"Favorites"];
    [userDefaults synchronize];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.favorites.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FavoritePhotoCellID" forIndexPath:indexPath];
    
    Photo *photoData = [self.favorites objectAtIndex:indexPath.row];
    UIImage *image = photoData.image;
    
    CGFloat width = (self.view.frame.size.width / 3) - 3;
    double aspectRatio = image.size.height / image.size.width;
    CGFloat height = aspectRatio * width;
    UIImage *resizedImage = [photoData imageForScaling:image scaledToSize:CGSizeMake(width, height)];

    cell.backgroundColor = [UIColor colorWithPatternImage:resizedImage];
    
    cell.delegate = self;
    
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Photo *photoData = [self.favorites objectAtIndex:indexPath.row];
    UIImage *imageForCell = photoData.image;
    
    CGFloat width = (self.view.frame.size.width / 3) - 3;
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


- (NSURL *) documentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

- (void) loadFavorites {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedFavorites = [userDefaults objectForKey:@"Favorites"];
    self.favorites = [NSKeyedUnarchiver unarchiveObjectWithData:encodedFavorites];
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    UIEdgeInsets inset = UIEdgeInsetsMake(2, 2, 2, 2);
    
    return inset;
    
}


@end
