//
//  QuizViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Views
import Models
import AudioToolbox

class QuizViewController: UIViewController {
    // MARK:- UI var
    @IBOutlet weak var option1: OptionButton!
    
    @IBOutlet weak var option2: OptionButton!
    
    @IBOutlet weak var option3: OptionButton!
    
    @IBOutlet weak var option4: OptionButton!
    
    @IBOutlet weak var questionView: UIView!
    
    

    @IBOutlet weak var timeLeftLabel: UILabel!
    
    @IBOutlet weak var removeOptionsButton: DesignableButton!
    
    @IBOutlet weak var selfProgressView: UIProgressView!
    @IBOutlet weak var selfAvatarView: AvatarRoundedView!
    @IBOutlet weak var selfScoreLabel: UILabel!
    @IBOutlet weak var selfDisplayNameLabel: UILabel!
    @IBOutlet weak var selfRankLabel: UILabel!
    
    
    @IBOutlet var opponentProgressView: UIProgressView!
    @IBOutlet weak var opponentAvatarView: AvatarRoundedView!
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var opponentDisplayNameLabel: UILabel!
    @IBOutlet var opponentRankLabel: UILabel!
    
    
    // MARK:- ivar
    private var current_q: Int = 0
    
    private var current_timeLeft: Double = 10.0 {
    didSet{
        let timeString = current_timeLeft.format(".1")
        
        if current_timeLeft < 3.0 {
            timeLeftLabel.textColor = UIColor(hex: 0xfe0000)
        } else if current_timeLeft < 7.5 {
            timeLeftLabel.textColor = UIColor.yellowColor()
        } else {
            timeLeftLabel.textColor = UIColor.blackColor()
        }
        timeLeftLabel.text = timeString
    }
    }
    
    private var turn: Turn!
    
    private var stopwatch: NSTimer? = nil
    
    private var stopwatchStartTime: NSDate!
    
    private var currentQuestionCorrect: Bool = false
    
    private var selfTotalScore: Int = 0 {
    didSet{
        selfScoreLabel.text = String(selfTotalScore)
        selfProgressView.setProgress(Float(selfTotalScore)/2500.0, animated: true)
    }
    }
    
    
    private var didRemoveOptions: Bool = false
    
// MARK:- init
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        turn = Turn(player: Player(name: "Ryne Cheow", rank: "Knight", displayPic: UIImage(named: "AvatarSample1")), opponent: Player(name: "Maggie Grace", rank: "Novice", displayPic: UIImage(named: "AvatarSample2")), questionSet: QuestionSetFactory.sharedInstance.generateDummyQuestionSet(), newGame: true)
    }

// MARK:- override calls
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewWithQuestion(turn.questionSet[current_q])
        setUpPlayerDetails()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

