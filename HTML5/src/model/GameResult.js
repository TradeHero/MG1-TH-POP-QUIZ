var TypeAlias = {};

(function () {
    TypeAlias.QuestionResultDetail = function QuestionResultDetail(id, rawScore, time) {
        this.id = id;
        this.rawScore = rawScore;
        this.time = time;
    };

    TypeAlias.QuestionResultFinalDetail = function QuestionResultFinalDetail(id, finalScore) {
        this.id = id;
        this.finalScore = finalScore;
    };

    PopQuiz.GameResult = function GameResult(gameId, resultDTO) {
        this.gameId = gameId;
        this.userId = resultDTO["userId"];
        this.score = resultDTO["score"];
        this.details = resultDTO["details"];
        this.extraDetails = resultDTO["finalScores"];
        this.submittedAtUtcString = resultDTO["submittedAtUtc"];
        this.highestCombo = resultDTO["correctStreak"];
        this.hintsUsed = resultDTO["hintsUsed"];

        this.resultDetails = function () {
            var details = this.extraDetails.split("|");
            var questionResultDetails = [];

            for (var i in details) {
                if (details.hasOwnProperty(i)) {
                    var d = details[i].split(", ");
                    var questionResultDetail = new TypeAlias.QuestionResultDetail(d[0], d[1], d[2]);
                    questionResultDetails.push(questionResultDetail);
                }
            }

            return questionResultDetail;
        };

        this.resultExtraDetails = function () {
            if (!this.extraDetails) {
                return undefined
            }
            var details = this.extraDetails.split("|");
            var questionResultFinalDetails = [];

            for (var i in details) {
                if (details.hasOwnProperty(i)) {
                    var d = details[i].split(", ");
                    var questionResultFinalDetail = new TypeAlias.QuestionResultFinalDetail(d[0], d[1]);
                    questionResultFinalDetails.push(questionResultFinalDetail);
                }
            }

            return questionResultFinalDetails;
        };

        this.questionCorrect = function () {
            var correct = 0;
            for (var i in this.resultDetails) {
                if (this.resultDetails.hasOwnProperty(i))
                    if (this.resultDetails[i].rawScore > 0) {
                        correct++
                    }
            }
            return correct
        };

        this.rawScore = function () {
            var rawScore = 0;
            for (var i in this.resultDetails) {
                if (this.resultDetails.hasOwnProperty(i)) {
                    rawScore += this.resultDetails[i]
                }
            }

            return rawScore;
        };

        this.finalScore = function () {
            if (this.resultExtraDetails !== undefined) {
                var finalScore = 0;
                for (var i in this.resultExtraDetails) {
                    if (this.resultExtraDetails.hasOwnProperty(i)) {
                        finalScore += this.resultExtraDetails[i];
                    }
                }

                return finalScore;
            }
            return this.rawScore;
        }
    };
}());