(function () {
    "use strict";

    PopQuiz.Game = function Game(gameDTO) {
        this.gameId = gameDTO["id"];
        this.createdAtUTCStr = gameDTO["createdAtUtc"];
        this.initiatingPlayerId = gameDTO["createdByUserId"];
        this.opponentPlayerId = gameDTO["opponentUserId"];
        /**
         *
         * @type {PopQuiz.Question[]}
         */
        this.questionSet = [];

        var questionSet = gameDTO["questionSet"];

        for (var i in questionSet) {
            if (questionSet.hasOwnProperty(i)) {
                var questionDTO = questionSet[i];
                this.questionSet.push(new PopQuiz.Question(questionDTO));
            }
        }

        //this.initiatingPlayerResult = new GameResult();
        //this.opponentPlayerResult = new GameResult();
        //this.isGameCompletedByChallenger = false;
        //this.isGameCompletedByOpponent = false;
        //this.initiatingPlayer = new THUser();
        //this.opponentPlayer = new THUser();
        //this.selfPlayer = new THUser();
        //this.awayPlayer = new THUser();
    };

    PopQuiz.Game.prototype = {};
}() );