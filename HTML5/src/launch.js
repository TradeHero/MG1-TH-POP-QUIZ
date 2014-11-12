(function () {
    "use strict";
    PopQuiz.Launch = {
        mainWindow: null,
        mainWindowCenterX: 0,
        mainWindowCenterY: 0,

        init: function (mainWindow) {
            PopQuiz.Launch.mainWindow = mainWindow;
            PopQuiz.Launch.mainWindowCenterX = PopQuiz.Launch.mainWindow.width / 2;
            PopQuiz.Launch.mainWindowCenterY = PopQuiz.Launch.mainWindow.height / 2;
            PopQuiz.Launch.mainWindow.drawView(PopQuiz.ctx);

            var launchBg = new UI.ImageView(0, 0, PopQuiz.currentWidth, PopQuiz.currentHeight, Asset.images.load_bg);
            var logoImageRatio = Asset.images.logo.width / Asset.images.logo.height;
            var logoImageWidth = PopQuiz.Launch.mainWindow.width * 0.8;
            var logoImageHeight = logoImageWidth / logoImageRatio;
            var logoImageX = PopQuiz.Launch.mainWindowCenterX - logoImageWidth / 2;
            var logoImageY = PopQuiz.Launch.mainWindowCenterY - logoImageHeight / 2;
            var logoImage = new UI.ImageView(logoImageX, logoImageY, logoImageWidth, logoImageHeight, Asset.images.logo);

            PopQuiz.Launch.mainWindow.addSubview(launchBg);
            PopQuiz.Launch.mainWindow.addSubview(logoImage);
            PopQuiz.Launch.drawChallengerWindow();
        },

        drawChallengerWindow: function () {
            // init for challenger main window
            var challengerWindowWidth = PopQuiz.Launch.mainWindow.width * 0.8;
            var challengerWindowHeight = PopQuiz.Launch.mainWindow.height * 0.9;
            var challengerWindowX = PopQuiz.Launch.mainWindowCenterX - challengerWindowWidth / 2;
            var challengerWindowY = PopQuiz.Launch.mainWindowCenterY - challengerWindowHeight / 2;
            var challengerWindow = new UI.View(challengerWindowX, challengerWindowY,
                challengerWindowWidth, challengerWindowHeight);

            // init for challenger profile image
            var challengerProfileImageViewRadius = challengerWindowWidth * 0.4 / 2;
            var challengerProfileImageViewX = PopQuiz.Launch.mainWindowCenterX - challengerProfileImageViewRadius;
            var challengerProfileImageViewY = challengerWindow.height * 0.15;
            var challengerProfileImageView = new UI.RoundImageView(challengerProfileImageViewX,
                challengerProfileImageViewY, challengerProfileImageViewRadius, Asset.images.test_profile_pic);

            // init for challenge msg
            var challengeLabelY = challengerProfileImageView.height + challengerProfileImageView.y +
                PopQuiz.Launch.mainWindow.height * 0.1;
            var challengeLabel = new UI.Label(PopQuiz.Launch.mainWindowCenterX, challengeLabelY, challengerWindowWidth,
                70, "James Lai has challenged you!");

            // init for accept challenge button
            var continueButtonWidth = challengerWindow.width * 0.8;
            var continueButtonHeight = continueButtonWidth / 4;
            var continueButtonX = PopQuiz.Launch.mainWindowCenterX - continueButtonWidth / 2;
            var continueButtonY = challengerWindow.height * 0.9 - continueButtonHeight;
            var continueButton = new UI.Button(continueButtonX, continueButtonY, continueButtonWidth,
                continueButtonHeight);
            continueButton.label.text = "Accept Challenge";
            continueButton.addTarget(function () {
                UTIL.clearCurrentView();
                PopQuiz.GameScene.init(PopQuiz.Launch.mainWindow);
                //LocalyticsSession.tagEvent("MG1UserAcceptChallenge");
            }, "touch");

            challengerWindow.background_color = "rgba(117, 168, 239, 0.98)";
            PopQuiz.Launch.mainWindow.addSubview(challengerWindow);
            challengerWindow.addSubview(challengerProfileImageView);
            challengerWindow.addSubview(challengeLabel);
            challengerWindow.addSubview(continueButton);
            console.log("MainWindow");
            console.log(PopQuiz.Launch.mainWindow);
            console.log("ChallengerWindow");
            console.log(challengerWindow);
        }
    }
}());