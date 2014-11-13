var Input = (function () {
    var _x = 0;
    var _y = 0;
    var _registeredControls = [];

    var _intersect = function (x, y) {
        for (var i in _registeredControls) {
            if (_registeredControls.hasOwnProperty(i)) {
                var view = _registeredControls[i];
                var largestX = view.x + view.width;
                var largestY = view.y + view.height;

                if ((x <= largestX && y <= largestY) && (x >= view.x && y >= view.y)) {
                    return view;
                }
            }
        }
        return undefined;
    };

    var _trigger = function (data) {
        this.x = (data.pageX - PopQuiz.offset.left) / PopQuiz.scale;
        this.y = (data.pageY - PopQuiz.offset.top) / PopQuiz.scale;
        var control = Input.intersect(this.x, this.y);

        if (control !== undefined && control.enabled) {
            control.allTargets()["touch"](control);
        }
    };

    //public interface
    return {
        registeredControls: _registeredControls,
        intersect: function (x, y) {
            _intersect(x, y);
        },
        trigger: function (data) {
            _trigger(data);
        }
    }
})();