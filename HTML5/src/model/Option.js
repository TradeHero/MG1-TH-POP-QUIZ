(function () {
    /**
     * convert json of option to object
     * @param content
     * @constructor
     */
    PopQuiz.Option = function Option(content) {
        /**
         *
         * @type {string}
         */
        this.stringContent = "";
        /**
         *
         * @type {string}
         */
        this.imageContentURLString = "";
        /**
         *
         * @returns {boolean}
         */
        this.isGraphical = function () {
            return this.imageContentURLString !== "";
        };

        var split = content.split("|");
        this.stringContent = split[0];
        this.imageContentURLString = "";
        if (split.length === 2) {
            this.imageContentURLString = split[1];
        }
    };
}() );