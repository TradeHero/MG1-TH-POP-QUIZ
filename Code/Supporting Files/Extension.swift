//
//  Extension.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import AVFoundation

extension UINavigationController {
    func hideNavigationBar() {
        if !self.navigationBarHidden {
            self.navigationBarHidden = true
        }
    }
    
    func showNavigationBar() {
        if self.navigationBarHidden {
            self.navigationBarHidden = false
        }
    }
}

extension UITableView {
    func forceUpdateTable(){
        self.beginUpdates()
        self.endUpdates()
    }
}
extension UIControl {
    func disable() {
        if enabled {
            enabled = false
        }
    }
    
    func enable() {
        if !enabled {
            enabled = true
        }
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
    
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if let i = index {
            self.removeAtIndex(i)
        }
    }
    
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}

extension CGFloat {
    
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
    
//    func roundToNearest1DecimalPlace() -> CGFloat {
//        return self.format(".1").CGFloatValue
//    }
    
    func roundToNearest1DecimalPlace() -> CGFloat {
        return CGFloat(Int(floor(self * 10 + 0.5))) / 10
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
    
    var x: CGFloat {
        get {
            return self.center.x
        }
        
        set(x) {
            var frame = self.frame
            frame.origin.x = x
            self.frame = frame
        }
    }
    
    var y: CGFloat {
        get {
            return self.center.y
        }
        
        set(y) {
            var frame = self.frame
            frame.origin.y = y
            self.frame = frame
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        
        set(width) {
            var frame = self.frame
            frame.size.width = width
            self.frame = frame
        }
    }

    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        
        set(height) {
            var frame = self.frame
            frame.size.height = height
            self.frame = frame
        }
    }

    
    
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
    
    class func animateWithDuration(duration: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> ()) {
        self.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: nil)
    }
    
    class func roundView(view:UIView, onCorner rectCorner:UIRectCorner, radius:CGFloat) {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: rectCorner, cornerRadii: CGSizeMake(radius, radius))
        var maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.CGPath
        view.layer.mask = maskLayer
    }
    
    func hideWithAnimation(hide:Bool) {
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
            [unowned self] in
            if hide {
                self.alpha = 0
                self.hidden = false
                self.alpha = 1
            } else {
                self.alpha = 0
            }
            }) { complete in
                if !hide {
                    self.hidden = true
                }
        }
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
    
    func centerCropImage() -> UIImage {
        // Use smallest side length as crop square length
        let squareLength = min(self.size.width, self.size.height)
        // Center the crop area
        let clippedRect = CGRectMake((self.size.width - squareLength) / 2, (self.size.height - squareLength) / 2, squareLength, squareLength)
        // Crop logic
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, clippedRect)

        return UIImage(CGImage: imageRef)!
    }
    
    func transparencyToWhiteMatte() -> UIImage {
        return UIImage(data: UIImageJPEGRepresentation(self, 1)!)!
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
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
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
        let rect = CGRectMake(0, 0, CGFloat(pixelsWide), CGFloat(pixelsHigh))
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
        let base64EncodedString = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
        return base64EncodedString!
    }
    
    func decodeFromBase64Encoding() -> String {
        let base64data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(0))
        let decodedString = NSString(data: base64data!, encoding: NSUTF8StringEncoding)
        return decodedString!
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    
    var CGFloatValue: CGFloat {
        return CGFloat(self.floatValue)
    }
    
    var intValue: Int {
        return (self as NSString).integerValue
    }
    
    var length: Int {
        return self.utf16Count
    }
}

extension UINavigationController {
    func setNavigationTintColor(barColor:UIColor? = nil, buttonColor:UIColor? = nil){
        if let color = barColor {
              self.navigationBar.barTintColor = color
        }
        
        if let color = buttonColor {
            self.navigationBar.tintColor = color
        }
        
    }
}

extension UIFont {
    func ProximaNovaFont(size:CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-Regular", size: size)!
    }
}

extension AVAudioPlayer {
    class func createAudioPlayer(fileName: String, extensionName:String) -> AVAudioPlayer {
        let url = NSBundle.mainBundle().URLForResource(fileName, withExtension: extensionName)
        return AVAudioPlayer(contentsOfURL: url!, error: nil)
    }
    
    class func createAudioPlayer(urlResource: NSURL) -> AVAudioPlayer {
        return AVAudioPlayer(contentsOfURL: urlResource, error: nil)
    }
    
    func fadeToStop() {
        var originalVolume = self.volume
        self.fadeOutWithDuration(1.0)
        self.currentTime = 0
        self.volume = originalVolume
        self.prepareToPlay()
    }
}

extension JGProgressHUD {
    class func progressHUDWithCustomisedStyle(style:JGProgressHUDStyle) -> JGProgressHUD! {
        var hud = JGProgressHUD(style: style)
        hud.textLabel.font = UIFont(name: "AngryBirds-Regular", size: 18)
        hud.detailTextLabel.font = UIFont(name: "AngryBirds-Regular", size: 14)
        hud.indicatorView = THIndefiniteIndicatorView(style: style)
        hud.interactionType = .BlockAllTouches
//        hud.animation = JGProgressHUDFadeZoomAnimation()
        return hud
    }
    
    class func progressHUDWithCustomisedStyleInView(view:UIView, style:JGProgressHUDStyle = .ExtraLight) -> JGProgressHUD! {
        let hud = self.progressHUDWithCustomisedStyle(style)
        hud.showInView(UIApplication.sharedApplication().delegate?.window!)
        return hud
    }
    
    class func progressHUDWithRingStyle(style:JGProgressHUDStyle) -> JGProgressHUD! {
        var hud = JGProgressHUD(style: style)
        hud.textLabel.font = UIFont(name: "AngryBirds-Regular", size: 18)
        hud.detailTextLabel.font = UIFont(name: "AngryBirds-Regular", size: 14)
        hud.layoutChangeAnimationDuration = 0.5
        hud.indicatorView = JGProgressHUDRingIndicatorView(HUDStyle: style)
        hud.interactionType = .BlockAllTouches
        hud.showInView(UIApplication.sharedApplication().delegate?.window!)
        return hud
    }
}

extension Int {
    var decimalFormattedString: String {
        return NSNumberFormatter.localizedStringFromNumber(NSNumber(integer: self), numberStyle: .DecimalStyle)
    }
}



extension NSData {
    func deviceTokenString() -> String {
        var token = self.description
        token = token.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        return token
    }
}
