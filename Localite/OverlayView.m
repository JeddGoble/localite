//
//  OverlayView.m
//  Localite
//
//  Created by Jedd Goble on 10/18/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import "OverlayView.h"
#import "Photo.h"

@implementation OverlayView

- (instancetype) initWithPhoto:(Photo *)photo andCurrentView:(UIView *)view andText:(NSString *)text {
    
    self = [super init];
    
    self.frame = CGRectMake(0.0, 0.0, view.frame.size.width, view.frame.size.height);
    
    self.backgroundColor = [UIColor clearColor];
    
    float width = view.frame.size.width - 20;
    float aspectRatio = photo.image.size.height / photo.image.size.width;
    float height = width * aspectRatio;
    float originX = 10;
    float originY = (view.center.y - (height / 2)) - 30.0;
    
    
    
    UIView *borderForImage = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
    borderForImage.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    [self addSubview:borderForImage];
    
    UIImageView *fullScreenImage = [[UIImageView alloc] initWithFrame:CGRectMake(originX + 5, originY + 5, width - 10, height - 10)];
    fullScreenImage.image = photo.image;
    [fullScreenImage setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:fullScreenImage];
    
    self.xIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_close"]];
    self.xIcon.frame = CGRectMake(view.frame.size.width - 10 - self.xIcon.frame.size.width, 30, self.xIcon.frame.size.width, self.xIcon.frame.size.height);
    [self addSubview:self.xIcon];
    
    self.addOrRemoveLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + height + 20, width, 50.0)];
    self.addOrRemoveLabel.backgroundColor = borderForImage.backgroundColor;
    self.addOrRemoveLabel.text = text;
    self.addOrRemoveLabel.textColor = [UIColor colorWithRed:155.0 / 255.0 green: 107.0 / 255.0 blue:25.0 / 255.0 alpha:1.0];
    self.addOrRemoveLabel.clipsToBounds = YES;
    self.addOrRemoveLabel.layer.cornerRadius = 25.0;
    self.addOrRemoveLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.addOrRemoveLabel];
    
    UITapGestureRecognizer *screenTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [self addGestureRecognizer:screenTap];
    
    return self;
    
}

- (void) labelTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint tapLocation = [recognizer locationInView:[recognizer.view superview]];
    
    NSLog(@"Label Tapped");
    
    if (CGRectContainsPoint(self.xIcon.frame, tapLocation)) {
        [self.delegate exitButtonTapped];
    } else if (CGRectContainsPoint(self.addOrRemoveLabel.frame, tapLocation)) {
        [self.delegate addOrRemoveTapped];
    }
    

    
}


@end
