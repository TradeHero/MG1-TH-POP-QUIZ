//
//  GPUImageProcessor.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/18/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class GPUImageProcessor {
    required init(){
        
    }
    
    var grayscale: Bool = false {
        didSet{
            for filter in self.filters {
                if filter is GPUImageGrayscaleFilter {
                    if !grayscale {
                        self.filters = self.filters.filter({$0 != filter})
                        return
                    }
                }
            }
            if grayscale {
                self.filters.append(GPUImageGrayscaleFilter())
            }
        }
    }
    
    var swirl: Bool = false {
        didSet{
            for filter in self.filters {
                if filter is GPUImageSwirlFilter {
                    if !swirl {
                        self.filters = self.filters.filter({$0 != filter})
                        return
                    }
                }
            }
            if swirl {
                self.filters.append(GPUImageSwirlFilter())
            }
        }
    }
    
    private var filters: [GPUImageFilter] = []
    
    func imageWithFilterAppliedWithImage(image:UIImage) -> UIImage {
        let picture = GPUImagePicture(image: image, smoothlyScaleOutput: true)
        var lastFilter: GPUImageOutput = picture
        var filter: GPUImageFilter!
        
        let scale = UIScreen.mainScreen().scale
        let processSize = CGSizeMake(image.size.width * scale, image.size.height * scale)
        
        for filter in filters{
            filter.forceProcessingAtSize(processSize)
            lastFilter.removeAllTargets()
            lastFilter.addTarget(filter)
            lastFilter = filter
        }
        
        picture.processImage()
        return lastFilter.imageFromCurrentFramebuffer()
    }
}