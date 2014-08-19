//
//  EditableImageView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/4/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class EditableImageView: UIImageView {

    private var rasterizedImage: UIImage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        self.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    var gpuProcessor: GPUImageProcessor = GPUImageProcessor()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.gpuProcessor.swirl = true
        self.gpuProcessor.grayscale = true
        self.contentMode = UIViewContentMode.ScaleAspectFit
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func mosaic(tileSize:Int){
        self.image = UIImage(CGImage: rasterizedImage.CGImage).mosaicEffectOnImage(tileSize)
        
    }

    func reset(){
//        self.image = matteImage
        UIView.transitionWithView(self, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() -> Void in
            self.image = self.rasterizedImage
            }, completion: nil)
    }
    
    var presetImage : UIImage! {
        didSet{
            self.image = presetImage.transparencyToWhiteMatte()
            rasterizedImage = UIView.rasterizeView(self)
            self.image = rasterizedImage
        }
    }
    
    func applyFilters() {
        self.image = gpuProcessor.imageWithFilterAppliedWithImage(rasterizedImage)
    }
    
}
