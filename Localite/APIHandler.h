//
//  APIHandler.h
//  Localite
//
//  Created by Jedd Goble on 10/15/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@protocol APIHandlerProtocol <NSObject>

- (void) addImageToArray:(Photo *)photo;

- (void) startSpinner;

- (void) stopSpinner;

@end

@interface APIHandler : NSObject

@property (strong, nonatomic) id <APIHandlerProtocol> delegate;

- (void) getPhotosWithLocation:(double)latitude andLon:(double)longitude andSpan:(double)span;

- (void) getPhotosWithKeyword:(NSString *)keyword hashtagOrUser:(BOOL)hashtag;

- (void) getPhotosWithUsername:(NSString *)username;

@end
