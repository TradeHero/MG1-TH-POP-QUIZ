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
    
    @IBOutlet private weak var timeLeftLabel: UILabel!
    
    @IBOutlet private weak var removeOptionsButton: DesignableButton!
    
    @IBOutlet private weak var roundIndicatorLabel: UILabel!
    
    @IBOutlet private weak var selfProgressView: LDProgressView!
    
    @IBOutlet private weak var selfAvatarView: AvatarRoundedView!
    
    @IBOutlet private weak var selfScoreLabel: UILabel!
    
    @IBOutlet private weak var selfDisplayNameLabel: UILabel!
    
    @IBOutlet private var opponentProgressView: LDProgressView!
    
    @IBOutlet private weak var opponentAvatarView: AvatarRoundedView!
    
    @IBOutlet private weak var opponentScoreLabel: UILabel!
    
    @IBOutlet private weak var opponentDisplayNameLabel: UILabel!
    
    
    @IBOutlet private weak var buttonSetContentView: UIView!
    
    // MARK:- ivar
    private var current_q: Int = 0
    
    private var current_timeLeft: CGFloat = 15.0 {
        didSet{
            let timeString = Double(current_timeLeft).format(".1")
            timeLeftLabel.text = timeString
            if current_timeLeft < 5.0 {
                timeLeftLabel.textColor = UIColor(hex: 0xfe0000)
            } else if current_timeLeft < 8 {
                timeLeftLabel.textColor = UIColor(hex :0x10634A)
            } else {
                timeLeftLabel.textColor = UIColor(hex :0x1063D9)
            }
        }
    }
    
    var game: Game!
    
    private var stopwatch: NSTimer? = nil
    
    private var stopwatchStartTime: NSDate!
    
    private var stopwatchCurrTime: CGFloat = 15.0
    
    private var currentQuestionCorrect: Bool = false {
        didSet {
            if currentQuestionCorrect {
                selfProgressView.progress += 1 / CGFloat(self.game.questionSet.count)
            }
        }
    }
    
    private var questionResults: [QuestionResult] = []
    
    private var selfTotalScore: Int = 0 {
        didSet{
            selfScoreLabel.text = "\(selfTotalScore.decimalFormattedString)"
        }
    }
    
    
    private var currentQuestion:Question {
        return game.questionSet[current_q]
    }
    private var isTimedObfuscatorQuestion:Bool {
        return currentQuestion.questionType == QuestionType.LogoType
    }
    
    private var didRemoveOptions: Bool = false
    
    private var player: THUser!
    
    private var opponent:THUser!
    
    private var opponentScore: Int = 0
    
    private var opponentQuestionCorrect: Int = 0
    
    private var combos: Int = 0 {
        didSet {
            if combos > highestCombo {
                highestCombo = combos
            }
        }
    }
    
    private var highestCombo: Int = 0
    
    private var hintUsed:UInt = 0
    
    private var totalHintUsed: UInt = 0
    
    private var gameMusicPlayer: AVAudioPlayer!
    
    // MARK:- init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK:- override calls
    override func viewDidLoad() {
        super.viewDidLoad()
        musicPlayer.stop()
        
        self.prepareFirstQuestionUISetup()
        for b in optionGroup {
            b.exclusiveTouch = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        playMusic("Piano 3")
        //        musicPlayer.play()
        self.navigationController?.hideNavigationBar()
        
        dispatch_after(1, dispatch_get_main_queue()) {
            [unowned self] in
            self.proceedToNextQuestion()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Actions
    @IBAction private func removeTwoOptions(sender: AnyObject) {
        if !didRemoveOptions {
            var incorrectOptions:[OptionButton] = []
            for option in self.optionGroup {
                if !option.is_answer {
                    incorrectOptions.append(option)
                }
            }
            incorrectOptions.shuffle()
            incorrectOptions[0].hideAndDisable(true)
            incorrectOptions[1].hideAndDisable(true)
            UIView.animateWithDuration(0.5) {
                self.removeOptionsButton.alpha = 0
            }
            
            removeOptionsButton.disable()
            hintUsed++
            totalHintUsed++
        }
        didRemoveOptions = true
    }
    
    
    @IBAction private func optionSelected(sender: OptionButton) {
        self.timerStop()
        self.preventFurtherActions()
        self.currentQuestionCorrect = false
        self.timeLeftLabel.text = "∞"
        for button in self.optionGroup {
            if sender !== button {
                button.shrink()
            }
        }
        
        if sender.is_answer {
            sender.configureAsCorrect()
            playCorrectSound()
            combos++
            currentQuestionCorrect = true
            let currentQuestionScore = calculateScore()
            produceResultForCurrentQuestion(true, score: currentQuestionScore)
        } else {
            sender.configureAsFalse()
            playWrongSound()
            revealCorrectAnswer()
            combos = 0
            let currentQuestionScore = calculateScore()
            produceResultForCurrentQuestion(false, score: currentQuestionScore)
            vibrateIfAllowed()
            
        }
        
        unmaskContentViewIfNecessary()
        
        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "prepareToEndRound", userInfo: nil, repeats: false)
    }
    
    // MARK:- methods
    
    private func preventFurtherActions(){
        removeOptionsButton.disable()
        removeOptionsButton.alpha = 0
        
        
        for option in self.optionGroup {
            option.disable()
        }
    }
    
    func prepareToEndRound() {
        current_q++
        if game.questionSet.count > current_q {
            proceedToNextQuestion()
        } else {
            endTurn()
        }
    }
    
    private func calculateScore() -> Int {
        let timeLeftBonus =  getTimeBonus(current_timeLeft)
        let comboBonus = getComboBonus()
        let hintPenalty = getHintPenalty()
        let correctiveFactor:CGFloat = currentQuestionCorrect ? 1.0 : 0.0
        let score = CGFloat(basicScorePerQuestion) * timeLeftBonus * correctiveFactor * comboBonus * hintPenalty
        self.selfTotalScore += Int(score)
        return Int(score)
    }
    
    private func getHintPenalty() -> CGFloat {
        switch hintUsed{
        case 0:
            return 1
        case 1:
            return 0.75
        case 2:
            return 0.5
        default:
            return 0.25
        }
    }
    
    private func getComboBonus() -> CGFloat {
        switch combos {
        case 0:
            return 1
        case 1:
            return 1.5
        case 2:
            return 2
        case 3:
            return 3
        case 4:
            return 4
        default:
            return 5
        }
    }
    
    private func getTimeBonus(timeLeft:CGFloat) -> CGFloat {
        let timeAllowed:CGFloat = MAX_ALLOWED_TIME
        
        let timeRange = (timeAllowed - timeLeft)/timeAllowed * 100
        
        switch timeRange {
        case 0..<0.5:
            return 10
        case 0.5..<5:
            return 5
        case 5..<10:
            return 2
        case 10..<20:
            return 1.5
        case 20..<30:
            return 1.2
        case 30..<50:
            return 1
        case 50..<70:
            return 0.8
        case 70..<100:
            return 0.4
        default:
            return 0
        }
    }
    
    
    //MARK:- Timer functions
    private func timerStart() {
        stopwatchCurrTime = MAX_ALLOWED_TIME
        if stopwatch == nil {
            stopwatch = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
        }
    }
    
    private func timerStop() {
        stopCountdownMusic()
        stopwatch?.invalidate()
        stopwatch = nil
    }
    
    private func getTimeElasped() -> CGFloat{
        let timeNow = NSDate()
        let timeInterval = CGFloat(timeNow.timeIntervalSinceDate(stopwatchStartTime))
        return timeInterval > 0 ? timeInterval : 0
    }
    
    private func proceedToNextQuestion(){
        
        switch(self.current_q){
        case 0:
            self.setUpViewWithQuestion(self.game.questionSet[self.current_q])
        default:
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.buttonSetContentView.alpha = 0
                }, completion: nil)
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.questionView.alpha = 0
                
                }) { c in
                    self.setUpViewWithQuestion(self.game.questionSet[self.current_q])
            }
        }
    }
    
    func updateTimer(){
        stopwatchCurrTime -= 0.1
        var timeLeft = stopwatchCurrTime
        if timeLeft > 0 {
            current_timeLeft = timeLeft
            if timeLeft < MAX_ALLOWED_TIME - 1 {
                playCountdownMusic()
            }
            if isTimedObfuscatorQuestion {
                showImageObfuscationWithTimeFactor(factor: timeLeft/MAX_ALLOWED_TIME)
            }
        } else if timeLeft <= 0 {
            playWrongSound()
            current_timeLeft = 0
            timerStop()
            preventFurtherActions()
            vibrateIfAllowed()
            revealCorrectAnswer()
            unmaskContentViewIfNecessary()
            let score = calculateScore()
            produceResultForCurrentQuestion(false, score: score)
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "prepareToEndRound", userInfo: nil, repeats: false)
            
        }
    }
    
    private func showImageObfuscationWithTimeFactor(factor:CGFloat = 1) {
        for view in self.questionView.subviews as [UIView] {
            if view is QuestionViewWithImage {
                let qview = view as QuestionViewWithImage
                qview.logoCanvasView.obfuscateWithEffect(factor)
            }
        }
    }
    
    private func revealCorrectAnswer() {
        for option in self.optionGroup {
            if option.is_answer {
                option.backgroundColor = UIColor(patternImage: UIImage(named: "CorrectAnswerBackground")!)
                option.unshrink()
            }
        }
    }
    
    private func endTurn(){
        let currentTurnScore = selfTotalScore
        let results = self.questionResults
        
        var hud = JGProgressHUD.progressHUDWithDefaultStyle()
        hud.showInWindow()
        
        hud.textLabel.text = "Calculating results..."
        NetworkClient.sharedClient.postGameResults(self.game, highestCombo: self.highestCombo, noOfHintsUsed: self.totalHintUsed, currentScore: currentTurnScore, questionResults: results, errorHandler:{error in}) {
            [unowned self] in
            playMusic(kTHDefaultSong)
            hud.dismissAnimated(true)
            self.game = $0
            if $0.isGameCompletedByBothPlayer {
                self.performSegueWithIdentifier("QuizWinLoseSegue", sender: nil)
                return
            }
            
            if $0.isGameCompletedByChallenger || $0.isGameCompletedByOpponent {
                self.performSegueWithIdentifier("PartialQuizResultSegue", sender: nil)
                return
            }
        }
    }
    
    
    //MARK:- UI setup
    private func setupProgressBar(bar:LDProgressView){
        bar.color = UIColor(hex: 0x75BF34)
        bar.background = UIColor(hex: 0x4A4A4A)
        bar.showText = NSNumber(bool: false)
        bar.progress = 0
        bar.type = LDProgressSolid
    }
    
    private func prepareFirstQuestionUISetup(){
        removeOptionsButton.disable()
        setUpPlayerDetails()
        questionView.alpha = 0
        buttonSetContentView.alpha = 0
        roundIndicatorLabel.alpha = 0
    }
    
    private func setUpQuestionViewWithQuestion(question:Question) -> UIView {
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
    
    private func setUpViewWithQuestion(question:Question){
        self.resetButtons()
        didRemoveOptions = false
        hintUsed = 0
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
        self.roundIndicatorLabel.alpha = 0
        switch self.current_q {
        case self.game.questionSet.count - 1:
            self.roundIndicatorLabel.text = "LAST ROUND"
        default:
            self.roundIndicatorLabel.text = "ROUND \(self.current_q + 1)"
        }
        
        
        
        UIView.animateWithDuration(1, delay: 0.0, options: .TransitionCrossDissolve, animations: {
            self.roundIndicatorLabel.alpha = 1
            }) { complete in
                UIView.animateWithDuration(1, options: .TransitionCrossDissolve) {
                    self.roundIndicatorLabel.alpha = 0
                }
        }
        
        UIView.animateWithDuration(1.5, delay: 2.0, options: .TransitionCrossDissolve, animations: {
            self.questionView.alpha = 1
            }, completion: nil)
        
        UIView.animateWithDuration(2.0, delay: 4.5, options: .TransitionCrossDissolve, animations: {
            [unowned self] in
            self.buttonSetContentView.alpha = 1
            }){ [unowned self] completed in
                if completed {
                    self.resetRemoveOptionsButton()
                    for option in self.optionGroup {
                        option.enable()
                    }
                    self.timerStart()
                }
        }
    }
    
    
    private func setUpPlayerDetails() {
        let thisPlayer = self.player
        let opponent = self.opponent
        
        self.setupProgressBar(self.selfProgressView)
        self.setupProgressBar(self.opponentProgressView)
        
        NetworkClient.fetchImageFromURLString(thisPlayer.pictureURL, progressHandler: nil) {
            [unowned self] image, error in
            if image != nil {
                self.selfAvatarView.image = image
            }
        }
        selfDisplayNameLabel.text = thisPlayer.displayName
        
        selfTotalScore = 0
        
        NetworkClient.fetchImageFromURLString(opponent.pictureURL, progressHandler: nil) {
            [unowned self] image, error in
            if image != nil {
                self.opponentAvatarView.image = image
            }
        }
        
        opponentDisplayNameLabel.text = opponent.displayName
        opponentProgressView.progress = CGFloat(self.opponentQuestionCorrect)/CGFloat(self.game.questionSet.count)
        opponentScoreLabel.text = "\(opponentScore.decimalFormattedString)"
        
        
    }
    
    private func unmaskContentViewIfNecessary() {
        switch currentQuestion.questionType {
        case .LogoType:
            for view in questionView.subviews {
                if let logoView = view as? QuestionViewWithImage {
                    logoView.logoCanvasView.reset()
                }
            }
        default:
            break
        }
    }
    
    private func resetButtons(){
        for option in self.optionGroup {
            option.resetButton()
        }
    }
    
    private func resetRemoveOptionsButton() {
        let threshold = UInt(0.3 * CGFloat(self.game.questionSet.count))
        
        if hintUsed <= threshold {
            
            
            if removeOptionsButton.alpha == 0 {
                UIView.animateWithDuration(0.0, delay: 5.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    [unowned self] in
                    self.removeOptionsButton.alpha = 1
                    }) { [unowned self] completed in
                        if completed {
                            if !self.removeOptionsButton.enabled {
                                self.removeOptionsButton.enable()
                            }
                        }
                }
            }
        }
    }
    
    private func produceResultForCurrentQuestion(isCorrect:Bool, score:Int){
        self.questionResults.append(QuestionResult(questionID: currentQuestion.questionID, timeTaken: Float(MAX_ALLOWED_TIME - current_timeLeft), correct: isCorrect, score: score))
    }
    
    func bindGameAndUsers(game:Game, player:THUser, opponent:THUser){
        self.game = game
        
        if game.initiatingPlayer == opponent {
            if game.initiatingPlayerResult != nil {
                self.opponentScore = game.initiatingPlayerResult.rawScore
                self.opponentQuestionCorrect = game.initiatingPlayerResult.questionCorrect
            }
        } else {
            
            if game.opponentPlayerResult != nil {
                self.opponentScore = game.opponentPlayerResult.rawScore
                self.opponentQuestionCorrect = game.opponentPlayerResult.questionCorrect
            }
        }
        
        self.player = player
        self.opponent = opponent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "QuizWinLoseSegue" {
            let vc = segue.destinationViewController as WinLoseViewController
            vc.bindResult(self.game, selfUser: self.player, opponentUser: self.opponent)
        } else if segue.identifier == "PartialQuizResultSegue" {
            let vc = segue.destinationViewController as ResultsViewController
            vc.bindGame(self.game)
        }
    }
    
    private func playSoundEffect(effect:THSoundEffect) {
        switch effect {
        case .CorrectSound:
            var player = AVAudioPlayer.createAudioPlayer("Correct-Bell", extensionName: "caf")
            player.volume = kTHSoundEffectValue
            player.play()
            
        case .WrongSound:
            var player = AVAudioPlayer.createAudioPlayer("Wrong-Buzzer", extensionName: "caf")
            player.volume = kTHSoundEffectValue
            player.play()
        }
    }
    
}