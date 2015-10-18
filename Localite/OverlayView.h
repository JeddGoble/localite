//
//  OverlayView.h
//  Localite
//
//  Created by Jedd Goble on 10/18/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Photo;

@protocol OverlayDelegate <NSObject>

- (void) addOrRemoveTapped;
- (void) exitButtonTapped;

@end

@interface OverlayView : UIView

@property (strong, nonatomic) UIImageView *xIcon;
@property (strong, nonatomic) UILabel *addOrRemoveLabel;

@property (nonatomic, assign) id <OverlayDelegate> delegate;

- (instancetype) initWithPhoto:(Photo *)photo andCurrentView:(UIView *)view andText:(NSString *)text;

@end
