(function () {
    var fps = {
        current: 0,
        last: 0,
        lastUpdated: Date.now(),
        draw: function () {
            PopQuiz.ctx.fillStyle = '#fff';
            PopQuiz.ctx.fillRect(0, 0, 100, 25);
            PopQuiz.ctx.font = '12pt Arial';
            PopQuiz.ctx.fillStyle = '#000';
            PopQuiz.ctx.textBaseline = 'top';
            PopQuiz.ctx.textAlign = "left";
            PopQuiz.ctx.fillText(fps.last + 'fps', 5, 5);
        },
        update: function () {
            fps.current++;
            if (Date.now() - fps.lastUpdated >= 1000) {
                fps.last = fps.current;
                fps.current = 0;
                fps.lastUpdated = Date.now();
            }
        }
    };

    "use strict";
    PopQuiz.GameScene = {
        /**
         * @type {number}
         */
        animFrameId: 0,

        /**
         * @type {PopQuiz.Game}
         */
        game: null,


        /**
         * @type {PopQuiz.QuestionResult[]}
         */
        questionResults: [],
        // time for calculate fps, max on 60 due to rAF
        delta: 0,
        currentTime: 0,
        startTime: 0,
        lastTime: 0,
        basicScorePerQuestion: 1000,
        // game view & game object
        mainWindow: undefined,
        optionSetView: undefined,
        countDownLabel: undefined,
        removeTwoOptionButton: undefined,
        selectedWrongButton: undefined,
        optionButtons: [],
        optionsToRemove: [],

        // timer to keep track status
        countDownTimer: 15.0,
        roundLabelTimer: 0.0,
        removeTwoOptionTimer: 0.0,
        questionViewTimer: 0.0,
        optionSetViewTimer: 0.0,
        delayForNextQuestionTimer: 0.0,

        // alpha value for specific object animation
        roundLabelAlpha: 0.0,
        questionViewAlpha: 0.0,
        optionSetViewAlpha: 0.0,

        // player's score
        selfScore: 0,
        awayScore: 0,
        hintsUsed: 0,
        combo: 0,

        // keep track game status
        roundNumber: 0,
        startNewQuestion: true,
        answerCorrect: false,
        timeout: false,
        countdownTimerStop: true,
        questionLoaded: false,

        /**
         * @type {PopQuiz.Question}
         */
        currentQuestion: null,

        //UI
        /**
         * @type {UI.Label}
         */
        selfPlayerScoreLabel: null,

        init: function (mainWindow) {
            this.mainWindow = mainWindow;
            this.mainWindow.subviews = [];

            // for testing
            this.game = Config.getCurrentGame();
            this.currentQuestion = this.game.questionSet[this.roundNumber];
            if (!$.isEmptyObject(this.game)) {
                this.lastTime = Date.now();
                this.loop();
            }
        },

        loop: function () {

            var animFrameId = 0;
            (function (self) {
                animFrameId = window.requestAnimFrame(function () {
                    self.loop();
                });
            }(this));
            fps.update();
            this.currentTime = Date.now();
            this.delta = (this.currentTime - this.lastTime) / 1000;

            this.load();
            this.update(animFrameId);
            this.render();
            this.lastTime = this.currentTime;
        },

        update: function (animFrameId) {
            // update animation for round label
            this.roundLabelTimer += this.delta;
            UI.View.animate(1.5, 1, this.roundLabelTimer, function () {
                var gameScene = PopQuiz.GameScene;
                gameScene.roundLabelAlpha += gameScene.delta / 1.5;
            }, function () {
                var gameScene = PopQuiz.GameScene;

                if (gameScene.roundLabelAlpha > 0.1) {
                    gameScene.roundLabelAlpha -= gameScene.delta / 1.5;
                } else {
                    gameScene.roundLabelAlpha = 0;
                    gameScene.questionViewTimer += gameScene.delta;

                    // fade in animation for question view
                    UI.View.animate(1, 1, gameScene.questionViewTimer, function () {
                        var gameScene = PopQuiz.GameScene;
                        gameScene.questionViewAlpha += gameScene.delta;
                    }, function () {
                        PopQuiz.GameScene.questionLoaded = true;
                    })
                }
            });

            // fade in option buttons
            if (this.questionLoaded) {
                this.optionSetViewTimer += this.delta;

                UI.View.animate(1, 1, this.optionSetViewTimer, function () {
                    var gameScene = PopQuiz.GameScene;
                    gameScene.optionSetViewAlpha += gameScene.delta;

                    for (var i in gameScene.optionButtons) {
                        if (gameScene.optionButtons.hasOwnProperty(i)) {
                            gameScene.optionButtons[i].alpha = gameScene.optionSetViewAlpha;
                        }
                    }

                }, function () {
                    var gameScene = PopQuiz.GameScene;

                    for (var i in gameScene.optionButtons) {
                        if (gameScene.optionButtons.hasOwnProperty(i)) {
                            gameScene.optionButtons[i].enabled = true;
                        }
                    }

                    if (gameScene.startNewQuestion) {
                        gameScene.startTime = Date.now();
                        gameScene.startNewQuestion = false;
                        gameScene.countdownTimerStop = false;
                    }
                });
            }

            // update animation for countdown timer
            if (!this.startNewQuestion && !this.countdownTimerStop) {
                if (this.countDownTimer > 0.5) {
                    this.countDownTimer = 15 - (this.currentTime - this.startTime) / 1000;
                } else {
                    this.countDownTimer = 0;
                    this.timeout = true;
                }
            }

            // enable remove 2 options button
            if (this.countDownTimer <= 10) {
                this.removeTwoOptionButton.enabled = true;
                this.removeTwoOptionButton.alpha = 1;
            }

            // animation for removing 2 options button from view
            if (this.optionsToRemove.length > 0) {
                this.removeTwoOptionButton.enabled = false;
                this.removeTwoOptionButton.alpha = 0.5;
                this.removeTwoOptionTimer += this.delta;
                UI.View.animate(0.5, 0, this.removeTwoOptionTimer, function () {
                    var gameScene = PopQuiz.GameScene;
                    for (var j in gameScene.optionButtons) {
                        if (gameScene.optionButtons.hasOwnProperty(j)) {
                            if (gameScene.optionButtons[j].label.text === gameScene.optionsToRemove[0].label.text ||
                                gameScene.optionButtons[j].label.text === gameScene.optionsToRemove[1].label.text) {
                                gameScene.optionButtons[j].alpha -= gameScene.removeTwoOptionTimer * 2;
                                gameScene.optionButtons[j].enabled = false;
                            }
                        }
                    }
                }, function () {
                    var gameScene = PopQuiz.GameScene;
                    for (var j in gameScene.optionButtons) {
                        if (gameScene.optionButtons.hasOwnProperty(j)) {
                            if (gameScene.optionButtons[j].label.text === gameScene.optionsToRemove[0].label.text ||
                                gameScene.optionButtons[j].label.text === gameScene.optionsToRemove[1].label.text) {
                                gameScene.optionButtons[j].alpha = 0;
                                gameScene.optionButtons[j].enabled = false;
                            }
                        }
                    }
                });
            }

            // animation for option buttons
            for (var i in this.optionButtons) {
                if (this.optionButtons.hasOwnProperty(i)) {

                    // effect for wrong option is selected
                    if (this.selectedWrongButton !== undefined) {
                        if (this.selectedWrongButton.label.text === this.optionButtons[i].label.text) {
                            this.optionButtons[i].background_color = "rgb(245, 81, 95)";
                        }
                    }

                    // end of the question
                    if (this.selectedWrongButton !== undefined || this.answerCorrect === true || this.timeout === true) {
                        this.optionButtons[i].enabled = false;

                        // effect for showing correct option
                        if (this.optionButtons[i].is_answer) {
                            this.optionButtons[i].background_color = "rgb(180, 236, 81)";

                        }
                    }
                }
            }

            if (!this.startNewQuestion) {
                // end of the question and round
                if (this.selectedWrongButton !== undefined || this.answerCorrect === true || this.timeout === true) {
                    this.removeTwoOptionButton.enabled = false;
                    this.removeTwoOptionButton.alpha = 0.5;
                    this.countdownTimerStop = true;


                    // correct answer is selected by user
                    if (this.answerCorrect === true) {
                        // calculate marks.
                    }

                    if (this.roundNumber < this.game.questionSet.length - 1) {
                        this.delayForNextQuestionTimer += this.delta;
                        UI.View.animate(1, 1, this.delayForNextQuestionTimer, function () {
                            var gameScene = PopQuiz.GameScene;
                            gameScene.questionViewAlpha -= gameScene.delta;
                            gameScene.optionSetViewAlpha = gameScene.questionViewAlpha;

                            for (var i in gameScene.optionButtons) {
                                if (gameScene.optionButtons.hasOwnProperty(i)) {
                                    if (gameScene.optionButtons[i].alpha !== 0) {
                                        gameScene.optionButtons[i].alpha = gameScene.optionSetViewAlpha;
                                    }
                                }
                            }
                        }, function () {
                            var gameScene = PopQuiz.GameScene;
                            gameScene.prepareForNextRound();
                        });
                    } else {
                        // render result scene
                        var cancelAnimationFrame = window.cancelAnimationFrame || window.mozCancelAnimationFrame;
                        cancelAnimationFrame(animFrameId);
                        var res = this.questionResults;
                        Client.postResults(this.game.gameId, res, this.combo, this.hintsUsed);
                    }
                }
            }
        },

        render: function () {
            if (this.optionSetViewAlpha > 0) {
                for (var j in this.optionButtons) {
                    if (this.optionButtons.hasOwnProperty(j)) {
                        this.optionSetView.addSubview(this.optionButtons[j]);
                    }
                }
            }

            this.mainWindow.addSubview(this.removeTwoOptionButton);
            fps.draw();
        },

        load: function () {
            Utility.clearCurrentView();
            this.mainWindow.drawView(PopQuiz.ctx);

            var quizBgImageView = new UI.ImageView(0, 0, PopQuiz.currentWidth, PopQuiz.currentHeight, Assets.images().quiz_bg);
            this.mainWindow.addSubview(quizBgImageView);
            this.setUpRoundLabel();
            this.setUpTopBar();
            this.setUpRemoveTwoOptionButton();

            if (this.questionViewAlpha > 0) {
                this.setUpQuestionViewWithQuestion(this.currentQuestion);
            }
        },

        prepareForNextRound: function () {
            this.startNewQuestion = true;
            this.countDownTimer = 15.0;
            this.roundLabelAlpha = 0.0;
            this.roundLabelTimer = 0.0;
            this.questionViewAlpha = 0.0;
            this.questionViewTimer = 0.0;
            this.optionSetViewAlpha = 0.0;
            this.optionSetViewTimer = 0.0;
            this.removeTwoOptionTimer = 0.0;
            this.removeTwoOptionTimer = 0.0;
            this.delayForNextQuestionTimer = 0.0;
            this.optionButtons = [];
            this.optionsToRemove = [];
            this.answerCorrect = false;
            if(this.timeout){
                //when timeout
                if(this.timeout){
                    console.log('timeout');
                    this.timeout = false;
                    this.combo = 0;
                    var sc = this.calculateScore(false);
                    this.produceResultForCurrentQuestion(false, sc);
                }
            }
            //this.timeout = false;
            this.questionLoaded = false;
            this.selectedWrongButton = undefined;
            this.currentQuestion = this.game.questionSet[++this.roundNumber];
        },

        setUpRoundLabel: function () {
            var mainWindowCenterX = this.mainWindow.width / 2;
            var mainWindowCenterY = this.mainWindow.height / 2;
            var roundLabel = new UI.Label(mainWindowCenterX, mainWindowCenterY, 500, 80, "ROUND " + (this.roundNumber + 1).toString());

            if (this.roundNumber + 1 === this.game.questionSet.length) {
                roundLabel.text = "LAST ROUND";
            }

            roundLabel.font_size = "2.5";
            roundLabel.font_weight = "bold";
            roundLabel.text_color = "rgba(255, 255, 255," + this.roundLabelAlpha + ")";

            this.mainWindow.addSubview(roundLabel);
        },

        setUpTopBar: function () {
            var barBGRatio = Assets.images().bar_bg.width / Assets.images().bar_bg.height;
            var barHeight = PopQuiz.currentWidth / barBGRatio;
            var barBgImageView = new UI.ImageView(0, 0, PopQuiz.currentWidth, barHeight, Assets.images().bar_bg);

            var profilePicRadius = PopQuiz.currentWidth / 8 / 2;
            var profilePicY = barHeight / 2 - profilePicRadius;
            var profilePicCenterY = profilePicY + profilePicRadius;
            var selfProfilePicX = 30;
            var selfPlayerProfilePic = new UI.RoundImageView(selfProfilePicX, profilePicY, profilePicRadius,
                Assets.images().self_pp);
            var selfPlayerScoreLabelX = selfProfilePicX + profilePicRadius * 2 + 20;
            this.selfPlayerScoreLabel = new UI.Label(selfPlayerScoreLabelX, profilePicCenterY, PopQuiz.currentWidth / 5,
                30, this.selfScore.toString());
            this.selfPlayerScoreLabel.text_baseline = "bottom";
            this.selfPlayerScoreLabel.font_weight = "bold";
            this.selfPlayerScoreLabel.font_size = "1.3";
            this.selfPlayerScoreLabel.text_color = "white";
            this.selfPlayerScoreLabel.text_allign = "left";
            var selfPlayerNameLabel = new UI.Label(selfPlayerScoreLabelX, profilePicCenterY, PopQuiz.currentWidth / 4,
                30, Config.getCurrentUserContext().displayName);
            selfPlayerNameLabel.text_baseline = "top";
            selfPlayerNameLabel.font_weight = "normal";
            selfPlayerNameLabel.font_size = "1.3";
            selfPlayerNameLabel.text_color = "white";
            selfPlayerNameLabel.text_allign = "left";

            var awayProfilePicX = PopQuiz.currentWidth - profilePicRadius * 2 - 30;
            var awayPlayerProfilePic = new UI.RoundImageView(awayProfilePicX, profilePicY, profilePicRadius,
                Assets.images().opp_pp);
            var awayPlayerScoreLabelX = awayProfilePicX - 20;
            var awayPlayerScoreLabel = new UI.Label(awayPlayerScoreLabelX, profilePicCenterY, PopQuiz.currentWidth / 5,
                30, this.awayScore.toString());
            awayPlayerScoreLabel.text_baseline = "bottom";
            awayPlayerScoreLabel.font_weight = "bold";
            awayPlayerScoreLabel.font_size = "1.3";
            awayPlayerScoreLabel.text_color = "white";
            awayPlayerScoreLabel.text_allign = "right";
            var awayPlayerNameLabel = new UI.Label(awayPlayerScoreLabelX, profilePicCenterY, PopQuiz.currentWidth / 4,
                30, Config.getOpponentUserContext().displayName);
            awayPlayerNameLabel.text_baseline = "top";
            awayPlayerNameLabel.font_weight = "normal";
            awayPlayerNameLabel.font_size = "1.3";
            awayPlayerNameLabel.text_color = "white";
            awayPlayerNameLabel.text_allign = "right";

            this.countDownLabel = new UI.Label(PopQuiz.currentWidth / 2, 0, 50, 30, this.countDownTimer.toFixed(1).toString());
            this.countDownLabel.text_baseline = "top";

            if (this.countDownTimer < 5) {
                this.countDownLabel.text_color = "red";
            }

            this.mainWindow.addSubview(barBgImageView);
            this.mainWindow.addSubview(selfPlayerProfilePic);
            this.mainWindow.addSubview(awayPlayerProfilePic);
            this.mainWindow.addSubview(this.selfPlayerScoreLabel);
            this.mainWindow.addSubview(selfPlayerNameLabel);
            this.mainWindow.addSubview(awayPlayerScoreLabel);
            this.mainWindow.addSubview(awayPlayerNameLabel);
            this.mainWindow.addSubview(this.countDownLabel);
        },

        setUpRemoveTwoOptionButton: function () {
            var bottomGap = 11;

            if (PopQuiz.ua_isMobile) {
                bottomGap = bottomGap * PopQuiz.ua_mobile_scale;
            }

            var removeTwoOptionButtonWidth = PopQuiz.currentWidth * 0.4;
            var removeTwoOptionButtonHeight = PopQuiz.currentHeight / 14;
            var removeTwoOptionButtonX = PopQuiz.currentWidth / 2 - removeTwoOptionButtonWidth / 2;
            var removeTwoOptionButtonY = PopQuiz.currentHeight - removeTwoOptionButtonHeight - bottomGap;
            this.removeTwoOptionButton = new UI.Button(removeTwoOptionButtonX, removeTwoOptionButtonY,
                removeTwoOptionButtonWidth, removeTwoOptionButtonHeight);
            this.removeTwoOptionButton.label.text = "Remove 2";
            this.removeTwoOptionButton.label.text_color = "white";
            this.removeTwoOptionButton.label.font_size = "1.5";
            this.removeTwoOptionButton.image = Assets.images().remove2;
            var self = this;
            this.removeTwoOptionButton.addTarget(function (sender) {
                //var optionButtons = Utility.array.shuffle(PopQuiz.GameScene.optionButtons);
                var optionButtons = PopQuiz.GameScene.optionButtons.shuffle();
                var count = 0;
                for (var i in optionButtons) {
                    if (optionButtons.hasOwnProperty(i)) {
                        if ((!optionButtons[i].is_answer) && (count < 2)) {
                            PopQuiz.GameScene.optionsToRemove.push(optionButtons[i]);
                            count++;
                        }
                    }
                }
                sender.enabled = false;
                self.hintsUsed++;
            }, "touch");
            this.removeTwoOptionButton.enabled = false;
            this.removeTwoOptionButton.alpha = 0.5;
        },

        setUpQuestionViewWithQuestion: function (question) {
            // init for contentView
            var removeTwoOptionButtonGap = 22;
            if (PopQuiz.ua_isMobile) {
                removeTwoOptionButtonGap *= PopQuiz.ua_mobile_scale;
            }
            var barBGRatio = Assets.images().bar_bg.width / Assets.images().bar_bg.height;
            var barHeight = PopQuiz.currentWidth / barBGRatio;
            var removeTwoOptionButtonHeight = PopQuiz.currentHeight / 14;
            var contentViewX = 0;
            var contentViewY = barHeight;
            var contentViewWidth = PopQuiz.currentWidth;
            var contentViewHeight = (PopQuiz.currentHeight - barHeight - removeTwoOptionButtonHeight - removeTwoOptionButtonGap) / 2;
            var contentView = new UI.View(contentViewX, contentViewY, contentViewWidth, contentViewHeight);
            contentView.background_color = "rgba(0, 0, 0, 0)";
            this.mainWindow.addSubview(contentView);

            if (question.isGraphical()) {
                var contentTextLabelHeight = contentViewHeight * 0.25;
                var contentTextLabelY = contentViewY + contentTextLabelHeight / 2;
                var contentTextLabel = new UI.Label(contentViewWidth / 2, contentTextLabelY, contentViewWidth, 30, question.questionContent);
                contentTextLabel.font_size = "1.5";
                contentTextLabel.text_baseline = "alphabetic";
                contentTextLabel.text_color = "white";
                contentTextLabel.alpha = this.questionViewAlpha;
                contentView.addSubview(contentTextLabel);

                if (question.questionImageURLString !== "") {
                    var questionImage = new Image();
                    questionImage.src = question.questionImageURLString;

                    var contentImageRatio = questionImage.width / questionImage.height;
                    var contentImageViewHeight = (contentViewHeight * 0.75) * 0.9;
                    var contentImageViewWidth = contentImageRatio * contentImageViewHeight;

                    if (contentImageViewWidth > contentViewWidth) {
                        contentImageViewHeight *= 0.5;
                        contentImageViewWidth *= 0.5;
                    }

                    var contentImageViewX = contentViewWidth / 2 - contentImageViewWidth / 2;
                    var contentImageViewY = contentViewY + contentTextLabelHeight + ((contentViewHeight * 0.75 - contentImageViewHeight) / 2);
                    var contentImageView = new UI.ImageView(contentImageViewX, contentImageViewY, contentImageViewWidth,
                        contentImageViewHeight, questionImage);
                    contentImageView.alpha = this.questionViewAlpha;
                    contentView.addSubview(contentImageView);
                }

                switch (question.questionType) {
                    case Type.QuestionType.LogoType:
                        if (question.questionImageURLString !== "") {
                            // TODO filter effect. e.g. swirl effect

                        }
                        break;
                    default :
                        break;
                }
            } else {
                if (question.accesoryImageContent !== "") {
                    contentTextLabelHeight = contentViewHeight * 0.25;
                    contentTextLabelY = contentViewY + contentTextLabelHeight / 2;
                    contentImageViewWidth = contentViewWidth * 0.8;
                    contentImageViewHeight = (contentViewHeight * 0.75) * 0.9;
                    contentImageViewX = contentViewWidth / 2 - contentImageViewWidth / 2;
                    contentImageViewY = contentViewY + contentTextLabelHeight + ((contentViewHeight * 0.75 - contentImageViewHeight) / 2);
                    contentTextLabel = new UI.Label(contentViewWidth / 2, contentTextLabelY, contentViewWidth, 30, question.questionContent);
                    contentTextLabel.font_size = "1.5";
                    contentTextLabel.text_baseline = "alphabetic";
                    contentTextLabel.text_color = "white";
                    contentTextLabel.alpha = this.questionViewAlpha;

                    questionImage = new Image();
                    questionImage.src = question.accesoryImageContent;

                    contentImageView = new UI.ImageView(contentImageViewX, contentImageViewY, contentImageViewWidth,
                        contentImageViewHeight, questionImage);
                    contentImageView.alpha = this.questionViewAlpha;

                    contentView.addSubview(contentTextLabel);
                    contentView.addSubview(contentImageView);
                } else {
                    contentTextLabel = new UI.Label(contentViewWidth / 2, contentViewHeight / 2 + contentViewY, contentViewWidth, 30, question.questionContent);
                    contentTextLabel.font_size = "1.5";
                    contentTextLabel.text_baseline = "middle";
                    contentTextLabel.text_color = "white";
                    contentTextLabel.alpha = this.questionViewAlpha;

                    contentView.addSubview(contentTextLabel);
                }
            }
            this.setUpOptionSetViewWithOption(question.options);
        },

        setUpOptionSetViewWithOption: function (optionSet) {

            var removeTwoOptionButtonGap = 22;

            if (PopQuiz.ua_isMobile) {
                removeTwoOptionButtonGap *= PopQuiz.ua_mobile_scale;
            }
            var barBGRatio = Assets.images().bar_bg.width / Assets.images().bar_bg.height;
            var barHeight = PopQuiz.currentWidth / barBGRatio;
            var removeTwoOptionButtonHeight = PopQuiz.currentHeight / 14;
            var optionSetViewWidth = PopQuiz.currentWidth;
            var optionSetViewHeight = (PopQuiz.currentHeight - barHeight - removeTwoOptionButtonHeight - removeTwoOptionButtonGap) / 2;
            var optionSetViewX = 0;
            var optionSetViewY = barHeight + optionSetViewHeight;
            this.optionSetView = new UI.View(optionSetViewX, optionSetViewY, optionSetViewWidth, optionSetViewHeight);
            this.optionSetView.background_color = "rgba(0, 0, 0, 0.0)";
            this.mainWindow.addSubview(this.optionSetView);

            var optionSetViewMiddleX = optionSetViewX + optionSetViewWidth / 2;
            var optionSetViewMiddleY = optionSetViewY + optionSetViewHeight / 2;
            var optionButtonWidth = Math.abs(optionSetViewX - optionSetViewMiddleX) * 0.9;
            var optionButtonHeight = Math.abs(optionSetViewY - optionSetViewMiddleY) * 0.9;
            var optionButtonOneX = (optionSetViewWidth / 2 - optionButtonWidth) / 2 + optionSetViewX;
            var optionButtonOneY = (optionSetViewHeight / 2 - optionButtonHeight) / 2 + optionSetViewY;
            this.optionButtons = [];
            this.optionButtons.push(new UI.Button(optionButtonOneX, optionButtonOneY, optionButtonWidth, optionButtonHeight));
            this.optionButtons.push(new UI.Button(optionButtonOneX + optionSetViewWidth / 2, optionButtonOneY,
                optionButtonWidth, optionButtonHeight));
            this.optionButtons.push(new UI.Button(optionButtonOneX, optionButtonOneY + optionSetViewHeight / 2,
                optionButtonWidth, optionButtonHeight));
            this.optionButtons.push(new UI.Button(optionButtonOneX + optionSetViewWidth / 2, optionButtonOneY + optionSetViewHeight / 2,
                optionButtonWidth, optionButtonHeight));

            for (var i in this.optionButtons) {
                if (this.optionButtons.hasOwnProperty(i)) {
                    // init for all option button
                    this.optionButtons[i].cornerRadius = 10;
                    this.optionButtons[i].label.text = optionSet.allOption[i].stringContent;
                    this.optionButtons[i].label.font_size = "1.4";
                    this.optionButtons[i].label.text_baseline = "alphabetic";
                    this.optionButtons[i].label.text_color = "rgb(12, 79, 174)";
                    this.optionButtons[i].background_color = "rgb(139, 219, 251)";
                    this.optionButtons[i].enabled = false;

                    // action for wrong option is selected
                    (function (self) {
                        self.optionButtons[i].addTarget(function (sender) {
                            PopQuiz.GameScene.answerWrong = true;
                            PopQuiz.GameScene.selectedWrongButton = sender;
                            self.combo = 0;
                            var sc = self.calculateScore(false);
                            self.produceResultForCurrentQuestion(false, sc);
                        }, "touch");

                        // set up for correct option
                        if (optionSet.allOption[i] === optionSet.correctOption) {
                            self.optionButtons[i].is_answer = true;

                            // action for correct option is selected
                            self.optionButtons[i].addTarget(function () {
                                PopQuiz.GameScene.answerCorrect = true;
                                self.combo++;
                                var sc = self.calculateScore(true);
                                self.produceResultForCurrentQuestion(true, sc);
                            }, "touch");
                        }
                    }(this));

                }
            }
        },

        /**
         *
         * @param questionCorrect
         * @returns {number}
         */
        calculateScore: function (questionCorrect) {
            var timeLeftBonus = this.getTimeBonus(this.countDownTimer);
            var comboBonus = this.getComboBonus();
            var hintPenalty = this.getHintPenalty();
            var correctiveFactor = questionCorrect ? 1.0 : 0.0;
            var score = this.basicScorePerQuestion * timeLeftBonus * correctiveFactor * comboBonus * hintPenalty;
            this.selfScore += score;
            this.selfPlayerScoreLabel.text = this.selfScore.toString();
            return Math.floor(score);
        },

        /**
         *
         * @param correct {Boolean}
         * @param score {number}
         */
        produceResultForCurrentQuestion: function (correct, score) {
            this.questionResults.push(new PopQuiz.QuestionResult(this.currentQuestion.questionId, 15 - this.countDownTimer, correct, score))
        },

        /**
         *
         * @returns {number}
         */
        getHintPenalty: function () {
            switch (this.hintsUsed) {
                case 0:
                    return 1;
                case 1:
                    return 0.75;
                case 2:
                    return 0.5;
                default:
                    return 0.25;
            }
        },

        /**
         *
         * @returns {number}
         */
        getComboBonus: function () {
            switch (this.combo) {
                case 0:
                    return 1;
                case 1:
                    return 1.5;
                case 2:
                    return 2;
                case 3:
                    return 3;
                case 4:
                    return 4;
                default:
                    return 5;
            }
        },

        /**
         *
         * @param timeLeft {number}
         * @returns {number}
         */
        getTimeBonus: function (timeLeft) {
            var timeRange = (15 - timeLeft) / 15.0 * 100;
            switch (true) {
                case ((timeRange >= 0) && (timeRange < 0.5)):
                    return 10;
                case ((timeRange >= 0.5) && (timeRange <= 5)):
                    return 5;
                case ((timeRange >= 5) && (timeRange < 10)):
                    return 2;
                case ((timeRange >= 10) && (timeRange < 20)):
                    return 1.5;
                case ((timeRange >= 20) && (timeRange < 30)):
                    return 1.2;
                case ((timeRange >= 30) && (timeRange < 50)):
                    return 1;
                case ((timeRange >= 50) && (timeRange < 70)):
                    return 0.8;
                case ((timeRange >= 70) && (timeRange < 100)):
                    return 0.4;
                default:
                    return 0;
            }
        }
    }
}());