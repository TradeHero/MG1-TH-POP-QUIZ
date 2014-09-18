//
//  ObjCHelpers.m
//  TradeGame
//
//  Created by Ryne Cheow on 8/27/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

#import "ObjCHelpers.h"

@implementation UIImage (Helper)

- (instancetype) replaceWhiteinImageWithTransparency {
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bitmapByteCount = bytesPerRow * height;
    
    unsigned char *pixelData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixelData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    uint byteIndex = 0;
    
    while (byteIndex < bitmapByteCount) {
        unsigned char red   = pixelData[byteIndex];
        unsigned char green = pixelData[byteIndex + 1];
        unsigned char blue  = pixelData[byteIndex + 2];
        
        if (((red >= 245) && (red <= 255)) &&
            ((green >= 245) && (green <= 255)) &&
            ((blue >= 245) && (blue <= 255))) {
            // make the pixel transparent
            pixelData[byteIndex] = 0;
            pixelData[byteIndex + 1] = 0;
            pixelData[byteIndex + 2] = 0;
            pixelData[byteIndex + 3] = 0;
        }
        byteIndex += 4;
    }
    
    CGImageRef img = CGBitmapContextCreateImage(context);
    UIImage *result = [UIImage imageWithCGImage:img];
    CGImageRelease(img);
    CGContextRelease(context);
    free(pixelData);
    return result;
}

- (instancetype)centerCropImage
{
    // Use smallest side length as crop square length
    CGFloat squareLength = MIN(self.size.width, self.size.height);
    // Center the crop area
    CGRect clippedRect = CGRectMake((self.size.width - squareLength) / 2, (self.size.height - squareLength) / 2, squareLength, squareLength);
    
    // Crop logic
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], clippedRect);
    UIImage * croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

@end


@implementation UIView (roundedCorners)

+ (void)roundView:(UIView *)view onCorner:(UIRectCorner)rectCorner radius:(float)radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:rectCorner
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    [view.layer setMask:maskLayer];
}

@end


@implementation UITableView (Wave)

- (void)reloadDataAnimateWithWave:(UITableViewCellLoadWaveAnimationDirection)animation;
{
    
    [self setContentOffset:self.contentOffset animated:NO];
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [UIView transitionWithView:self
                      duration:.1f
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^(void) {
                        [self setHidden:YES];
                        [self reloadData];
                    } completion:^(BOOL finished) {
                        if(finished){
                            [self setHidden:NO];
                            [self visibleRowsBeginAnimation:animation];
                        }
                    }
     ];
}


- (void)visibleRowsBeginAnimation:(UITableViewCellLoadWaveAnimationDirection)animation
{
    NSArray *array = [self indexPathsForVisibleRows];
    for (int i=0 ; i < [array count]; i++) {
        NSIndexPath *path = [array objectAtIndex:i];
        UITableViewCell *cell = [self cellForRowAtIndexPath:path];
        cell.frame = [self rectForRowAtIndexPath:path];
        cell.hidden = YES;
        [cell.layer removeAllAnimations];
        NSArray *array = @[path,[NSNumber numberWithInt:animation]];
        [self performSelector:@selector(animationStart:) withObject:array afterDelay:.2*i];
    }
}


- (void)animationStart:(NSArray *)array
{
    NSIndexPath *path = [array objectAtIndex:0];
    float i = [((NSNumber*)[array objectAtIndex:1]) floatValue] ;
    UITableViewCell *cell = [self cellForRowAtIndexPath:path];
    CGPoint originPoint = cell.center;
    CGPoint beginPoint = CGPointMake(cell.frame.size.width * i, originPoint.y);
    CGPoint endBounce1Point = CGPointMake(originPoint.x - i * 2 * kBOUNCE_DISTANCE, originPoint.y);
    CGPoint endBounce2Point  = CGPointMake(originPoint.x + i * kBOUNCE_DISTANCE, originPoint.y);
    cell.hidden = NO ;
    
    CAKeyframeAnimation *move = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    move.keyTimes=@[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.8],[NSNumber numberWithFloat:0.9],[NSNumber numberWithFloat:1.]];
    move.values=@[[NSValue valueWithCGPoint:beginPoint],[NSValue valueWithCGPoint:endBounce1Point],[NSValue valueWithCGPoint:endBounce2Point],[NSValue valueWithCGPoint:originPoint]];
    move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    CABasicAnimation *opaAnimation = [CABasicAnimation animationWithKeyPath: @"opacity"];
    opaAnimation.fromValue = @(0.f);
    opaAnimation.toValue = @(1.f);
    opaAnimation.autoreverses = NO;
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[move,opaAnimation];
    group.duration = kWAVE_DURATION;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    [cell.layer addAnimation:group forKey:nil];
    
}



@end


