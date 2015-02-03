/**
 * Created by rynecheow on 17/11/14.
 */

/**
 * http://paulirish.com/2011/requestanimationframe-for-smart-animating
 * shim layer with setTimeout fallback
 */
window.requestAnimFrame = (function () {
    return window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame ||
        window.oRequestAnimationFrame ||
        window.msRequestAnimationFrame ||

        function (callback) {
            window.setTimeout(callback, 1000 / 60);
        };
})();

/**
 * Inheritance
 *
 * @param proto prototype to inherit
 * @returns {inherit.F}
 */
function inherit(proto) {
    function F() {
    }

    F.prototype = proto;
    return new F;
}

/**
 * Overwrites obj1's values with obj2's and adds obj2's if non existent in obj1
 * @param object_1
 * @param object_2
 * @returns {{}}
 */
function merge(object_1, object_2) {
    "use strict";
    var object_3 = {};
    for (var attr1 in object_1) {
        object_3[attr1] = object_1[attr1];
    }
    for (var attr2 in object_2) {
        object_3[attr2] = object_2[attr2];
    }
    return object_3;
}


var Assets = (function () {
    "use strict";
    var _debug = function (message) {
        console.debug("[assets.js] " + (new Date()).toLocaleTimeString() + " >>> " + message);
    };
    var _initialise = function (images, completionCallback) {
        _images = images;
        _finished = completionCallback;
    };

    var _finished;
    var _images = {};

    var _numberOfAssetsLoaded = 0; // how many assets have been loaded

    var _assetsCount = function () {
        return Object.keys(_images).length;
    };  // total number of assets

    /**
     * Ensure all assets are loaded before using them
     * @param dic  - Dictionary name ('images')
     * @param name - Asset name in the dictionary
     */
    var _assetDidLoad = function (dic, name) {

        // don't count assets that have already loaded
        if (dic[name].status !== "loading") {
            return;
        }

        dic[name].status = "loaded";
        _debug(++_numberOfAssetsLoaded + "/" + Object.keys(_images).length + " asset(s) loaded.");
        // finished callback
        if (_numberOfAssetsLoaded === _assetsCount() && typeof _finished === "function") {
            _debug("All assets are successfully loaded.");
            _finished();
        }
    };

    /**
     * Create assets, set callback for asset loading, set asset source
     */
    var _downloadAll = function () {
        var loadImage = function(img, src){
            _images[img] = new Image();
            _images[img].status = "loading";
            _images[img].name = img;
            _images[img].onload = function () {
                _assetDidLoad(_images, img);
            };

            _images[img].src = src;
        };

        _debug("Begin to load images..");
        // load images
        for (var img in _images) {
            if (_images.hasOwnProperty(img)) {
                loadImage(img, _images[img]);
            }
        }
    };

    return {
        /**
         *
         * @param images Dictionary of images in the format imageName -> url
         * @param callback Callback when all assets are successfully loaded
         */
        initialise: function (images, callback) {
            return _initialise(images, callback);
        },
        /**
         *
         * @returns {{}}
         */
        images: function () {
            return _images;
        },
        /**
         *  Begin loading all images
         */
        beginLoad: _downloadAll
    };

})();




/**
 * Created by rynecheow on 13/11/14.
 */

/**
 * Utility object
 */
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

    //public interface
    return {
        isMobile: _isMobile
    }

})();


/**
 * Created by rynecheow on 13/11/14.
 */



var THCanvas = (function (width, height) {
    var _aspect_ratio = width / height;

    var _canvas = document.createElement("canvas");
    _canvas.width = width;
    _canvas.height = height;

    var _ctx = _canvas.getContext("2d");

    return {
        ctx: _ctx
    }
})(800, 600);



/**
 * Created by rynecheow on 13/11/14.
 */

/**
 * UI Object
 */
