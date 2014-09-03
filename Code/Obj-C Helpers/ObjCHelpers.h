//
//  UIImage+Transparency.h
//  TradeGame
//
//  Created by Ryne Cheow on 8/27/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Transparency)

- (instancetype) replaceWhiteinImageWithTransparency;

@end

@interface UIView (roundedCorners)

- (void)roundCornersOnTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius;

@end