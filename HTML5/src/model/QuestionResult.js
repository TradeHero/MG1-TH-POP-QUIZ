(function () {
    /**
     *
     * @param questionId {number}
     * @param timeTaken {number}
     * @param correct {boolean}
     * @param score {number}
     * @constructor
     */
    PopQuiz.QuestionResult = function QuestionResult(questionId, timeTaken, correct, score) {
        /**
         *
         * @type {number}
         */
        this.questionId = questionId;
        /**
         *
         * @type {number}
         */
        this.timeTaken = timeTaken;
        /**
         *
         * @type {boolean}
         */
        this.correct = correct;
        /**
         *
         * @type {number}
         */
        this.score = score;
    }
}());