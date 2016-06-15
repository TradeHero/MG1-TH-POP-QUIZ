//
//  OptionButtonTopViewWithAccessoryImage.swift
//  TH PopQuiz
//
//  Created by Ryne Cheow on 8/28/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class OptionButtonAccessoryImageLayer: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}