//
//  QuestionWithImage.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class QuestionViewWithImage: UIView {

    @IBOutlet public weak var questionContent: UILabel!
    @IBOutlet public weak var imageView: UIImageView!
    
    var image: UIImage? {
    didSet{
        imageView.image = processImage(image!)
    }
    }
    
    public init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    public init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    func processImage(image:UIImage) -> UIImage{
        let whiteImage = UIImage.imageWithColor(UIColor.whiteColor(), size: image.size)
        let sourceImage = image.CGImage
        let data: CFDataRef = CGDataProviderCopyData(CGImageGetDataProvider(sourceImage))
        var pixelData = UnsafePointer<UInt8>(CFDataGetBytePtr(data))
        
        let dataLength = CFDataGetLength(data) as Int
        
        for var i = 0 ; i < dataLength ; i += 4 {
            var r = 255, b = 255, g = 255, a = 255
            
            pixelData[i + 1] = UInt8(r)
            pixelData[i + 2] = UInt8(g)
            pixelData[i + 3] = UInt8(b)
            pixelData[i + 4] = UInt8(a)
        }

        var context = CGBitmapContextCreate(pixelData,
            CGImageGetWidth(sourceImage),
            CGImageGetHeight(sourceImage),
            UInt(8),
            CGImageGetBytesPerRow(sourceImage),
            CGImageGetColorSpace(sourceImage),
            CGBitmapInfo.fromRaw(CGImageAlphaInfo.PremultipliedLast.toRaw())!)
        
        let newImage = CGBitmapContextCreateImage(context)
        
        let originalOrientaion: UIImageOrientation = whiteImage.imageOrientation
        
        let data3 = UIImagePNGRepresentation(whiteImage)
        var result = CIImage(data: data3)
        let result2 = CIImage(CGImage: newImage)
        
        let context2 = CIContext(options: nil)
        var addBackground = CIFilter(name: "CISourceOverCompositing")
        addBackground.setDefaults()
        addBackground.setValue(result, forKey: "inputImage")
        addBackground.setValue(result2, forKey: "inputBackgroundImage")
        
        result = addBackground.valueForKey("outputImage") as CIImage
        
        let imgRef = context2.createCGImage(result, fromRect: result.extent())
        let img = UIImage(CGImage: imgRef, scale: 1, orientation: originalOrientaion)
        
        return img
    }
    

}
