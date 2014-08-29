//
//  Extension.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

extension UIProgressView {
    override public func sizeThatFits(size: CGSize) -> CGSize {
        return CGSizeMake(self.frame.size.width, 10)
    }
}

extension UIControl {
    func disable() {
        enabled = false
    }
    
    func enable() {
        enabled = true
    }
}

extension Array
    {
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<self.count
        {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
    
    func randomItem() -> T {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}

extension CGFloat {
    func roundToNearest1DecimalPlace() -> CGFloat {
        return Double(self).format(".1").CGFloatValue
    }
}


extension UIColor {
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let b = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:r, green:g, blue:b, alpha:alpha)
    }
    
    public func lightenColorByValue(value:Float) -> UIColor!{
        let totalComponents = CGColorGetNumberOfComponents(self.CGColor)
        var isGrayscale = totalComponents == 2 ? true : false
        
        var oldComponents = CGColorGetComponents(self.CGColor)
        var newComponents: [CGFloat] = Array(count: 4, repeatedValue: 0.0)
        
        if isGrayscale {
            newComponents[0] = oldComponents[0] - CGFloat(value) < 0.0 ? 0.0 : oldComponents[0] - CGFloat(value)
            newComponents[1] = oldComponents[0] - CGFloat(value) < 0.0 ? 0.0 : oldComponents[0] - CGFloat(value)
            newComponents[2] = oldComponents[0] - CGFloat(value) < 0.0 ? 0.0 : oldComponents[0] - CGFloat(value)
            newComponents[3] = oldComponents[1]
        } else {
            newComponents[0] = oldComponents[0] + CGFloat(value) > 1.0 ? 1.0 : oldComponents[0] + CGFloat(value);
            newComponents[1] = oldComponents[1] + CGFloat(value) > 1.0 ? 1.0 : oldComponents[1] + CGFloat(value);
            newComponents[2] = oldComponents[2] + CGFloat(value) > 1.0 ? 1.0 : oldComponents[2] + CGFloat(value);
            newComponents[3] = oldComponents[3];
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let newColor = CGColorCreate(colorSpace, newComponents)
        
        return UIColor(CGColor:newColor)
    }
    
    convenience init(r:Int, _ g:Int, _ b:Int, _ a:Int) {
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
    }
}
extension UIView {
    func removeAllSubviews(){
        for view in (self.subviews as [UIView]){
            view.removeFromSuperview()
        }
    }

    func listAllSubviews() {
        for view in (self.subviews as [UIView]){
            println("\(object_getClassName(view))")
        }
    }
    
    class func rasterizeView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, UIScreen.mainScreen().scale)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage
    }

    func isSubviewOf(view:UIView) -> Bool {
        for v in view.subviews as [UIView] {
            if v === self {
                return true
            }
        }
        return false
    }

    class func animateWithDuration(duration: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void) {
        self.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: nil)
    }
}


extension UIImage {
    
    class func imageWithImage(image:UIImage, newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func imageWithColor(color:UIColor, size:CGSize) -> UIImage{
        UIGraphicsBeginImageContext(size)
        let path = UIBezierPath(rect: CGRectMake(0, 0, size.width, size.height))
        color.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func transparencyToWhiteMatte() -> UIImage {
        return UIImage(data: UIImageJPEGRepresentation(self, 1))
    }
    
    func mosaicEffectOnImage(tileSize:Int) -> UIImage{
        var originalImage = self
        let imageSize = originalImage.size
        let ctx = createARGBBitmapContext(originalImage.CGImage)
        UIGraphicsBeginImageContext(imageSize)
        let context = UIGraphicsGetCurrentContext()
        originalImage.drawInRect(CGRectMake(0, 0, imageSize.width, imageSize.height))
        
        let tilesPerRow = Int(imageSize.width)/tileSize
        let tilesPerColumn = Int(imageSize.height)/tileSize
        
        for var j = 0 ; j < tilesPerColumn ; j++ {
            for var i = 0 ; i < tilesPerRow ; i++ {
                let xPt = CGFloat(i * tileSize + tileSize/2)
                let yPt = CGFloat(j * tileSize + tileSize/2)
                
                let fillColor = getPixelColorAtLocation(ctx, point: CGPointMake(xPt, yPt), inImage: originalImage.CGImage)
                
                let a = CGRectMake(CGFloat(i * tileSize), CGFloat(j * tileSize), CGFloat(tileSize), CGFloat(tileSize))
                
                CGContextSetFillColorWithColor(context, fillColor.CGColor)
                
                CGContextAddRect(context, a)
                
                let a2 = CGRectMake(CGFloat(i * tileSize), CGFloat(j * tileSize), CGFloat(tileSize), CGFloat(tileSize))
                
                UIImage.imageWithColor(fillColor, size: CGSizeMake(CGFloat(tileSize), CGFloat(tileSize))).drawInRect(a2, blendMode: kCGBlendModeNormal, alpha: 1)
                
            }
        }
        
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        return newImg
    }
    
    
    
    private func createARGBBitmapContext(inImage: CGImageRef) -> CGContext {
        var bitmapByteCount = 0
        var bitmapBytesPerRow = 0
        
        //Get image width, height
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        bitmapBytesPerRow = Int(pixelsWide) * 4
        bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        let bitmapData = malloc(CUnsignedLong(bitmapByteCount))
        let bitmapInfo = CGBitmapInfo.fromRaw(CGImageAlphaInfo.PremultipliedFirst.toRaw())!
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, CUnsignedLong(8), CUnsignedLong(bitmapBytesPerRow), colorSpace, bitmapInfo)
        
        // Make sure and release colorspace before returning
        
        return context
    }
    
    private func getPixelColorAtLocation(context: CGContext, point:CGPoint, inImage:CGImageRef) -> UIColor {
        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
        
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        let data:COpaquePointer = COpaquePointer(CGBitmapContextGetData(context))
        let dataType = UnsafePointer<UInt8>(data)
        
        let offset = 4*((Int(pixelsWide) * Int(point.y)) + Int(point.x))
        let a = dataType[offset]
        let r = dataType[offset+1]
        let g = dataType[offset+2]
        let b = dataType[offset+3]
        
        return UIColor(r: Int(r), Int(g), Int(b), Int(a))
    }
}

extension String {
    
    func encodeToBase64Encoding() -> String {
        let utf8str = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let base64EncodedString = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!)
        return base64EncodedString!
    }
    
    func decodeFromBase64Encoding() -> String {
        let base64data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions.fromRaw(0)!)
        let decodedString = NSString(data: base64data, encoding: NSUTF8StringEncoding)
        return decodedString
    }

    var floatValue: Float {
        return (self as NSString).floatValue
    }


    var CGFloatValue: CGFloat {
        return CGFloat(self.floatValue)
    }

    var length: Int {
        return self.utf16Count
    }
}

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Home", bundle: nil)
    }
    
    class func loginStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
    }


    class func quizStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Quiz", bundle: NSBundle.mainBundle())
    }
}

extension UIViewController {
    func setNavigationTintColor(barColor:UIColor!, buttonColor:UIColor!){
        if self.navigationController != nil {
            if barColor != nil {
                self.navigationController.navigationBar.barTintColor = barColor
            }
            
            if buttonColor != nil {
                self.navigationController.navigationBar.tintColor = buttonColor
            }
        }
    }
    
}

extension UIFont {
    func ProximaNovaFont(size:CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-Regular", size: size)
    }
}