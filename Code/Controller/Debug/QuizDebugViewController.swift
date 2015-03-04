//
//  QuizDebugViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 3/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import UIKit
import LDProgressView
import JGProgressHUD
import KKProgressTimer
import PureLayout

class QuizDebugViewController: UIViewController {
    
    @IBAction func dismissClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    let MAX_ALLOWED_TIME:CGFloat = 15.0
    let basicScorePerQuestion = 1000
    // MARK:- UI var
    
    @IBOutlet weak var timerView: KKProgressTimer!
    
    @IBOutlet private var optionGroup: [OptionButton]!
    
    @IBOutlet private weak var questionView: UIView!
    
    @IBOutlet private weak var removeOptionsButton: DesignableButton!
    
    @IBOutlet private weak var buttonSetContentView: UIView!
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var difficultyLabel: UILabel!
    
    var questionSet = [QuestionDTO]()
    
    
    var currentQuestionIndex: Int = 0
    
    func bindQuestionSet(questionSet: [QuestionDTO]){
        self.questionSet = questionSet
        self.questionSet.shuffle()
    }
    
    
    override func viewDidLoad() {
        if(questionSet.count == 0){
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
        //if questions exist, display
        setupFirstQuestionView()
    }
    
    private func setupFirstQuestionView(){
        var firstQuestion = questionSet.first;
        setupViewWithQuestion(firstQuestion!)
    }
    
    private func setupViewWithQuestion(question: QuestionDTO){
        questionView.removeAllSubviews()
        let contentView = setUpQuestionViewWithQuestion(question)
        questionView.addSubview(contentView)
        contentView.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
        contentView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
        contentView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 0)
        contentView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 0)
        
        let optionSet = question.options.allOptions
        
        var optionButtonSet = self.optionGroup
        
        var i = 0
        for option in optionSet {
            optionButtonSet[i].configureButtonWithContent(option.stringContent, imageContent: option.imageContent )
            if question.options.checkOptionChoiceIfIsCorrect(option) {
                optionButtonSet[i].is_answer = true
            } else {
                optionButtonSet[i].is_answer = false
            }
            i++
        }
        questionLabel.text = "QID: \(question.questionID)"
        
        switch question.difficulty {
        case 1:
            difficultyLabel.text = "Easy"
        case 2:
             difficultyLabel.text = "Medium"
        case 3:
             difficultyLabel.text = "Hard"
        default:
             difficultyLabel.text = "Undefined"
        }
    }
    
    private func setUpQuestionViewWithQuestion(question:QuestionDTO) -> UIView {
        if question.isGraphical() {
            var contentView = NSBundle.mainBundle().loadNibNamed("QuestionViewWithImage"
                , owner: self, options: nil)[0] as QuestionViewWithImage
            
            contentView.questionContent.text = question.questionContent
            
            switch question.questionType {
            case .LogoType:
                if let img = question.questionImage {
                    let filters:[LogoCanvasObfuscationType] = [.SwirlEffect, .PixellateEffect, .GaussianBlurEffect]
                    contentView.logoCanvasView.presetImage = img
                    contentView.logoCanvasView.obfuscationType = filters.randomItem()
                    contentView.logoCanvasView.prepareFirstObfuscation()
                }
            default:
                if let img = question.questionImage {
                    contentView.logoCanvasView.presetImage = img
                }
            }
            
            return contentView
        } else {
            if let accessoryImage = question.accessoryImage {
                var contentView = NSBundle.mainBundle().loadNibNamed("QuestionViewWithAccessoryImage", owner: self, options: nil)[0] as QuestionViewWithAccessoryImage
                
                contentView.questionContent.text = question.questionContent
                contentView.accessoryImageView.image = question.accessoryImage
                
                return contentView
            } else {
                var contentView = NSBundle.mainBundle().loadNibNamed("QuestionViewPlain", owner: self, options: nil)[0] as QuestionViewPlain
                
                contentView.questionContent.text = question.questionContent
                return contentView
            }
        }
    }
    private func setupNextQuestion(){
        if(currentQuestionIndex == questionSet.count){
            return
        }
        setupViewWithQuestion(questionSet[currentQuestionIndex++])
    }
    
    private func setupPreviousQuestion(){
        if(currentQuestionIndex == 0){
            return
        }
        setupViewWithQuestion(questionSet[currentQuestionIndex--])
    }
    
    @IBAction func clickNext(sender: AnyObject) {
        setupNextQuestion()
    }
    
    @IBAction func clickPrevious(sender: AnyObject) {
        setupPreviousQuestion()
    }
   }