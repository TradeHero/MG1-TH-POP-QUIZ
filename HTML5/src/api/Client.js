/**
 * Created by rynecheow on 6/2/15.
 */
var Client = (function () {
    // TODO submit result here

    /**
     *
     * @param gameId {number}
     * @param questionResults {PopQuiz.QuestionResult[]}
     * @param combo {number}
     * @param hintsUsed {number}
     * @private
     *
     */
    function _postResults(gameId, questionResults, combo, hintsUsed) {

        /**
         * @type {{questionId: number, time: number, rawScore: number}[]}
         */
        var resultSet = [];

        for (var i = 0; i < questionResults.length; i++) {
            /**
             *
             * @type {PopQuiz.QuestionResult}
             */
            var qRes = questionResults[i];
            resultSet.push({
                "questionId": qRes.questionId,
                "time": qRes.timeTaken,
                "rawScore": qRes.score
            })
        }
        //console.log(resultSet);

        /**
         *
         * @type {{gameId: number, results: {questionId: number, time: number, rawScore: number}[], correctStreak: number, hintsUsed: number}}
         */
        var param = {
            "gameId": gameId,
            "results": resultSet,
            "correctStreak": combo,
            "hintsUsed": hintsUsed
        };

        var method = "POST";

        // The rest of this code assumes you are not using a library.
        // It can be made less wordy if you use one.
        var form = document.createElement("form");
        form.setAttribute("method", method);
        form.setAttribute("action", 'Result');

        var hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", "result");
        hiddenField.setAttribute("value", JSON.stringify(param));

        form.appendChild(hiddenField);

        var token = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", "accessToken");
        hiddenField.setAttribute("value", Config.getAuthToken());

        form.appendChild(token);

        document.body.appendChild(form);
        form.submit();
    }

    return {
        postResults: function (gameId, results, combo, hints) {
            _postResults(gameId, results, combo, hints)
        }
    }
}());