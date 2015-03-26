//
//  Option.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import Argo
import Runes

class Option: JSONDecodable, DebugPrintable, Equatable, DictionaryRepresentation {
    let content : String
    let accessoryImageUrl : String?

    var imageContent: UIImage!

    lazy var isGraphical: Bool = {
        return self.accessoryImageUrl != nil
    }()

    init(content:String, accessoryImageUrl:String?){
        self.content = content
        self.accessoryImageUrl = accessoryImageUrl
    }
    
    class func create(content: String)(accessoryImageUrl: String?)-> Option {
        return Option(content: content, accessoryImageUrl: accessoryImageUrl)
    }
    
    class func decode(j: JSONValue) -> Option? {
        return Option.create
            <^> j <| "content"
            <*> j <| "accessoryImageUrl"
    }

    /**
     Initialise option with string content and image content

     :param: stringContent The string content of the option
     */
    
    func fetchImage(completionHandler: () -> ()) {
        if let imgName = self.accessoryImageUrl {
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
        return "[ Option content: \(content) ]"
    }
    
    var dictionaryRepresentation: [String:AnyObject] {
        return ["content": content, "accessoryImageUrl": accessoryImageUrl ?? NSNull()];
    }
}

func ==(lhs: Option, rhs: Option) -> Bool {
    return lhs.content == rhs.content
}
