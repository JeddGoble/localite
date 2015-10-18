//
//  CustomCollectionViewCell.m
//  Localite
//
//  Created by Jedd Goble on 10/17/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@implementation CustomCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:singleTap];
        
    }
    
    return self;

}



- (void) cellTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint tapLocation = [recognizer locationInView:[recognizer.view superview]];
    
    [self.delegate cellTapped:tapLocation];
    
    NSLog(@"Cell tapped");
    
}

@end
