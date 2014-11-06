//
//  Option.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

/// Choices that are of a given question.

final class Option {
    
    /// String content of the option
    let stringContent: String!
    
    let imageContentURLString: String!
    
    var imageContent: UIImage!
    
    lazy var isGraphical: Bool = {
        return self.imageContentURLString != nil
        }()
    /**
    Initialise option with string content and image content
    
    :param: stringContent The string content of the option
    */
    init(stringContent:String){
        var d = stringContent.componentsSeparatedByString("|")
        if d.count == 2 {
            self.stringContent = d[0]
            self.imageContentURLString = d[1]
        } else {
            self.stringContent = stringContent
            self.imageContentURLString = nil
        }
    }
    
    func fetchImage(completionHandler:() -> ()){
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
            
        }else{
            completionHandler()
        }
    }
}

extension Option : Printable {
    var description :String {
        return "[ Option content: \(stringContent) ]"
    }
}