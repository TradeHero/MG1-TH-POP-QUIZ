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
         * @param resolve {Function}
         * @param reject {Function}
         * @private
         *
         */
        function _postResults(gameId, questionResults, combo, hintsUsed, resolve, reject) {

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
            //console.log(param);


            $.ajax({
                url: URI.resultPagePost(),
                type: "POST",
                dataType: "json",
                crossDomain: true,
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify(param),
                cache: false,
                beforeSend: function (xhr) {
                    /////   Authorization header////////
                    xhr.setRequestHeader("Authorization", "TH-Facebook " + Config.getAuthToken());
                },
                success: function (data) {
                    console.log("submitted" + data);
                    resolve(data);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.log("error" + errorThrown);
                    reject(errorThrown);
                }
            }).fail(function () {
                reject(null);
            });
        }

        return {
            postResults: function (gameId, results, combo, hints) {
                return new Promise(function (resolve, reject) {
                    _postResults(gameId, results, combo, hints, resolve, reject)
                });
            }
        }
    }());