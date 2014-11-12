(function () {
    "use strict";

    /**
     *
     * @type {{TouchEvent: {code: number, state: string}}}
     */
    UI.ControlEvents = {
        TouchEvent: {code: 1, state: "TouchEvent"}
    };

    UI.ControlState = {
        Normal: {code: 1, state: "Normal"},
        Highlighted: {code: 2, state: "Highlighted"},
        Disabled: {code: 3, state: "Disabled"},
        Selected: {code: 4, state: "Selected"}
    };

    UI.Control = function Control(x, y, width, height) {
        /**
         *
         */
        UI.View.call(this, x, y, width, height);
        /**
         *
         * @type {boolean}
         */
        this.enabled = true;
        /**
         *
         * @type {boolean}
         */
        this.selected = false;
        /**
         *
         */
        this.state = UI.ControlState.Normal;

        this.targets = [];
    };

    UI.Control.prototype = inherit(UI.View.prototype);

    UI.Control.prototype.addTarget = function (callback, forEvent) {
        this.targets[forEvent] = callback;
        INPUT.registeredControls.push(this);
    };

    UI.Control.prototype.allTargets = function () {
        return this.targets;
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
     * @constructor
     */
    UI.Button = function Button(x, y, width, height) {
        /**
         *
         */
        UI.Control.call(this, x, y, width, height);
        /**
         *
         * @type {UI.Label}
         */
        this.label = new UI.Label(x + width / 2, y + height / 2, width * 0.9, 30, "button");
        /**
         *
         * @type {boolean}
         */
        this.stroke = false;
        /**
         *
         * @type {number}
         */
        this.cornerRadius = 0;
        /**
         *
         * @type {number}
         */
        this.rotate = 0;
        /**
         *
         * @type {boolean}
         */
        this.is_answer = false;
        /**
         *
         * @type {Image}
         */
        this.image = null;
        /**
         *
         */
        this.state = UI.ControlState.Normal;

        this.targets = [];
    };

    UI.Button.prototype = inherit(UI.Control.prototype);

    UI.Button.prototype.drawView = function (ctx) {
        //if (!this.enabled) {
        //    this.alpha = 0.5;
        //}

        if (this.hidden) {
            this.alpha = 0;
        }

        ctx.globalAlpha = this.alpha;

        if (this.image === null) {
            if (this.cornerRadius != 0) {
                if (PopQuiz.ua_isMobile) {
                    this.cornerRadius *= PopQuiz.ua_mobile_scale;
                }
                ctx.beginPath();
                ctx.moveTo(this.x + this.cornerRadius, this.y);
                ctx.lineTo(this.x + this.width - this.cornerRadius, this.y);
                ctx.quadraticCurveTo(this.x + this.width, this.y, this.x + this.width, this.y + this.cornerRadius);
                ctx.lineTo(this.x + this.width, this.y + this.height - this.cornerRadius);
                ctx.quadraticCurveTo
                (this.x + this.width, this.y + this.height, this.x + this.width - this.cornerRadius, this.y + this.height);
                ctx.lineTo(this.x + this.cornerRadius, this.y + this.height);
                ctx.quadraticCurveTo(this.x, this.y + this.height, this.x, this.y + this.height - this.cornerRadius);
                ctx.lineTo(this.x, this.y + this.cornerRadius);
                ctx.quadraticCurveTo(this.x, this.y, this.x + this.cornerRadius, this.y);
                ctx.closePath();
                if (this.stroke) {
                    ctx.stroke();
                }
                ctx.fillStyle = this.background_color;
                ctx.fill();
            } else {
                ctx.fillStyle = this.background_color;
                ctx.fillRect(this.x, this.y, this.width, this.height);
            }
        } else {
            var imageView = new UI.ImageView(this.x, this.y, this.width, this.height, this.image);
            imageView.alpha = this.alpha;
            this.addSubview(imageView);
        }

        ctx.globalAlpha = 1.0;
        this.label.alpha = this.alpha;
        this.addSubview(this.label);
    }
}());
