//
//  Photo.m
//  Localite
//
//  Created by Jedd Goble on 10/15/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import "Photo.h"
#import "APIHandler.h"

@interface Photo () <NSCoding>

@property (strong, nonatomic) Photo *currentlyViewingPhoto;

@end


@implementation Photo

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.imageURL forKey:@"kImageURL"];
    [aCoder encodeObject:self.image forKey:@"kImage"];
    [aCoder encodeDouble:self.coordinates.latitude forKey:@"kCoordinatesLatitude"];
    [aCoder encodeDouble:self.coordinates.longitude forKey:@"kCoordinatesLongitude"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSURL *imageURL = [aDecoder decodeObjectForKey:@"kImageURL"];
    UIImage *image = [aDecoder decodeObjectForKey:@"kImage"];
    double latitude = [aDecoder decodeDoubleForKey:@"kCoordinatesLatitude"];
    double longitude = [aDecoder decodeDoubleForKey:@"kCoordinatesLongitude"];
    
    return [self initWithURL:imageURL andImage:image andLat:latitude andLon:longitude];
}


- (Photo *) initWithURL:(NSURL *)imageURL andImage:(UIImage *)image andLat:(double)latitude andLon:(double)longitude {
    
    self = [super init];
    
    self.imageURL = imageURL;
    self.image = image;
    self.coordinates = CLLocationCoordinate2DMake(latitude, longitude);
    
    return self;
    
}



- (UIImage *)imageForScaling:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

@end