var UI = (function () {
    "use strict";

    /**
     * UI.View constructor
     *
     * @param x x-coordinates of origin
     * @param y y-coordinates of origin
     * @param width Width of view
     * @param height Height of view
     * @param ctx Canvas context to render view on
     * @constructor
     */
    var _view = function View(x, y, width, height, ctx) {
        /**
         * Context in render.
         * @type {CanvasRenderingContext2D|*}
         */
        var _ctx = ctx;

        /**
         * Current context in render.
         * @returns {CanvasRenderingContext2D|*}
         */
        this.getContext = function () {
            return _ctx
        };
        /**
         * x-coordinates of the top-left corner
         * @type {number}
         */
        this.x = x;
        /**
         * y-coordinates of the top-left corner
         * @type {number}
         */
        this.y = y;
        /**
         * Width of view
         * @type {number}
         */
        this.width = width;
        /**
         * Height of view
         * @type {number}
         */
        this.height = height;
        /**
         * Background color of view
         * @type {string}
         */
        this.background_color = "white";
        /**
         * Hidden
         * @type {boolean}
         */
        this.hidden = false;
        /**
         * Alpha component of view (not color)
         * @type {number}
         */
        this.alpha = 1;
        /**
         * Parent view of this view instance
         * @type {View}
         */
        this.superview = null;
        /**
         *
         * @type {Array}
         */
        this.subviews = [];

        this.zIndex = 0;
    };
    _view.prototype = (function () {
        return {
            /**
             * Add subview to current view.
             *
             * @param viewToAdd
             */
            addSubview: function (viewToAdd) {
                viewToAdd.superview = this;
                this.subviews.push(viewToAdd);
                viewToAdd.zIndex = this.zIndex++;
                viewToAdd.draw();
            },

            /**
             * Remove subview from its superview
             */
            removeFromSuperview: function () {
                if (this.superview != null) {
                    var i = this.superview.subviews.indexOf(this);
                    if (i != -1) {
                        this.superview.subviews.splice(i, 1);
                    }
                }
            },

            draw: function () {
                var ctx = this.getContext();
                ctx.fillStyle = this.background_color;
                ctx.fillRect(this.x, this.y, this.width, this.height);
            }
        }
    })();

    /**
     * UI.ImageView constructor
     *
     * @param x x-coordinates of origin
     * @param y y-coordinates of origin
     * @param width Width of view
     * @param height Height of view
     * @param ctx Canvas context to render view on
     * @param image Image to draw on view
     * @constructor
     */
    var _imageview = function ImageView(x, y, width, height, image, ctx) {
        /**
         *
         * super constructor
         */
        _view.call(this, x, y, width, height, ctx);
        /**
         *
         * @type {Image}
         */
        this.image = image;
    };
    _imageview.prototype = merge(inherit(_view.prototype), (function () {
        return {
            draw: function () {
                var ctx = this.getContext();
                ctx.globalAlpha = this.alpha;
                ctx.drawImage(this.image, this.x, this.y, this.width, this.height);
                ctx.globalAlpha = 1.0;
            }
        }
    })());


    /**
     * UI.RoundImageView constructor
     *
     * @param x x-coordinates of origin
     * @param y y-coordinates of origin
     * @param radius Radius of view
     * @param ctx Canvas context to render view on
     * @param image Image to draw on view
     * @constructor
     */
    var _roundimageview = function RoundImageView(x, y, radius, image, ctx) {
        /**
         *
         * super constructor
         */
        _view.call(this, x, y, radius * 2, radius * 2, ctx);
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
    _roundimageview.prototype = merge(inherit(_view.prototype), (function () {
        return {
            draw: function () {
                var ctx = this.getContext();
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
            }
        }
    })());

    /**
     * UI.Label constructor
     *
     * @param x x-coordinates of origin
     * @param y y-coordinates of origin
     * @param width Width of view
     * @param lineHeight Height of line
     * @param text Label text
     * @param ctx
     * @constructor
     */
    var _label = function Label(x, y, width, lineHeight, text, ctx) {
        /**
         *
         */
        _view.call(this, x, y, width, 0, ctx);
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
    _label.prototype = merge(inherit(_view.prototype), (function () {
        return {
            draw: function () {
                var ctx = this.getContext();
                ctx.globalAlpha = this.alpha;
                ctx.font = this.font_weight + " " + this.font_size + "em " + this.font;

                //TODO: scale

                ctx.fillStyle = this.text_color;
                ctx.textAlign = this.text_allign;
                ctx.textBaseline = this.text_baseline;
                _wrapText(ctx, this.x, this.y, this.width, this.lineHeight, this.text);
                ctx.globalAlpha = 1.0; // reset global alpha
            }
        }
    })());

    /**
     *
     * @type {{TouchStart: {code: number, event: string}, TouchEnd: {code: number, event: string}, TouchMove: {code: number, event: string}, Click: {code: number, event: string}, MouseDown: {code: number, event: string}, MouseUp: {code: number, event: string}, MouseMove: {code: number, event: string}, fromRaw: Function}}
     * @private
     */
    var _controlEvents = {
        TouchStart: {code: 1, event: "touchstart"},
        TouchEnd: {code: 2, event: "touchend"},
        TouchMove: {code: 3, event: "touchmove"},
        Click: {code: 4, event: "click"},
        MouseDown: {code: 5, event: "mousedown"},
        MouseUp: {code: 6, event: "mouseup"},
        MouseMove: {code: 7, event: "mousemove"},
        fromRaw: function (eventName) {
            switch (eventName) {
                case "touchstart":
                    return this.TouchStart;
                case "touchend:":
                    return this.TouchEnd;
                case "touchmove:":
                    return this.TouchMove;
                case "click:":
                    return this.Click;
                case "mouseup:":
                    return this.MouseUp;
                case "mousedown:":
                    return this.MouseDown;
                case "mousemove:":
                    return this.MouseMove;
                default:
                    return null;
            }
        }
    };

    /**
     * UI.Control constructor
     *
     * @param x x-coordinates of origin
     * @param y y-coordinates of origin
     * @param width Width of view
     * @param height Height of view
     * @param ctx Canvas context to render view on
     * @constructor
     */
    var _control = function Control(x, y, width, height, ctx) {
        _view.call(this, x, y, width, height, ctx);
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

        this.targets = [];
    };
    _control.prototype = merge(inherit(_view.prototype), (function () {
        return {
            /**
             *
             * @param action
             * @param forEvent
             */
            addTarget: function (action, forEvent) {
                this.targets[forEvent] = action;
                var self = this;
                window.addEventListener('mouseup', function (e) {
                    self.triggerTouch(e);
                });
                //Input.registeredControls.push(this);
            },
            allTargets: function () {
                return this.targets;
            },
            triggerTouch: function (jsevent) {
                console.debug("jsevent triggered" + jsevent);
                var x = jsevent.pageX - this.getContext().canvas.offsetLeft;
                var y = jsevent.pageY - this.getContext().canvas.offsetTop;
                if (this.enabled && _intesect(this, x, y)) {
                    this.targets["touch"]()
                }
            },
            triggerDrag: function(startX, startY, endX, endY, duration){

            }
        }
    })());

    /**
     * UI.Button constructor
     * @param x x-coordinates of origin
     * @param y y-coordinates of origin
     * @param width Width of view
     * @param height Height of view
     * @param ctx Canvas context to render view on
     * @constructor
     */
    var _button = function Button(x, y, width, height, ctx) {
        /**
         *
         */
        _control.call(this, x, y, width, height, ctx);

        /**
         *
         * @type {_label}
         */
        this.label = new _label(x + width / 2, y + height / 2, width * 0.9, 80, "Button", ctx);
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

        this.targets = [];
    };
    _button.prototype = merge(inherit(_control.prototype), (function () {
        return {
            draw: function () {
                var ctx = this.getContext();
                if (this.hidden) {
                    this.alpha = 0;
                }

                ctx.globalAlpha = this.alpha;

                if (this.image === null) {
                    if (this.cornerRadius != 0) {
                        //if (PopQuiz.ua_isMobile) {
                        //    this.cornerRadius *= PopQuiz.ua_mobile_scale;
                        //}
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
                    var imageView = new _imageview(this.x, this.y, this.width, this.height, this.image, ctx);
                    imageView.alpha = this.alpha;
                    this.addSubview(imageView);
                }

                ctx.globalAlpha = 1.0;
                this.label.alpha = this.alpha;
                this.addSubview(this.label);
            }
        }
    })());

    //Private functions

    /**
     * Wraps text and cap text within provided width and line height.
     *
     * @param ctx Current context
     * @param x x-coordinates of label
     * @param y y-coordinates of label
     * @param maxWidth Maximum width of label
     * @param lineHeight Line height defined for label
     * @param text Label text
     * @private
     */
    var _wrapText = function (ctx, x, y, maxWidth, lineHeight, text) {
        var words = text.split(' ');
        var line = '', testLine = '';

        //if (PopQuiz.ua_isMobile) {
        //    lineHeight = lineHeight * PopQuiz.ua_mobile_scale;
        //}

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

    /**
     * Animate view with a specified duration and delay
     *
     * @param duration Duration of animation
     * @param delay Delay before animation starts
     * @param animationTimer Designated timer for animation
     * @param animationsCallBack Function that executes animation
     * @param completionCallBack Function that executes while animation completes with delay
     * @private
     */
    var _animateView = function (duration, delay, animationTimer, animationsCallBack, completionCallBack) {
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


    var _intesect = function(control, x, y){
        var largestX = control.x + control.width;
        var largestY = control.y + control.height;

        return !!((x <= largestX && y <= largestY) && (x >= control.x && y >= control.y));
    };

    //UI Factory

    /**
     * Creates a UI Factory that generates view based on a HTML5 canvas context.
     * @param ctx
     * @constructor
     */
    var _uifactory = function Factory(ctx) {

        /**
         * Context in render.
         * @type {CanvasRenderingContext2D|*}
         * @private
         */
        var _ctx = ctx;

        /**
         * Base view to draw on on this context
         *
         * @type {_view}
         * @private
         */
        var _baseView = new _view(0, 0, ctx.canvas.width, ctx.canvas.height, ctx);
        _baseView.draw();
        /**
         * Current context in render.
         * @returns {CanvasRenderingContext2D|*}
         */
        this.getContext = function () {
            return _ctx
        };

        /**
         *
         * @returns {_view}
         */
        this.getBaseView = function () {
            return _baseView;
        };
    };
    _uifactory.prototype = (function () {
        "use strict";

        return {
            /**
             * Create view on current factory context
             *
             * @param x x-coordinates of origin
             * @param y y-coordinates of origin
             * @param width Width of view
             * @param height Height of view
             */
            createView: function (x, y, width, height) {
                return new _view(x, y, width, height, this.getContext());
            },

            /**
             * Create image view on current factory context
             *
             * @param x x-coordinates of origin
             * @param y y-coordinates of origin
             * @param width Width of view
             * @param height Height of view
             * @param image Image to draw on image view
             * @returns {_imageview}
             */
            createImageView: function (x, y, width, height, image) {
                return new _imageview(x, y, width, height, image, this.getContext());
            },

            /**
             * Create a rounded image view on current factory context
             * @param x x-coordinates of origin
             * @param y y-coordinates of origin
             * @param radius Radius of view
             * @param image Image to draw on image view
             * @returns {_roundimageview}
             */
            createRoundImageView: function (x, y, radius, image) {
                return new _roundimageview(x, y, radius, image, this.getContext());
            },

            /**
             * Create a label on current factory context
             *
             * @param x x-coordinates of origin
             * @param y y-coordinates of origin
             * @param width Width of view
             * @param lineHeight Height of line
             * @param text Label text
             * @returns {_label}
             */
            createLabel: function (x, y, width, lineHeight, text) {
                return new _label(x, y, width, lineHeight, text, this.getContext());
            },

            /**
             * Create a button on current factory context
             *
             * @param x x-coordinates of origin
             * @param y y-coordinates of origin
             * @param width Width of view
             * @param height Height of view
             * @returns {_button}
             */
            createButton: function (x, y, width, height) {
                return new _button(x, y, width, height, this.getContext())
            }
        }
    })();


    return {
        /**
         * Creates a UI Factory that generates view based on a HTML5 canvas context.
         * @param ctx
         * @returns {_uifactory}
         */
        createFactory: function (ctx) {
            return new _uifactory(ctx);
        },
        /**
         * Animate view with a specified duration and delay
         *
         * @param duration Duration of animation
         * @param delay Delay before animation starts
         * @param animationTimer Designated timer for animation
         * @param animationsCallBack Function that executes animation
         * @param completionCallBack Function that executes while animation completes with delay
         * @private
         */
        animateView: function (duration, delay, animationTimer, animationsCallBack, completionCallBack) {
            return _animateView(duration, delay, animationTimer, animationsCallBack, completionCallBack);
        },

        ControlEvents: _controlEvents
    };
})();


/**
 * Created by rynecheow on 13/11/14.
 */

var Network = (function(root){

    var _exports = {};

    var _parse = function (req) {
        var result;
        try {
            result = JSON.parse(req.responseText);
        } catch (e) {
            result = req.responseText;
        }
        return [result, req];
    };

    var _xhr = function (type, url, data) {
        var methods = {
            success: function () {
            },
            error: function () {
            }
        };

        var XHR = root.XMLHttpRequest || ActiveXObject;
        var request = new XHR('MSXML2.XMLHTTP.3.0');
        request.open(type, url, true);
        request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        request.onreadystatechange = function () {
            if (request.readyState === 4) {
                if (request.status === 200) {
                    methods.success.apply(methods, _parse(request));
                } else {
                    methods.error.apply(methods, _parse(request));
                }
            }
        };
        request.send(data);
        return {
            success: function (callback) {
                methods.success = callback;
                return methods;
            },
            error: function (callback) {
                methods.error = callback;
                return methods;
            }
        };
    };

    _exports['get'] = function (src) {
        return _xhr('GET', src);
    };

    _exports['put'] = function (url, data) {
        return _xhr('PUT', url, data);
    };

    _exports['post'] = function (url, data) {
        return _xhr('POST', url, data);
    };

    _exports['delete'] = function (url) {
        return _xhr('DELETE', url);
    };

    return _exports;
})(this);



/**
 * Created by rynecheow on 14/1/15.
 */

var UniqueIdCookieManager = (function () {
    (function() {
        var _global = this;

        // Unique ID creation requires a high quality random # generator.  We feature
        // detect to determine the best RNG source, normalizing to a function that
        // returns 128-bits of randomness, since that's what's usually required
        var _rng;

        // Node.js crypto-based RNG - http://nodejs.org/docs/v0.6.2/api/crypto.html
        //
        // Moderately fast, high quality
        if (typeof(_global.require) == 'function') {
            try {
                var _rb = _global.require('crypto').randomBytes;
                _rng = _rb && function() {return _rb(16);};
            } catch(e) {}
        }

        if (!_rng && _global.crypto && crypto.getRandomValues) {
            // WHATWG crypto-based RNG - http://wiki.whatwg.org/wiki/Crypto
            //
            // Moderately fast, high quality
            var _rnds8 = new Uint8Array(16);
            _rng = function whatwgRNG() {
                crypto.getRandomValues(_rnds8);
                return _rnds8;
            };
        }

        if (!_rng) {
            // Math.random()-based (RNG)
            //
            // If all else fails, use Math.random().  It's fast, but is of unspecified
            // quality.
            var  _rnds = new Array(16);
            _rng = function() {
                for (var i = 0, r; i < 16; i++) {
                    if ((i & 0x03) === 0) r = Math.random() * 0x100000000;
                    _rnds[i] = r >>> ((i & 0x03) << 3) & 0xff;
                }

                return _rnds;
            };
        }

        // Buffer class to use
        var BufferClass = typeof(_global.Buffer) == 'function' ? _global.Buffer : Array;

        // Maps for number <-> hex string conversion
        var _byteToHex = [];
        var _hexToByte = {};
        for (var i = 0; i < 256; i++) {
            _byteToHex[i] = (i + 0x100).toString(16).substr(1);
            _hexToByte[_byteToHex[i]] = i;
        }

        // **`parse()` - Parse a UUID into it's component bytes**
        function parse(s, buf, offset) {
            var i = (buf && offset) || 0, ii = 0;

            buf = buf || [];
            s.toLowerCase().replace(/[0-9a-f]{2}/g, function(oct) {
                if (ii < 16) { // Don't overflow!
                    buf[i + ii++] = _hexToByte[oct];
                }
            });

            // Zero out remaining bytes if string was short
            while (ii < 16) {
                buf[i + ii++] = 0;
            }

            return buf;
        }

        // **`unparse()` - Convert UUID byte array (ala parse()) into a string**
        function unparse(buf, offset) {
            var i = offset || 0, bth = _byteToHex;
            return  bth[buf[i++]] + bth[buf[i++]] +
                bth[buf[i++]] + bth[buf[i++]] + '-' +
                bth[buf[i++]] + bth[buf[i++]] + '-' +
                bth[buf[i++]] + bth[buf[i++]] + '-' +
                bth[buf[i++]] + bth[buf[i++]] + '-' +
                bth[buf[i++]] + bth[buf[i++]] +
                bth[buf[i++]] + bth[buf[i++]] +
                bth[buf[i++]] + bth[buf[i++]];
        }

        // **`v1()` - Generate time-based UUID**
        //
        // Inspired by https://github.com/LiosK/UUID.js
        // and http://docs.python.org/library/uuid.html

        // random #'s we need to init node and clockseq
        var _seedBytes = _rng();

        // Per 4.5, create and 48-bit node id, (47 random bits + multicast bit = 1)
        var _nodeId = [
            _seedBytes[0] | 0x01,
            _seedBytes[1], _seedBytes[2], _seedBytes[3], _seedBytes[4], _seedBytes[5]
        ];

        // Per 4.2.2, randomize (14 bit) clockseq
        var _clockseq = (_seedBytes[6] << 8 | _seedBytes[7]) & 0x3fff;

        // Previous uuid creation time
        var _lastMSecs = 0, _lastNSecs = 0;

        // See https://github.com/broofa/node-uuid for API details
        function v1(options, buf, offset) {
            var i = buf && offset || 0;
            var b = buf || [];

            options = options || {};

            var clockseq = options.clockseq != null ? options.clockseq : _clockseq;

            // UUID timestamps are 100 nano-second units since the Gregorian epoch,
            // (1582-10-15 00:00).  JSNumbers aren't precise enough for this, so
            // time is handled internally as 'msecs' (integer milliseconds) and 'nsecs'
            // (100-nanoseconds offset from msecs) since unix epoch, 1970-01-01 00:00.
            var msecs = options.msecs != null ? options.msecs : new Date().getTime();

            // Per 4.2.1.2, use count of uuid's generated during the current clock
            // cycle to simulate higher resolution clock
            var nsecs = options.nsecs != null ? options.nsecs : _lastNSecs + 1;

            // Time since last uuid creation (in msecs)
            var dt = (msecs - _lastMSecs) + (nsecs - _lastNSecs)/10000;

            // Per 4.2.1.2, Bump clockseq on clock regression
            if (dt < 0 && options.clockseq == null) {
                clockseq = clockseq + 1 & 0x3fff;
            }

            // Reset nsecs if clock regresses (new clockseq) or we've moved onto a new
            // time interval
            if ((dt < 0 || msecs > _lastMSecs) && options.nsecs == null) {
                nsecs = 0;
            }

            // Per 4.2.1.2 Throw error if too many uuids are requested
            if (nsecs >= 10000) {
                throw new Error('uuid.v1(): Can\'t create more than 10M uuids/sec');
            }

            _lastMSecs = msecs;
            _lastNSecs = nsecs;
            _clockseq = clockseq;

            // Per 4.1.4 - Convert from unix epoch to Gregorian epoch
            msecs += 12219292800000;

            // `time_low`
            var tl = ((msecs & 0xfffffff) * 10000 + nsecs) % 0x100000000;
            b[i++] = tl >>> 24 & 0xff;
            b[i++] = tl >>> 16 & 0xff;
            b[i++] = tl >>> 8 & 0xff;
            b[i++] = tl & 0xff;

            // `time_mid`
            var tmh = (msecs / 0x100000000 * 10000) & 0xfffffff;
            b[i++] = tmh >>> 8 & 0xff;
            b[i++] = tmh & 0xff;

            // `time_high_and_version`
            b[i++] = tmh >>> 24 & 0xf | 0x10; // include version
            b[i++] = tmh >>> 16 & 0xff;

            // `clock_seq_hi_and_reserved` (Per 4.2.2 - include variant)
            b[i++] = clockseq >>> 8 | 0x80;

            // `clock_seq_low`
            b[i++] = clockseq & 0xff;

            // `node`
            var node = options.node || _nodeId;
            for (var n = 0; n < 6; n++) {
                b[i + n] = node[n];
            }

            return buf ? buf : unparse(b);
        }

        // **`v4()` - Generate random UUID**

        // See https://github.com/broofa/node-uuid for API details
        function v4(options, buf, offset) {
            // Deprecated - 'format' argument, as supported in v1.2
            var i = buf && offset || 0;

            if (typeof(options) == 'string') {
                buf = options == 'binary' ? new BufferClass(16) : null;
                options = null;
            }
            options = options || {};

            var rnds = options.random || (options.rng || _rng)();

            // Per 4.4, set bits for version and `clock_seq_hi_and_reserved`
            rnds[6] = (rnds[6] & 0x0f) | 0x40;
            rnds[8] = (rnds[8] & 0x3f) | 0x80;

            // Copy bytes to buffer, if provided
            if (buf) {
                for (var ii = 0; ii < 16; ii++) {
                    buf[i + ii] = rnds[ii];
                }
            }

            return buf || unparse(rnds);
        }

        // Export public API
        var uuid = v4;
        uuid.v1 = v1;
        uuid.v4 = v4;
        uuid.parse = parse;
        uuid.unparse = unparse;
        uuid.BufferClass = BufferClass;

        if (typeof define === 'function' && define.amd) {
            // Publish as AMD module
            define(function() {return uuid;});
        } else if (typeof(module) != 'undefined' && module.exports) {
            // Publish as node.js module
            module.exports = uuid;
        } else {
            // Publish as global (in browsers)
            var _previousRoot = _global.uuid;

            // **`noConflict()` - (browser only) to reset global 'uuid' var**
            uuid.noConflict = function() {
                _global.uuid = _previousRoot;
                return uuid;
            };

            _global.uuid = uuid;
        }
    }).call(this);


    /*\
     |*|
     |*|  :: cookies.js ::
     |*|
     |*|  A complete cookies reader/writer framework with full unicode support.
     |*|
     |*|  Revision #1 - September 4, 2014
     |*|
     |*|  https://developer.mozilla.org/en-US/docs/Web/API/document.cookie
     |*|  https://developer.mozilla.org/User:fusionchess
     |*|
     |*|  This framework is released under the GNU Public License, version 3 or later.
     |*|  http://www.gnu.org/licenses/gpl-3.0-standalone.html
     |*|
     |*|  Syntaxes:
     |*|
     |*|  * docCookies.setItem(name, value[, end[, path[, domain[, secure]]]])
     |*|  * docCookies.getItem(name)
     |*|  * docCookies.removeItem(name[, path[, domain]])
     |*|  * docCookies.hasItem(name)
     |*|  * docCookies.keys()
     |*|
     \*/

    var docCookies = {
        getItem: function (sKey) {
            if (!sKey) { return null; }
            return decodeURIComponent(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || null;
        },
        setItem: function (sKey, sValue, vEnd, sPath, sDomain, bSecure) {
            if (!sKey || /^(?:expires|max\-age|path|domain|secure)$/i.test(sKey)) { return false; }
            var sExpires = "";
            if (vEnd) {
                switch (vEnd.constructor) {
                    case Number:
                        sExpires = vEnd === Infinity ? "; expires=Fri, 31 Dec 9999 23:59:59 GMT" : "; max-age=" + vEnd;
                        break;
                    case String:
                        sExpires = "; expires=" + vEnd;
                        break;
                    case Date:
                        sExpires = "; expires=" + vEnd.toUTCString();
                        break;
                }
            }
            document.cookie = encodeURIComponent(sKey) + "=" + encodeURIComponent(sValue) + sExpires + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "") + (bSecure ? "; secure" : "");
            return true;
        },
        hasItem: function (sKey) {
            if (!sKey) { return false; }
            return (new RegExp("(?:^|;\\s*)" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test(document.cookie);
        },

        removeItem: function (sKey, sPath, sDomain) {
            //if (!this.hasItem(sKey)) { return false; }
            document.cookie = encodeURIComponent(sKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT" + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "");
            return true;
        },

        keys: function () {
            var aKeys = document.cookie.replace(/((?:^|\s*;)[^\=]+)(?=;|$)|^\s*|\s*(?:\=[^;]*)?(?:\1|$)/g, "").split(/\s*(?:\=[^;]*)?;\s*/);
            for (var nLen = aKeys.length, nIdx = 0; nIdx < nLen; nIdx++) { aKeys[nIdx] = decodeURIComponent(aKeys[nIdx]); }
            return aKeys;
        }
    };

    var setCookie = function (name){
        docCookies.setItem(name, uuid.v4(), "Tue, 19 Jan 2038 03:14:07 GMT");
    };

    return {
        setCookie: setCookie,
        getCookie: docCookies.getItem,
        cookieExistForName: docCookies.hasItem,
        deleteCookie: docCookies.removeItem,
        allCookie: docCookies.keys
    }
}());

