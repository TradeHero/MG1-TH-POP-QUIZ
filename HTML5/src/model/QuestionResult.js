(function () {
    /**
     *
     * @param questionId
     * @param timeTaken
     * @param correct
     * @param score
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