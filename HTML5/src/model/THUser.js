(function () {
    /**
     * Convert json of THUser to object
     * @param profileDTO
     * @constructor
     */
    PopQuiz.THUser = function THUser(profileDTO) {
        /**
         *
         * @type {string}
         */
        this.userId = profileDTO["id"];
        /**
         *
         * @type {string}
         */
        this.firstName = profileDTO["firstName"];
        /**
         *
         * @type {string}
         */
        this.lastName = profileDTO["lastName"];
        /**
         *
         * @type {string}
         */
        this.displayName = profileDTO["displayName"];
        /**
         *
         * @type {string}
         */
        this.pictureURL = profileDTO["picture"];
    };
}() );