(function () {
    "use strict";
    PopQuiz.Web = {
        /**
         * @return {string}
         */
        HttpGet: function (url) {
            var xmlHttp;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", url, false);
            xmlHttp.send(null);
            document.write(xmlHttp.responseText);
            return xmlHttp.responseText;
        }
    }
}());