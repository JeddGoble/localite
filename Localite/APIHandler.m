//
//  APIHandler.m
//  Localite
//
//  Created by Jedd Goble on 10/15/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import "APIHandler.h"
#import "Photo.h"

@interface APIHandler ()


@end

@implementation APIHandler

static NSString * const accessToken = @"1146404.ab103e5.44f5f336040e470e8e1d28617b05034d";


- (void) getPhotosWithLocation:(double)latitude andLon:(double)longitude andSpan:(double)span {
    
    [self.delegate startSpinner];
    
    double timestamp = [[NSDate date] timeIntervalSince1970];
    NSInteger timestampInt = (int)timestamp;
    
    NSString *stringForURL = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/search?min_timestamp=%ld&max_timestamp=%ld&lat=%f&lng=%f&access_token=%@", (long)timestampInt - 7600, (long)timestampInt, latitude, longitude, accessToken];
    
    NSLog(@"%@", stringForURL);
    
    NSURL *url = [NSURL URLWithString:stringForURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
            
            [self parsePhotoDictionaryWithJSON:jsonDict];
        });
    }];
    
    [task resume];
}

- (void) getPhotosWithUsername:(NSString *)username {
    NSString *stringForURL = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/search?q=%@&access_token=%@", username, accessToken];
    
    NSLog(@"User Search: %@", stringForURL);
    
    NSURL *url = [NSURL URLWithString:stringForURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *usersResults = jsonDict[@"data"];
            NSDictionary *firstUser = [usersResults objectAtIndex:0];
            NSString *userID = firstUser[@"id"];
            [self getPhotosWithKeyword:[NSString stringWithFormat:@"%@", userID] hashtagOrUser:NO];
        });
    }];
    
    [task resume];
    
    
}

- (void) getPhotosWithKeyword:(NSString *)keyword hashtagOrUser:(BOOL)hashtag {
    
    [self.delegate startSpinner];
    
    NSString *stringForURL = [NSString new];
    
    if (hashtag) {
        stringForURL = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?access_token=%@", keyword, accessToken];
    } else {
        stringForURL = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?access_token=%@", keyword, accessToken];
    }

    
    NSLog(@"%@", stringForURL);
    
    
    NSURL *url = [NSURL URLWithString:stringForURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self parsePhotoDictionaryWithJSON:jsonDict];
        });
    }];
    
    [task resume];
}

- (void) parsePhotoDictionaryWithJSON:(NSDictionary *)jsonDict {
    
    NSMutableArray *displays = [NSMutableArray new];
    
    NSArray *photosArray = [[NSArray alloc] initWithArray:jsonDict[@"data"]];
    
    for (NSDictionary *photoData in photosArray) {
        Photo *photo = [Photo new];
        
        NSDictionary *imageSizes = [[NSDictionary alloc] initWithDictionary:photoData[@"images"]];
        NSDictionary *resolutionData = [[NSDictionary alloc] initWithDictionary:imageSizes[@"standard_resolution"]];
        NSString *imageStringForURL = [NSString stringWithFormat:@"%@", resolutionData[@"url"]];
        NSURL *imageURL = [NSURL URLWithString:imageStringForURL];
        photo.imageURL = imageURL;
        photo.photoID = photoData[@"id"];
        
        
        
        if (photoData[@"location"] != [NSNull null]) {
            NSDictionary *locations = [[NSDictionary alloc] initWithDictionary:photoData[@"location"]];
            
            NSString *latitudeString = [NSString stringWithFormat:@"%@", locations[@"latitude"]];
            double lat = [latitudeString doubleValue];
            NSString *longitudeString = [NSString stringWithFormat:@"%@", locations[@"longitude"]];
            double lon = [longitudeString doubleValue];
            photo.coordinates = CLLocationCoordinate2DMake(lat, lon);
        } else {
            photo.coordinates = CLLocationCoordinate2DMake(0.0, 0.0);
        }

        
        [displays addObject:photo];
    }
    
    [self downloadPhotosWithPhotoURLArray:displays];
    
}

- (void) downloadPhotosWithPhotoURLArray:(NSMutableArray *)displays {
    
    for (Photo *photo in displays) {
        NSURLRequest *request = [NSURLRequest requestWithURL:photo.imageURL];
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                      
            photo.image = [UIImage new];
            photo.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photo.imageURL]];
            
            [self.delegate addImageToArray:photo];
            
            [self.delegate stopSpinner];
            
        }];
        
        [task resume];
        
        
    }
    
    
}





@end
