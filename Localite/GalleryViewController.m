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

@interface GalleryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CustomCollectionViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *favorites;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) Photo *currentlyViewingPhoto;
@property (strong, nonatomic) UIView *borderForImage;
@property (strong, nonatomic) UIImageView *fullScreenImage;
@property (strong, nonatomic) UILabel *removeFromGallery;

@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFavorites];
    
}


- (void) cellTapped:(CGPoint)tapLocation {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    
    CustomCollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
    self.currentlyViewingPhoto = [Photo new];
    self.currentlyViewingPhoto = [self.favorites objectAtIndex:indexPath.item];
    
    self.borderForImage = [[UIView alloc] initWithFrame:selectedCell.frame];
    self.borderForImage.hidden = NO;
    self.borderForImage.backgroundColor = [UIColor colorWithRed:103.0 / 255.0 green:171.0 / 255.0 blue:156.0 / 255.0 alpha:0.6];
    [self.view addSubview:self.borderForImage];
    
    self.fullScreenImage = [[UIImageView alloc] initWithFrame:selectedCell.frame];
    self.fullScreenImage.hidden = NO;
    self.fullScreenImage.image = self.currentlyViewingPhoto.image;
    
    [self.fullScreenImage setClipsToBounds:YES];
    [self.fullScreenImage setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.view addSubview:self.fullScreenImage];
    
    float width = self.view.frame.size.width - 40;
    float aspectRatio = self.fullScreenImage.frame.size.height / self.fullScreenImage.frame.size.width;
    float height = width * aspectRatio;
    float originX = self.view.center.x - (width / 2);
    float originY = self.view.center.y - (height / 2);
    
    self.removeFromGallery = [[UILabel alloc] initWithFrame:CGRectMake(originX - 10, self.view.frame.size.height + 60.0, width + 20, 50.0)];
    self.removeFromGallery.backgroundColor = self.borderForImage.backgroundColor;
    self.removeFromGallery.text = @"Remove From Gallery";
    self.removeFromGallery.textColor = [UIColor redColor ];
    self.removeFromGallery.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.removeFromGallery];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageTapped:)];
    
    [self.view addGestureRecognizer:singleTap];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.currentlyViewingPhoto.image = [self.currentlyViewingPhoto imageForScaling:self.currentlyViewingPhoto.image scaledToSize:CGSizeMake(width, height)];
        self.removeFromGallery.frame = CGRectMake(originX - 10, originY + height + 15.0, width + 20, 50.0);
        self.fullScreenImage.frame = CGRectMake(originX, originY, width, height);
        self.borderForImage.frame = CGRectMake(originX - 10, originY - 10, width + 20, height + 20);
    } completion:nil];
    
    
    
}


- (void) fullScreenImageTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint tapLocation = [recognizer locationInView:[recognizer.view superview]];
    
    if (CGRectContainsPoint(self.fullScreenImage.frame, tapLocation)) {
        NSLog(@"User tapped image");
    } else if (CGRectContainsPoint(self.removeFromGallery.frame, tapLocation)){
        NSLog(@"User tapped remove button");
        [self removeFromFavorites];
    } else {
        [UIView animateWithDuration:0.2 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.fullScreenImage.frame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2, 0.0, 0.0);
            self.fullScreenImage.alpha = 0.0;
            self.borderForImage.frame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2, 0.0, 0.0);
            self.borderForImage.alpha = 0.0;
            self.removeFromGallery.frame = CGRectMake(self.removeFromGallery.frame.origin.x, self.removeFromGallery.frame.origin.y + 200, self.removeFromGallery.frame.size.width, 50.0);
            
        } completion:^(BOOL finished) {
            self.fullScreenImage.hidden = YES;
            self.borderForImage.hidden = YES;
            [self.fullScreenImage removeFromSuperview];
            [self.borderForImage removeFromSuperview];
        }];
        
        
    }
    
    
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
