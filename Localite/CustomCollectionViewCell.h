//
//  CustomCollectionViewCell.h
//  Localite
//
//  Created by Jedd Goble on 10/17/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomCollectionViewCellDelegate <NSObject>

- (void) cellTapped:(CGPoint)tapLocation;

@end


@interface CustomCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) id <CustomCollectionViewCellDelegate> delegate;

@end
