(function () {
    /**
     * an array of options
     * @param correctOption
     * @param dummyOptions
     * @constructor
     */
    PopQuiz.OptionSet = function OptionSet(correctOption, dummyOptions) {
        /**
         *
         * @type {PopQuiz.Option}
         */
        this.correctOption = correctOption;
        /**
         *
         * @type {[PopQuiz.Option]}
         */
        this.dummyOptions = dummyOptions;

        var allOption = [];
        for (var i in this.dummyOptions) {
            if (this.dummyOptions.hasOwnProperty(i)) {
                allOption.push(this.dummyOptions[i]);
            }
        }
        allOption.push(correctOption);
        /**
         *
         * @type {[PopQuiz.Option]}
         */
        this.allOption = Utility.array.shuffle(allOption);
    };
}());
