//
//  UIImage+Transparency.h
//  TradeGame
//
//  Created by Ryne Cheow on 8/27/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

@import UIKit;
@import AVFoundation;

@interface UIImage (Helper)

- (instancetype) replaceWhiteinImageWithTransparency;
- (instancetype) centerCropImage;

@end

@interface UIView (roundedCorners)
+ (void)roundView:(UIView *)view onCorner:(UIRectCorner)rectCorner radius:(float)radius;
//- (void)roundCornersOnTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius;

@end

#define kBOUNCE_DISTANCE  4.f
#define kWAVE_DURATION   .5f

typedef NS_ENUM(NSInteger,UITableViewCellLoadWaveAnimationDirection) {
    UITableViewCellLoadWaveAnimationDirectionLeftToRight = -1,
    UITableViewCellLoadWaveAnimationDirectionRightToLeft = 1
};


@interface UITableView (Wave)

- (void)reloadDataAnimateWithWave:(UITableViewCellLoadWaveAnimationDirection)animation;

@end

@interface AVAudioPlayer (FadeControl)

- (void)fadeOutWithDuration:(NSTimeInterval)inFadeOutTime;

@end


@interface JMMarkSlider : UISlider
@property (nonatomic) UIColor *markColor;
@property (nonatomic) CGFloat markWidth;
@property (nonatomic) NSArray *markPositions;
@property (nonatomic) UIColor *selectedBarColor;
@property (nonatomic) UIColor *unselectedBarColor;
@property (nonatomic) UIImage *handlerImage;
@property (nonatomic) UIColor *handlerColor;
@end