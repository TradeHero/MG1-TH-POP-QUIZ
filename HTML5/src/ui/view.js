(function () {
    "use strict";

    /**
     *
     * @param x
     * @param y
     * @param width
     * @param height
     * @constructor
     */
    UI.View = function View(x, y, width, height) {
        /**
         *
         * @type {number}
         */
        this.x = x;
        /**
         *
         * @type {number}
         */
        this.y = y;
        /**
         *
         * @type {number}
         */
        this.width = width;
        /**
         *
         * @type {number}
         */
        this.height = height;
        /**
         *
         * @type {string}
         */
        this.background_color = "#ffffff";
        /**
         *
         * @type {boolean}
         */
        this.hidden = false;
        /**
         *
         * @type {number}
         */
        this.alpha = 1;
        /**
         *
         * @type {UI.View}
         */
        this.superview = null;
        /**
         *
         * @type {*[]}
         */
        this.subviews = [];
    };

    UI.View.prototype = {
        /**
         *
         * @param view
         */
        addSubview: function (view) {
            view.superview = this;
            this.subviews.push(view);
            view.drawView(PopQuiz.ctx);
        },
        /**
         * Unlinks the view from its superview and its window. If the view’s superview is not nil, the superview releases the view.
         */
        removeFromSuperview: function () {
            if (this.superview != null) {
                var i = this.superview.subviews.indexOf(this);
                if (i != -1) {
                    this.superview.subviews.splice(i, 1);
                }
            }
        },
        /**
         * Draw function can be override by child.
         */
        drawView: function (ctx) {
            ctx.fillStyle = this.background_color;
            ctx.fillRect(this.x, this.y, this.width, this.height);
        }
    };

    UI.View.animate = function (duration, delay, animationTimer, animationsCallBack, completionCallBack) {
        if (delay <= animationTimer) {
            if (animationTimer <= duration + delay) {
                animationsCallBack();
            } else {
                if (completionCallBack !== null) {
                    completionCallBack();
                }
            }
        }

    };
}());

(function () {
    "use strict";

    /**
     *
     * @param x
     * @param y
     * @param width
     * @param height
     * @param image
     * @constructor
     */
    UI.ImageView = function ImageView(x, y, width, height, image) {
        /**
         *
         * super constructor
         */
        UI.View.call(this, x, y, width, height);
        /**
         *
         * @type {Image}
         */
        this.image = image;
    };

    /**
     * inherit from UI.View.prototype
     */
    UI.ImageView.prototype = inherit(UI.View.prototype);

    /**
     *
     * @param ctx
     */
    UI.ImageView.prototype.drawView = function (ctx) {
        ctx.globalAlpha = this.alpha;
        ctx.drawImage(this.image, this.x, this.y, this.width, this.height);
        ctx.globalAlpha = 1.0;
    };
}());

(function () {
    "use strict";

    /**
     *
     * @param x
     * @param y
     * @param radius
     * @param image
     * @constructor
     */
    UI.RoundImageView = function RoundImageView(x, y, radius, image) {
        /**
         *
         * super constructor
         */
        UI.View.call(this, x, y, radius * 2, radius * 2);
        /**
         *
         * @type {number}
         */
        this.radius = radius;
        /**
         *
         * @type {number}
         */
        this.start = 0;
        /**
         *
         * @type {number}
         */
        this.end = Math.PI * 2;
        /**
         *
         * @type {Image}
         */
        this.image = image;
        /**
         *
         * @type {boolean}
         */
        this.anticlockwise = false;
        /**
         *
         * @type {number}
         */
        this.line_width = 10;
        /**
         *
         * @type {string}
         */
        this.line_color = "white";
    };

    /**
     * inherit from UI.View.prototype
     */
    UI.RoundImageView.prototype = inherit(UI.View.prototype);

    /**
     *
     * @param ctx
     */
    UI.RoundImageView.prototype.drawView = function (ctx) {
        ctx.save();
        ctx.beginPath();
        ctx.arc(this.x + this.width / 2, this.y + this.height / 2, this.radius, this.start, this.end, this.anticlockwise);
        ctx.lineWidth = this.line_width;
        ctx.strokeStyle = this.line_color;
        ctx.closePath();
        ctx.stroke();
        ctx.clip();
        ctx.drawImage(this.image, this.x, this.y, this.width, this.height);
        ctx.restore();
    };
}());

(function () {
    "use strict";

    /**
     *
     * @param x
     * @param y
     * @param width
     * @param lineHeight
     * @param text
     * @constructor
     */
    UI.Label = function Label(x, y, width, lineHeight, text) {
        /**
         *
         */
        UI.View.call(this, x, y, width, 0);
        /**
         *
         * @type {number}
         */
        this.lineHeight = lineHeight;
        /**
         *
         * @type {string}
         */
        this.text = text;
        /**
         *
         * @type {string}
         */
        this.font = "Avenir Next";
        /**
         *
         * @type {string}
         */
        this.font_weight = "500";
        /**
         *
         * @type {string}
         */
        this.font_size = "2";
        /**
         *
         * @type {string}
         */
        this.text_color = "#000000";
        /**
         *
         * @type {string}
         */
        this.text_allign = "center";
        /**
         *
         * @type {string}
         */
        this.text_baseline = "middle";
    };

    /**
     * inherit from UI.View.prototype
     */
    UI.Label.prototype = inherit(UI.View.prototype);

    /**
     *
     * @param ctx
     */
    UI.Label.prototype.drawView = function (ctx) {
        ctx.globalAlpha = this.alpha;
        ctx.font = this.font_weight + " " + this.font_size + "em " + this.font;

        if (PopQuiz.ua_isMobile) {
            ctx.font = this.font_weight + " " + this.font_size * PopQuiz.ua_mobile_scale + "em " + this.font;
        }

        ctx.fillStyle = this.text_color;
        ctx.textAlign = this.text_allign;
        ctx.textBaseline = this.text_baseline;
        UI.TextWrap(ctx, this.x, this.y, this.width, this.lineHeight, this.text);
        ctx.globalAlpha = 1.0;
    };

    /**
     *
     * @param ctx
     * @param x
     * @param y
     * @param maxWidth
     * @param lineHeight
     * @param text
     * @constructor
     */
    UI.TextWrap = function (ctx, x, y, maxWidth, lineHeight, text) {
        var words = text.split(' ');
        var line = '', testLine = '';

        if (PopQuiz.ua_isMobile) {
            lineHeight = lineHeight * PopQuiz.ua_mobile_scale;
        }

        for (var i = 0; i < words.length; i++) {
            if (i === 0) {
                testLine = words[i];
            } else {
                testLine = line + ' ' + words[i];
            }

            var metrics = ctx.measureText(testLine);
            var testWidth = metrics.width;

            if (testWidth > maxWidth && i > 0) {
                ctx.fillText(line, x, y);
                line = words[i];
                y += lineHeight;
            }
            else {
                line = testLine;
            }
        }

        ctx.fillText(line, x, y);
    };
}());