#define     kFadeSteps  20.0

@implementation AVAudioPlayer (FadeControl)

-(void)fadeOutWithDuration:(NSTimeInterval)inFadeOutTime
{
    NSTimeInterval fireInterval = inFadeOutTime/kFadeSteps;
    float volumeDecrement = 1.0/kFadeSteps;
    float originalVolume = self.volume;
    self.volume = originalVolume - volumeDecrement;
    [NSTimer scheduledTimerWithTimeInterval:fireInterval target:self selector:@selector(fadeOutTimerMethod:) userInfo:[NSNumber numberWithFloat:originalVolume] repeats:YES];
}

- (void)fadeOutTimerMethod:(NSTimer*)theTimer
{
    float volumeDecrement = 1.0/kFadeSteps;
    if (self.volume > volumeDecrement) {
        self.volume = self.volume - volumeDecrement;
    } else if ([theTimer isValid]) {
        [self stop];
        NSNumber* originalVolume = [theTimer userInfo];
        self.volume = [originalVolume floatValue];
        [theTimer invalidate];
    } else {
        [self stop];
    }
}

@end


@implementation JMMarkSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Default configuration
        self.markColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:124/255.0 alpha:0.7];
        self.markPositions = @[@10,@20,@30,@40,@50,@60,@70,@80,@90,@100];
        self.markWidth = 1.0;
        self.selectedBarColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:193/255.0 alpha:0.8];
        self.unselectedBarColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:94/255.0 alpha:0.8];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Default configuration
        self.markColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:124/255.0 alpha:0.7];
        self.markPositions = @[@10,@20,@30,@40,@50,@60,@70,@80,@90,@100];
        self.markWidth = 1.0;
        self.selectedBarColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:193/255.0 alpha:0.8];
        self.unselectedBarColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:94/255.0 alpha:0.8];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // We create an innerRect in which we paint the lines
    CGRect innerRect = CGRectInset(rect, 1.0, 10.0);
    
    UIGraphicsBeginImageContextWithOptions(innerRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Selected side
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 12.0);
    CGContextMoveToPoint(context, 6, CGRectGetHeight(innerRect)/2);
    CGContextAddLineToPoint(context, innerRect.size.width - 10, CGRectGetHeight(innerRect)/2);
    CGContextSetStrokeColorWithColor(context, [self.selectedBarColor CGColor]);
    CGContextStrokePath(context);
    UIImage *selectedSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];
    
    // Unselected side
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 12.0);
    CGContextMoveToPoint(context, 6, CGRectGetHeight(innerRect)/2);
    CGContextAddLineToPoint(context, innerRect.size.width - 10, CGRectGetHeight(innerRect)/2);
    CGContextSetStrokeColorWithColor(context, [self.unselectedBarColor CGColor]);
    CGContextStrokePath(context);
    UIImage *unselectedSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];
    
    // Set trips on selected side
    [selectedSide drawAtPoint:CGPointMake(0,0)];
    for (int i = 0; i < [self.markPositions count]; i++) {
        CGContextSetLineWidth(context, self.markWidth);
        float position = [self.markPositions[i]floatValue] * innerRect.size.width / 100.0;
        CGContextMoveToPoint(context, position, CGRectGetHeight(innerRect)/2 - 5);
        CGContextAddLineToPoint(context, position, CGRectGetHeight(innerRect)/2 + 5);
        CGContextSetStrokeColorWithColor(context, [self.markColor CGColor]);
        CGContextStrokePath(context);
    }
    UIImage *selectedStripSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];
    
    // Set trips on unselected side
    [unselectedSide drawAtPoint:CGPointMake(0,0)];
    for (int i = 0; i < [self.markPositions count]; i++) {
        CGContextSetLineWidth(context, self.markWidth);
        float position = [self.markPositions[i]floatValue] * innerRect.size.width / 100.0;
        CGContextMoveToPoint(context, position, CGRectGetHeight(innerRect)/2 - 5);
        CGContextAddLineToPoint(context, position, CGRectGetHeight(innerRect)/2 + 5);
        CGContextSetStrokeColorWithColor(context, [self.markColor CGColor]);
        CGContextStrokePath(context);
    }
    UIImage *unselectedStripSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];
    
    UIGraphicsEndImageContext();
    
    [self setMinimumTrackImage:selectedStripSide forState:UIControlStateNormal];
    [self setMaximumTrackImage:unselectedStripSide forState:UIControlStateNormal];
    if (self.handlerImage != nil) {
        [self setThumbImage:self.handlerImage forState:UIControlStateNormal];
    } else if (self.handlerColor != nil) {
        [self setThumbImage:[UIImage new] forState:UIControlStateNormal];
        [self setThumbTintColor:self.handlerColor];
    }
}

@end