//
//  CustomFlowLayout.m
//  Localite
//
//  Created by Jedd Goble on 10/15/15.
//  Copyright © 2015 Mobile Makers. All rights reserved.
//

#import "CustomFlowLayout.h"

@implementation CustomFlowLayout


- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *rectArray = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *attr in rectArray) {
        if (attr.representedElementKind == nil) {
            NSIndexPath *indexPath = attr.indexPath;
            attr.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
        }
    }
    
    return rectArray;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (indexPath.item == 0 || indexPath.item == 1) {
        
        return attr;
    }
    
    NSIndexPath *indexPathPrev = [NSIndexPath indexPathForItem:indexPath.item - 2 inSection:indexPath.section];
    
    CGRect fPrev = [self layoutAttributesForItemAtIndexPath:indexPathPrev].frame;
    CGFloat rightPrev = fPrev.origin.y + fPrev.size.height + 2;
    
    if (attr.frame.origin.y <= rightPrev) {
        return attr;
    }
    
    CGRect frame = attr.frame;
    frame.origin.y = rightPrev;
    attr.frame = frame;
    
    return attr;
    
}




@end