// MARK:- methods

    func setUpPlayerDetails() {
        let thisPlayer = turn.player
        let opponent = turn.opponent
        
        selfAvatarView.image = thisPlayer.displayImage
        selfDisplayNameLabel.text = thisPlayer.displayName
        selfRankLabel.text = thisPlayer.rank
        selfTotalScore = 0
        
        opponentAvatarView.image = opponent.displayImage
        opponentDisplayNameLabel.text = opponent.displayName
        opponentRankLabel.text = opponent.rank
//        opponentScoreLabel.text = turn.newGame ? "0" : String(turn.opponentScore)
    }
    
    func setUpViewWithQuestion(question:Question){
        self.resetButtons()
        didRemoveOptions = false
        let optionSet = question.options.allOptions
        
        var optionButtonSet = [option1, option2, option3, option4]
        
        var i = 0
        for option in optionSet {
            optionButtonSet[i].option = option.stringContent
            if question.options.checkOptionChoiceIfIsCorrect(option) {
                optionButtonSet[i].is_answer = true
            } else {
                optionButtonSet[i].is_answer = false
            }
            i++
        }
        
        questionView.removeAllSubviewsExceptSubview(nil)
        questionView.addSubview(setUpQuestionViewWithQuestion(question))
        self.timerStart()
    }
    
    func setUpQuestionViewWithQuestion(question:Question) -> UIView {
        if question.isGraphical() {
            var contentView = NSBundle.mainBundle().loadNibNamed("QuestionViewWithImage"
                , owner: self, options: nil)[0] as QuestionViewWithImage
            contentView.questionContent.text = question.questionContent
            switch question.questionType {
            case .LogoType:
                contentView.imageView.presetImage = question.questionImage
                contentView.imageView.mosaic(20)
            default:
                contentView.imageView.presetImage = question.questionImage
            }
            
            return contentView
        } else {
            var contentView = NSBundle.mainBundle().loadNibNamed("QuestionViewPlain", owner: self, options: nil)[0] as QuestionViewPlain
            
            contentView.questionContent.text = question.questionContent
            return contentView
        }
    }
    
    func unmaskContentViewIfNecessary() {
        switch turn.questionSet[current_q].questionType {
        case .LogoType:
            for view in questionView.subviews {
                if let logoView = view as? QuestionViewWithImage {
                    logoView.imageView.reset()
                }
            }
        default:
            break
        }
    }
    
    func resetButtons(){
        for option in [option1, option2, option3, option4] {
            option.backgroundColor = UIColor.whiteColor()

            if option.wobbling {
                option.stopWobble()
            }
            if !option.enabled {
                option.enable()
            }
            
            if option.alpha == 0 {
                option.alpha = 1
            }
        }

        if !removeOptionsButton.enabled {
            removeOptionsButton.enable()
        }
        
        
        if removeOptionsButton.alpha == 0.5 {
            removeOptionsButton.alpha = 1
        }
    }

    func preventFurtherActions(){
        removeOptionsButton.disable()
        removeOptionsButton.alpha = 0.5

        for option in [option1, option2, option3, option4] {
            option.disable()
        }
    }

    @IBAction func optionSelected(sender: OptionButton) {
        timerStop()

        preventFurtherActions()

        currentQuestionCorrect = false
        
        if sender.is_answer {
            sender.backgroundColor = UIColor(hex: 0x4cd964)
            currentQuestionCorrect = true
        } else {
            sender.backgroundColor = UIColor(hex:0xFF6A6E)
            revealCorrectAnswer()
            AudioServicesPlayAlertSound(0x00000FFF)
        }
        
        unmaskContentViewIfNecessary()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "prepareToEndRound", userInfo: nil, repeats: false)
        
    }
    
    func prepareToEndRound() {
        current_q++
        calculateScore()
        if turn.questionSet.count > current_q {
            proceedToNextQuestion()
        } else {
            endTurn()
        }
    }
    
    func calculateScore(){
        var score = selfTotalScore
        let timeTaken:Float = 0
        let timeLeft = current_timeLeft
        let timeLeftBonus =  timeLeft > 0.0 ? timeLeft/10.0 : 0.4
        let correctiveFactor = currentQuestionCorrect ? 1.0 : 0.0
        let doubleScore = 500.0 * timeLeftBonus * correctiveFactor
        score += Int(doubleScore)
        selfTotalScore = score
    }
    
    
    /* timer */
    func timerStart() {
        stopwatchStartTime = NSDate()
        if stopwatch == nil {
            stopwatch = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
        }
    }
    
    func timerStop() {
        stopwatch?.invalidate()
        stopwatch = nil
    }
    
    func getTimeElasped() -> Double{
        let timeNow = NSDate()
        let timeInterval = timeNow.timeIntervalSinceDate(stopwatchStartTime)
        return timeInterval > 0 ? timeInterval : 0
    }
    
    func proceedToNextQuestion(){
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() -> Void in
            let new_q = self.turn.questionSet[self.current_q]
            self.setUpViewWithQuestion(new_q)
            }, completion:nil)
        
    }
    
    func updateTimer(){
        let time = getTimeElasped()
        var timeLeft = 10.0 - time
        if timeLeft > 0 {
            current_timeLeft = timeLeft
        } else if timeLeft <= 0 {
            timerStop()
            preventFurtherActions()
            AudioServicesPlayAlertSound(0x00000FFF)
            revealCorrectAnswer()
            unmaskContentViewIfNecessary()
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "prepareToEndRound", userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func removeTwoOptions(sender: AnyObject) {
        if !didRemoveOptions {
            var incorrectOptions:[OptionButton] = []
            for option in [option1, option2, option3, option4] {
                if !option.is_answer {
                    incorrectOptions.append(option)
                }
            }
            incorrectOptions.shuffle()
            UIView.animateWithDuration(0.5, animations: {()->Void in
                incorrectOptions[1].alpha = 0
                incorrectOptions[2].alpha = 0
                self.removeOptionsButton.alpha = 0.5
                })
            
            incorrectOptions[1].disable()
            incorrectOptions[2].disable()
            removeOptionsButton.disable()
        }
        didRemoveOptions = true
    }
    
    func revealCorrectAnswer() {
        for option in [option1, option2, option3, option4] {
            if option.is_answer {
                option.backgroundColor = UIColor(hex: 0x4cd964)
                option.startWobble()
                option.borderColor = UIColor.blackColor()
                option.borderWidth = 1.0
            }
        }
    }
 
    func endTurn(){
        let currentTurnScore = selfTotalScore
        
    }
}