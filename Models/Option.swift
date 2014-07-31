//
//  Option.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class Option {
    public var content: String? = ""
    
    public var imageContent: UIImage? = nil
    
    public convenience init(stringContent:String){
        self.init(stringContent:stringContent, imageContent:nil)
    }
    
    public convenience init(imageContent:UIImage){
        self.init(stringContent:nil, imageContent:imageContent)
    }
    
    public init(stringContent:String?, imageContent:UIImage?){
        if let strCont = stringContent {
            self.content = strCont
        }
        
        if let imgCont = imageContent {
            self.imageContent = imgCont
        }
    }
}
