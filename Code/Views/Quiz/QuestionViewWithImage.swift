//
//  QuestionWithImage.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class QuestionViewWithImage: UIView {

    @IBOutlet weak var questionContent: UILabel!

    @IBOutlet weak var logoCanvasView: LogoCanvasView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }

    func setup() {
        self.logoCanvasView = NSBundle.mainBundle().loadNibNamed("LogoCanvasView", owner: self, options: nil)[0] as! LogoCanvasView
    }
}
