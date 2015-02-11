var Utility = (function () {

    var _isMobile = (function () {

        var _Android = function () {
                return navigator.userAgent.match(/android/i);
            },
            _BlackBerry = function () {
                return navigator.userAgent.match(/blackberry/i);
            },
            _iOS = function () {
                return navigator.userAgent.match(/iphone|ipad|ipod/i);
            },
            _Opera = function () {
                return navigator.userAgent.match(/opera mini/i);
            },
            _Windows = function () {
                return navigator.userAgent.match(/iemobile/i);
            },
            _any = function () {
                return (_Android() || _BlackBerry() || _iOS() || _Opera() || _Windows());
            };

        //public interface
        return {
            Android: function () {
                return _Android()
            },
            BlackBerry: function () {
                return _BlackBerry();
            },
            iOS: function () {
                return _iOS();
            },
            Opera: function () {
                return _Opera();
            },
            Windows: function () {
                return _Windows();
            },
            any: function () {
                return _any();
            }
        }
    })();

    var _clearCurrentView = function () {
        var ctx = PopQuiz.ctx;

        // Store the current transformation matrix
        ctx.save();

        // Use the identity matrix while clearing the canvas
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.clearRect(0, 0, PopQuiz.canvas.width, PopQuiz.canvas.height);

        // Restore the transform
        ctx.restore();

        Input.registeredControls = [];
    };

    /**
     *
     * @param name {string}
     * @returns {string}
     * @private
     */
    var _getParameterByName = function (name) {
        name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
            results = regex.exec(location.search);
        return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    };

    //public interface
    return {
        version: "0.0.1",
        isMobile: _isMobile,
        clearCurrentView: function () {
            _clearCurrentView()
        },
        /**
         *
         * @param parameterName
         * @returns {string}
         */
        getQueryParameter: function(parameterName){
            return _getParameterByName(parameterName);
        }
    }
})();