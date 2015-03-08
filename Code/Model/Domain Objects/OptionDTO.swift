//
//  OptionDTO.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import UIKit

struct OptionDTO: DebugPrintable, Equatable {
    let stringContent: String!
    
    let imageContentURLString: String!
    
    var imageContent: UIImage!
    
    lazy var isGraphical: Bool = {
        return self.imageContentURLString != nil
    }()

    let originalContent: String
    
   /**
    Initialise option with string content and image content
    
    :param: stringContent The string content of the option
    */
    init(stringContent: String) {
        originalContent = stringContent
        var d = stringContent.componentsSeparatedByString("|")
        if d.count == 2 {
            self.stringContent = d[0]
            self.imageContentURLString = d[1]
        } else {
            self.stringContent = stringContent
            self.imageContentURLString = nil
        }
    }

    mutating func fetchImage(completionHandler: () -> ()) {
        if let imgName = self.imageContentURLString {
            NetworkClient.fetchImageFromURLString(imgName, progressHandler: nil, completionHandler: {
                image, error in
                if error != nil {
                    debugPrintln(error)
                    return
                }
                if image != nil {
                    self.imageContent = image
                }
                completionHandler()
            })

        } else {
            completionHandler()
        }
    }
    
    var debugDescription: String {
        return "[ Option content: \(stringContent) ]"
    }
}

func ==(lhs:OptionDTO, rhs:OptionDTO) -> Bool {
    return lhs.stringContent == rhs.stringContent && lhs.imageContentURLString == rhs.imageContentURLString
}
