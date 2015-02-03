var Input = {};

(function () {
    Input = {
        x: 0,
        y: 0,
        registeredControls: [],

        trigger: function (data) {
            this.x = (data.pageX - PopQuiz.offset.left) / PopQuiz.scale;
            this.y = (data.pageY - PopQuiz.offset.top) / PopQuiz.scale;
            var control = Input.intersect(this.x, this.y);

            if (control !== undefined && control.enabled) {
                control.allTargets()["touch"](control);
            }
        },

        intersect: function (x, y) {
            for (var i in Input.registeredControls) {
                if (Input.registeredControls.hasOwnProperty(i)) {
                    var view = Input.registeredControls[i];
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
