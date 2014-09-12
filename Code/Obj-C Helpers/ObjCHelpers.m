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
//
//-(void)roundCornersOnTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius {
//    
//    if (tl || tr || bl || br) {
//        
//        UIRectCorner corner; //holds the corner
//        //Determine which corner(s) should be changed
//        if (tl) {
//            corner = UIRectCornerTopLeft;
//        }
//        if (tr) {
//            UIRectCorner add = corner | UIRectCornerTopRight;
//            corner = add;
//        }
//        if (bl) {
//            UIRectCorner add = corner | UIRectCornerBottomLeft;
//            corner = add;
//        }
//        if (br) {
//            UIRectCorner add = corner | UIRectCornerBottomRight;
//            corner = add;
//        }
//        
//        UIView *v = self;
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:v.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
//        CAShapeLayer *maskLayer = [CAShapeLayer layer];
//        maskLayer.frame = v.bounds;
//        maskLayer.path = maskPath.CGPath;
//        v.layer.mask = maskLayer;
//    } else {
//    }
//}

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


@implementation NSDateFormatter (RFC822)

+ (instancetype)rfc822Formatter {
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:enUS];
        [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    }
    return formatter;
}


@end

@implementation NSDate (RFC822)

+ (instancetype)dateFromRFC822:(NSString *)date {
    return [[NSDateFormatter rfc822Formatter] dateFromString:date];
}

@end