//
//  DataFormatter.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 6/11/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import FormatterKit

class DataFormatter {

    class var shared: DataFormatter {

        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var instance: DataFormatter!
        }

        dispatch_once(&Singleton.onceToken) {
            Singleton.instance = DataFormatter()
        }

        return Singleton.instance
    }

    lazy var timeIntervalFormatter: TTTTimeIntervalFormatter = {
        let tif = TTTTimeIntervalFormatter()
//        tif.presentDeicticExpression = "Today"
//        tif.presentTimeIntervalMargin = 60 * 60 * 24
        tif.usesIdiomaticDeicticExpressions = true
        return tif
    }()

    lazy var dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = NSTimeZone(name: "UTC")
        return df
    }()
}
