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
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.image = image?.transparencyToWhiteMatte()
        let betterImage = UIView.rasterizeView(imageView)
        originalImage = betterImage
        imageView.image = betterImage
    }
    }
    
    private var originalImage: UIImage?
    
    var shouldMosaic: Bool = false {
    didSet{
        if shouldMosaic {
            imageView.image = imageView.image.mosaicEffectOnImage(10)
        } else {
            imageView.image = originalImage
        }
    }

    }
    
    public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        
    }
}
