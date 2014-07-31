//
//  MiniProgressResultView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/31/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let b = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:r, green:g, blue:b, alpha:alpha)
    }
}

@IBDesignable
public class MiniProgressResultView: UIView {

    @IBOutlet weak var contentLabel: UILabel!

    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        layer.cornerRadius = 9.0
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 1.5
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */
    override public func prepareForInterfaceBuilder() {
        setup()
    }
    
    public func showWrongAnswerView(){
        self.backgroundColor = UIColor(hex: 0xEF5354)
    }
    
    public func showCorrectAnswerView(timeTakenString:String){
        self.backgroundColor = UIColor(hex: 0x00D680)
        contentLabel.text = timeTakenString
    }

}
