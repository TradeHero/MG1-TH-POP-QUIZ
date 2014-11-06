//
//  UIImage+Transparency.h
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/27/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

@import UIKit;
@import AVFoundation;
@import AudioToolbox;

@interface UIImage (Helper)

- (instancetype)replaceWhiteinImageWithTransparency;

@end

#define kBOUNCE_DISTANCE  4.f
#define kWAVE_DURATION   .5f

typedef NS_ENUM(NSInteger, UITableViewCellLoadWaveAnimationDirection
) {
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
@property(nonatomic) UIColor *markColor;
@property(nonatomic) CGFloat markWidth;
@property(nonatomic) NSArray *markPositions;
@property(nonatomic) UIColor *selectedBarColor;
@property(nonatomic) UIColor *unselectedBarColor;
@property(nonatomic) UIImage *handlerImage;
@property(nonatomic) UIColor *handlerColor;
@end

void playSound(NSString *path);