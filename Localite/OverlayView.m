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

- (instancetype) initWithPhoto:(Photo *)photo andCurrentView:(UIView *)view {
    
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
    
    if (photo.inFavorites) {
        self.addOrRemoveLabel.text = [NSString stringWithFormat:@"Remove From Collection"];
        self.addOrRemoveLabel.textColor = [UIColor redColor];
    } else {
        self.addOrRemoveLabel.text = [NSString stringWithFormat:@"Add To Collection"];
        self.addOrRemoveLabel.textColor = [UIColor colorWithRed:155.0 / 255.0 green: 107.0 / 255.0 blue:25.0 / 255.0 alpha:1.0];
    }
    
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

+ (UIImage *) blurImage:(UIView *)viewToBlur andSnapshop:(CIImage *)inputImage {
    
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
    UIGraphicsBeginImageContext(viewToBlur.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -viewToBlur.frame.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, viewToBlur.frame, cgImage);
    
    // Apply dark tint
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor);
    CGContextFillRect(outputContext, viewToBlur.frame);
    CGContextRestoreGState(outputContext);
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}


@end
