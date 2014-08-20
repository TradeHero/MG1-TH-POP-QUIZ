//
//  LogoCanvasView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/19/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class LogoCanvasView: UIView {

    private var rasterizedImage: UIImage!
    
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        
    }
    
    var gpuProcessor: GPUImageProcessor = GPUImageProcessor()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.imageView = UIImageView(frame: CGRectMake(10, 10, 240, 110))
        self.addSubview(self.imageView)
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.gpuProcessor.swirl = true
        self.gpuProcessor.grayscale = true
        self.contentMode = UIViewContentMode.ScaleAspectFit
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func mosaic(tileSize:Int){
        self.imageView.image = UIImage(CGImage: rasterizedImage.CGImage).mosaicEffectOnImage(tileSize)
        
    }
    
    func reset(){
        UIView.transitionWithView(self, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() -> Void in
            self.imageView.image = self.rasterizedImage
            }, completion: nil)
    }
    
    var presetImage : UIImage! {
        didSet{
            if let img = self.presetImage {
                self.imageView.image = img.transparencyToWhiteMatte()
                self.rasterizedImage = UIView.rasterizeView(self)
                self.imageView.image = rasterizedImage
            }
        }
    }
    
    func applyFilters() {
        self.imageView.image = gpuProcessor.imageWithFilterAppliedWithImage(rasterizedImage)
    }
}
