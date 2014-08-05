//
//  Option.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

/// Choices that are of a given question. Can be textual or image-based, or both. Designed to scale according to needs.
public class Option {
        
    /// String content of the option
    public let stringContent: String? = ""
    
    /// Image content of the option
    public let imageContent: UIImage? = nil

    /**
        Initialise option with string content and image content
    
        :param: stringContent The string content of the option
        :param: imageContent The image content of the option
    */
    public init(stringContent:String? = nil, imageContent:UIImage? = nil){
        if let strCont = stringContent {
            self.stringContent = strCont
        }
        
        if let imgCont = imageContent {
            self.imageContent = imgCont
        }
    }
}
