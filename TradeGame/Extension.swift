//
//  Extension.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

extension Array
    {
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<self.count
        {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}

//extension UIView {
//    
//    class func loadInstanceFromNib() -> UIView? {
//        var classstr  = NSStringFromClass(self)
//        println(classstr)
//        return self.loadInstanceFromNibNamed(classstr)
//    }
//
//    class func loadInstanceFromNibNamed(nibName:String)-> UIView? {
//        var result: UIView? = nil
//        var elements = NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil)
//        
//        for element in elements {
////            if let view = element as? UIView {
////                result = view
////            }
//            
//            if element.isKindOfClass(self) {
//                result = element as? UIView
//            }
//            
//            break
//        }
//        
//        return result!
//    }
//}