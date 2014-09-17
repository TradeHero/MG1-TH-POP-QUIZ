//
//  QuestionResultTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/2/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

enum ResultStatus : Int {
    case Partial
    case Full
}


class QuestionResultTableViewCell: UITableViewCell {

    var delegate: QuestionResultTableViewCellDelegate!
    
    private var questionId: Int = 0
    private var selfQuestionResult: QuestionResult!
    private var opponentQuestionResult: QuestionResult!
    
    private var resultStatus: ResultStatus = .Partial {
        didSet {
            switch resultStatus {
            case .Partial:
                configureOpponentNotReady()
            case .Full:
                configureFullResult()
            }
        }
    }
    
    @IBOutlet private weak var questionTypeNameLabel: UILabel!
    
    @IBOutlet private weak var selfQuestionResultImageView: UIImageView!
    @IBOutlet private weak var selfQuestionTimeLabel: UILabel!
    
    @IBOutlet private weak var opponentQuestionTimeLabel: UILabel!
    @IBOutlet private weak var opponentQuestionResultImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction private func infoAction() {
        if self.delegate != nil {
            self.delegate.questionResultCell(self, didTapInfoButton: self.questionId)
        }
    }
    
    func bindQuestionResults(selfResult: QuestionResult, opponentResult:QuestionResult!, index:Int) {
        self.selfQuestionResult = selfResult
        self.opponentQuestionResult = opponentResult
//        if selfResult.questionId == opponentResult.questionId {
            self.questionId = selfResult.questionId
//        }
        self.questionTypeNameLabel.text = "Question \(index)"
        
        if opponentQuestionResult == nil {
            self.resultStatus = .Partial
        } else {
            self.resultStatus = .Full
        }
    }
    
    private func configureOpponentNotReady() {
        configureSelfResult()
        opponentQuestionTimeLabel.hidden = true
        opponentQuestionResultImageView.image = UIImage(named: "ResultPendingQuestionBox")
    }
    
    private func configureFullResult() {
        configureSelfResult()
        if opponentQuestionResult.isCorrect {
            opponentQuestionTimeLabel.hidden = false
            opponentQuestionTimeLabel.text = "\(NSNumber(float: opponentQuestionResult.timeTaken).stringValue)s"
            opponentQuestionResultImageView.image = UIImage(named: "ResultCorrectQuestionBox")
        } else {
            opponentQuestionTimeLabel.hidden = true
            opponentQuestionResultImageView.image = UIImage(named: "ResultWrongQuestionBox")
        }
    }
    
    private func configureSelfResult(){
        if selfQuestionResult.isCorrect {
            selfQuestionTimeLabel.hidden = false
            selfQuestionTimeLabel.text = "\(NSNumber(float: selfQuestionResult.timeTaken).stringValue)s"
            selfQuestionResultImageView.image = UIImage(named: "ResultCorrectQuestionBox")
        } else {
            selfQuestionTimeLabel.hidden = true
            selfQuestionResultImageView.image = UIImage(named: "ResultWrongQuestionBox")
        }

    }
}

protocol QuestionResultTableViewCellDelegate :class, NSObjectProtocol{
    func questionResultCell(cell:QuestionResultTableViewCell, didTapInfoButton questionID:Int)
}