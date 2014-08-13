//
//  Option.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

/// Choices that are of a given question.

public class Option {
    
    /// String content of the option
    public let stringContent: String
    
    /**
    Initialise option with string content and image content
    
    :param: stringContent The string content of the option
    */
    public init(stringContent:String){
        self.stringContent = stringContent
    }
}
