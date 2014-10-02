//
//  CHDraggableView+Avatar.h
//  ChatHeads
//
//  Created by Matthias Hochgatterer on 4/19/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import "CHDraggableView.h"

@interface CHDraggableView (Avatar)

+ (instancetype)draggableViewWithImage:(UIImage *)image;
+ (instancetype)draggableViewWithImage:(UIImage *)image size:(CGSize)size;

+ (instancetype)draggableViewWithFillColor:(UIColor *)color;
+ (instancetype)draggableViewWithFillColor:(UIColor *)color size:(CGSize)size;

@end
