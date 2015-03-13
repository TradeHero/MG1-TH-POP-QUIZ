/**
 * Created by malvin on 3/12/15.
 */
BasicGame.Game = function (game) {
    BasicGame._rawScore = 0;
    BasicGame._hintUsed = 0;
    BasicGame._correctStreak = 0;
    BasicGame._questions = [
        {
            question: "Question1 is a very long question that most likely wraps to the next line",
            image: "http://4.bp.blogspot.com/-QAVpnjM7GSE/TdWXHjU00bI/AAAAAAAAAMQ/h1tDJQDh6Yo/s400/dji-sam-soe.png",
            answers: [{
                id: 10,
                value: 'Option 1 is the correct option'
            }, {
                id: 11,
                value: 'Option 2 is a very long text which wraps to the next line'
            }, {
                id: 12,
                value: 'Option 3 is just another option, nothing special'
            }, {
                id: 14,
                value: 'Option 4 is not a correct option'
            }]
        },
        {
            question: "Question2 is a question that doesn't have an image",
            image: "http://upload.wikimedia.org/wikipedia/en/c/cb/HCA_Company_Logo.png",
            answers: [{
                id: 15,
                value: 'Option 1 is a very long text which wraps to the next line'
            }, {
                id: 16,
                value: 'Option 2 is the correct option'
            }, {
                id: 17,
                value: 'Option 3 is not a correct option'
            }, {
                id: 18,
                value: 'Option 4 is just another option, nothing special'
            }]
        }
    ];
    this._bg = null;

    this._secondsPerRound = 3;
    this._leftTextStyle = {
        "font": "3em " + defaultFont,
        "wordWrap": true,
        "wordWrapWidth": 200,
        "fill": "#fff"
    };
    this._rightStyle = JSON.parse(JSON.stringify(this._leftTextStyle));
    this._rightStyle.align = "right";
    this._timerText = null;
    this._timer = null;

    this._questionField = null;
    this._questionStyle = {
        "font": "4.5em '" + defaultFont + "'",
        "wordWrap": true,
        "wordWrapWidth": 700,
        "fill": "#fff",
        "align": "center",
        "stroke": "#333",
        "strokeThickness": 2
    };
    this._currentQuestion = 0;

    this._image = null;
    this._maxImageHeight = 300;
    this._maxImageWidth = 700;

    //Option Buttons
    this._btnOptions = null;
    this._btnOptionTextStyle = {
        'font': '2.5em ' + defaultFont,
        'fill': 'black',
        'align': 'center',
        'wordWrap': true,
        'wordWrapWidth': 340
    };

    this._btnHint = null;
};

