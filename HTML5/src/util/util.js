Array.prototype.clone = function () {
    return this.slice(0);
};

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

    var _array = (function () {
        var __array = {
            shuffle: function (arr) {
                var clonedArray = arr.clone();
                for (var j, x, i = clonedArray.length; i; j = parseInt(Math.random() * i), x = clonedArray[--i], clonedArray[i] = clonedArray[j], clonedArray[j] = x);

                return clonedArray;
            }
        };
        //public interface
        return {
            shuffle: function (a) {
                return __array.shuffle(a)
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
    //public interface
    return {
        version: "0.0.1",
        isMobile: _isMobile,
        array: _array,
        clearCurrentView: function () {
            _clearCurrentView()
        }
    }
})();