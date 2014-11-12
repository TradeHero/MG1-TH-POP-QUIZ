var UTIL = {};

UTIL = {
    version: "0.0.1"
};

(function () {
    "use strict";

    UTIL.isMobile = {
        Android: function () {
            return navigator.userAgent.match(/android/i);
        },
        BlackBerry: function () {
            return navigator.userAgent.match(/blackberry/i);
        },
        iOS: function () {
            return navigator.userAgent.match(/iphone|ipad|ipod/i);
        },
        Opera: function () {
            return navigator.userAgent.match(/opera mini/i);
        },
        Windows: function () {
            return navigator.userAgent.match(/iemobile/i);
        },
        any: function () {
            return (this.Android() || this.BlackBerry() || this.iOS() || this.Opera() || this.Windows());
        }
    };
}());

(function () {
    UTIL.array = {
        shuffle: function (array) {
            for (var j, x, i = array.length; i; j = parseInt(Math.random() * i), x = array[--i], array[i] = array[j], array[j] = x);

            return array;
        }
    }
}());

(function () {
    "use strict";

    UTIL.clearCurrentView = function () {
        var ctx = PopQuiz.ctx;

        // Store the current transformation matrix
        ctx.save();

        // Use the identity matrix while clearing the canvas
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.clearRect(0, 0, PopQuiz.canvas.width, PopQuiz.canvas.height);

        // Restore the transform
        ctx.restore();

        INPUT.registeredControls = [];
    };
}());