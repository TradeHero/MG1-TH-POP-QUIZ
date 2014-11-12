var INPUT = {};

(function () {
    INPUT = {
        x: 0,
        y: 0,
        registeredControls: [],

        trigger: function (data) {
            this.x = (data.pageX - PopQuiz.offset.left) / PopQuiz.scale;
            this.y = (data.pageY - PopQuiz.offset.top) / PopQuiz.scale;
            var control = INPUT.intersect(this.x, this.y);

            if (control !== undefined && control.enabled) {
                control.allTargets()["touch"](control);
            }
        },

        intersect: function (x, y) {
            for (var i in INPUT.registeredControls) {
                if (INPUT.registeredControls.hasOwnProperty(i)) {
                    var view = INPUT.registeredControls[i];
                    var largestX = view.x + view.width;
                    var largestY = view.y + view.height;

                    if ((x <= largestX && y <= largestY) && (x >= view.x && y >= view.y)) {
                        return view;
                    }
                }
            }
            return undefined;
        }
    };
}());
