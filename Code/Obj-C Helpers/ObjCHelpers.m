//
//  ObjCHelpers.m
//  TradeGame
//
//  Created by Ryne Cheow on 8/27/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

#import "ObjCHelpers.h"

@implementation UIImage (Transparency)

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

@end


@implementation UIView (roundedCorners)

-(void)roundCornersOnTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius {
    
    if (tl || tr || bl || br) {
        
        UIRectCorner corner; //holds the corner
        //Determine which corner(s) should be changed
        if (tl) {
            corner = UIRectCornerTopLeft;
        }
        if (tr) {
            UIRectCorner add = corner | UIRectCornerTopRight;
            corner = add;
        }
        if (bl) {
            UIRectCorner add = corner | UIRectCornerBottomLeft;
            corner = add;
        }
        if (br) {
            UIRectCorner add = corner | UIRectCornerBottomRight;
            corner = add;
        }
        
        UIView *v = self;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:v.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = v.bounds;
        maskLayer.path = maskPath.CGPath;
        v.layer.mask = maskLayer;
    } else {
    }
}

@end