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
                var filter = GPUImageSwirlFilter()
                filter.angle = 0.2
                self.filters.append(filter)
            }
        }
    }
    
    private var filters: [GPUImageFilter] = []
    
    func imageWithFilterAppliedWithImage(image:UIImage) -> UIImage {
        var filterableImage = image
        for filter in filters{
            filterableImage = filter.imageByFilteringImage(filterableImage)
        }
        
        return filterableImage
    }
}