BasicGame.Game.prototype = {
    preload: function () {
        this.load.image('top', '../resources/bar_bg.png');
        this.load.image('background', '../resources/quiz_bg.png');
        this.load.atlas('button_bg', '../resources/button_bg.png', '../resources/button_bg.json');
        this.load.atlas('button_hint', '../resources/button_hint.png', '../resources/button_hint.json');
        var game = this;
        BasicGame._questions.forEach(function (q) {
            //Load image separately
            if (q.image != null) {
                loadExternalUrl(game, q.image);
            }
        });
    },

    create: function () {
        ///Game BG
        this._bg = this.add.image(0, 0, 'background');
        this._bg.width = width;
        this._bg.height = height;

        //Add top BG
        this.add.image(0, 0, 'top');

        //Add info of the user and opponent
        this.add.text(10, 10, "Super King is a super long text", this._leftTextStyle);
        var right = this.add.text(width - 10, 10, "Another super king is looking for you", this._rightStyle);
        right.anchor.set(1, 0);

        //Add timer on top of the screen
        this._timerText = this.add.text(width / 2, 10, formatTime(this._secondsPerRound), {"font": "bold 4em " + defaultFont});
        this._timerText.anchor.set(0.5, 0);

        this._timer = this.time.create(false);

        ///Add Question Text
        this._questionField = this.add.text(width / 2, 250, "", this._questionStyle);
        this._questionField.anchor.set(0.5, 0);

        //Add the image
        this._image = this.add.image(width / 2, 620, '');
        this._image.kill(); //Initially is hidden;
        this._image.anchor.set(0.5, 0.5);

        //Add option button
        this._btnOptions = this.add.group();
        var x1 = 195;
        var x2 = 565;
        var y1 = 920;
        var y2 = 1090;

        var btnOption1 = new LabelButton(this, x1, y1, 'button_bg', "", this._btnOptionTextStyle, this.onOptionButtonClicked, this, "over", "normal", "down");
        var btnOption2 = new LabelButton(this, x2, y1, 'button_bg', "", this._btnOptionTextStyle, this.onOptionButtonClicked, this, "over", "normal", "down");
        var btnOption3 = new LabelButton(this, x1, y2, 'button_bg', "", this._btnOptionTextStyle, this.onOptionButtonClicked, this, "over", "normal", "down");
        var btnOption4 = new LabelButton(this, x2, y2, 'button_bg', "", this._btnOptionTextStyle, this.onOptionButtonClicked, this, "over", "normal", "down");

        this._btnOptions.add(btnOption1);
        this._btnOptions.add(btnOption2);
        this._btnOptions.add(btnOption3);
        this._btnOptions.add(btnOption4);


        //Add hint button
        this._btnHint = new LabelButton(this, width / 2, 1240, 'button_hint', "Remove 2", this._btnOptionTextStyle, this.onHintButtonClicked, this, "over", "normal", "down");
        this._btnHint.anchor.set(0.5, 0.5);
        this._btnHint.inputEnabled = true;

        //Render the question
        this.displayQuestionAndStartTimer();
    },

    update: function () {
        this.updateTimer();
    },

    startTimer: function () {
        if (!this._timer.running) {
            this._timer.add(Phaser.Timer.SECOND * this._secondsPerRound, this.endTimer, this);
            this._timer.start();
        }
    },

    updateTimer: function () {
        if (this._timer != null && this._timer.running) {
            this._timerText.setText(formatTime(Math.round((this._timer.duration.toFixed(0)) / 1000)));
        }
    },

    endTimer: function () {
        this._timer.stop();
        this.checkAnswer();
    },

    nextRound: function () {
        this.cleanUpQuestion();
        this.nextQuestion();
    },

    nextQuestion: function () {
        this._currentQuestion++;
        this._currentQuestion = this._currentQuestion % BasicGame._questions.length;
        this._timerText.setText(formatTime(this._secondsPerRound));
        this.displayQuestionAndStartTimer();
    },

    cleanUpQuestion: function () {
        //Retore options
        //Hide image
        this._image.kill();

        this._btnOptions.setAll('inputEnabled', true);
        this._btnOptions.setAll('freezeFrames', false);
        this._btnOptions.setAll('frameName', 'normal');
        this._btnOptions.setAll('alpha', 1);

        if (!this._btnHint.alive) {
            this._btnHint.frameName = "normal";//Restore to normal state
            this._btnHint.revive();
        }
        this._btnHint.inputEnabled = true;
        this._btnHint.alpha = 1;
    },

    resizeToImage: function (key) {
        if (this.cache.checkImageKey(key)) {
            var image = this.cache.getImage(key);
            console.log(image);
            console.log("image width: " + image.width + "; image height: " + image.height);
            var oriImageWidth = image.width;
            var oriImageHeight = image.height;
            var adjustedHeight = oriImageHeight;
            var adjustedWidth = oriImageWidth;
            var aspectRatio = oriImageHeight / oriImageWidth;

            if (oriImageHeight != this._maxImageHeight) {
                adjustedHeight = this._maxImageHeight;
                adjustedWidth = adjustedHeight / aspectRatio;
            }

            if (adjustedWidth > this._maxImageWidth) {
                adjustedWidth = this._maxImageWidth;
                adjustedHeight = adjustedWidth * aspectRatio;
            }

            this._image.width = adjustedWidth;
            this._image.height = adjustedHeight;

            console.log("image adjusted width: " + adjustedWidth + "; image adjusted height: " + adjustedHeight);

        }
    },

    displayQuestionAndStartTimer: function () {
        var q = BasicGame._questions[this._currentQuestion];
        var s = q.question;
        this._questionField.setText(s);
        if (q.image != null) {
            if (this._image.key != q.image && this.cache.checkImageKey(q.image)) {
                this._image.loadTexture(q.image);
                this.resizeToImage(q.image);
            }
            if (!this._image.alive) {
                this._image.revive();
            }
        } else {
            if (this._image.alive) {
                this._image.kill();
            }
        }

        var as = q.answers;
        for (var i = 0; i < as.length && i < this._btnOptions.length; i++) {
            var a = as[i];
            var o = this._btnOptions.getChildAt(i);
            o.answer = a;
            o.setLabel(a.value);
        }

        this.startTimer();
    },

    checkAnswer: function (answerId, button) {
        var isCorrect = false;
        if (answerId !== undefined || button !== undefined) {
            //Update is correct
        }

        if (!isCorrect) {
            if (button) {
                button.frameName = 'wrong';
                button.freezeFrames = true;
            }
            showCorrectOption(this);
        }

        this._btnOptions.setAll('freezeFrames', true);
        this._btnOptions.setAll('inputEnabled', false);

        var game = this;
        var bg = this._bg;
        this._bg.inputEnabled = true;
        this._bg.input.priorityId = 1;

        this._bg.events.onInputDown.addOnce(function () {
            game.nextRound();
            bg.input.inputEnabled = false;
        });

        this._btnHint.inputEnabled = false;

        function showCorrectOption(game) {
            game._btnOptions.forEach(function () {
                var correctOption = game._btnOptions.getChildAt(0);
                correctOption.frameName = 'correct';
            });
        }
    },

    onOptionButtonClicked: function (button, pointer, isOver) {
        if (isOver) {
            this._timer.stop();
            var answer = button.answer;
            this.checkAnswer(answer.id, button);
        }
    },

    onHintButtonClicked: function (button, pointer, isOver) {
        if (isOver) {
            button.inputEnabled = false; //Prevent second click

            var firstButton = this._btnOptions.getChildAt(1);
            var secondButton = this._btnOptions.getChildAt(2);

            var firstButtonTween = this.add.tween(firstButton).to({alpha: 0}, 300, Phaser.Easing.Cubic.InOut);
            var secondButtonTween = this.add.tween(secondButton).to({alpha: 0}, 300, Phaser.Easing.Cubic.InOut);

            var hintButtonTween = this.add.tween(button).to({alpha: 0}, 300, Phaser.Easing.Cubic.InOut);

            firstButtonTween.start();
            secondButtonTween.start();
            hintButtonTween.start();
        }
    }
};

function formatTime(s) {
    return ("0" + s).substr(-2);
}