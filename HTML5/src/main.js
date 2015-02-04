/*
 * TradeHero PopQuiz Javascript Plugin v@@version
 * http://www.tradehero.mobi/
 * Copyright 2014, TradeHero
 * Date: @@date
 *
 * Copyright (C) 2012 - 2014 by TradeHero
 */

/*global document*/
/*global $, jQuery*/
/*jslint nomen = false*/
/*global console*/
/*global debug*/
/*global error*/
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

var API = (function (hostURI) {

    var gameURI = hostURI + "/games/";
    return {
        getClosedChallengesURI: function () {
            return gameURI + "closed";
        },
        postGameResultsURI: function () {
            return gameURI + "postResults"
        },
        getResultForGameURI: function (gameId) {
            return gameURI + gameId + "/results";
        },
        getCurrentUserURI: function (accessToken) {
            return hostURI + "login";
        }
    }
}("https://www.tradehero.mobi/api/"));


var PopQuiz = {
    width: window.innerWidth,
    height: window.innerHeight,
    ratio: 0,
    currentWidth: 0,
    currentHeight: 0,
    /**
     * @type {?HTMLElement}
     */
    canvas: null,
    /**
     * @type {?CanvasRenderingContext2D}
     */
    ctx: null,

    scale: 1,
    offset: {top: 0, left: 0},

    ua_isMobile: true,
    ua_mobile_scale: 1.7,

    init: function () {
        if (!Utility.isMobile.any()) {
            PopQuiz.ua_isMobile = false;
            PopQuiz.ratio = 0.75;
            PopQuiz.width = PopQuiz.height * PopQuiz.ratio;
            PopQuiz.currentWidth = PopQuiz.width;
            PopQuiz.currentHeight = PopQuiz.height;
        } else {
            PopQuiz.ratio = PopQuiz.width / PopQuiz.height;
            PopQuiz.currentWidth = PopQuiz.width;
            PopQuiz.currentHeight = PopQuiz.height;
        }

        PopQuiz.canvas = document.getElementById('mainCanvas');
        PopQuiz.canvas.width = PopQuiz.width;
        PopQuiz.canvas.height = PopQuiz.height;
        PopQuiz.ctx = PopQuiz.canvas.getContext('2d');

        // listen for clicks
        window.addEventListener('click', function (e) {
            e.preventDefault();
            Input.trigger(e);
        }, false);

        // listen for touches
        window.addEventListener('touchstart', function (e) {
            e.preventDefault();
            // first touch from the event
            Input.trigger(e.touches[0]);
        }, false);
        window.addEventListener('touchmove', function (e) {
            // disable zoom and scroll
            e.preventDefault();
        }, false);
        window.addEventListener('touchend', function (e) {
            // as above
            e.preventDefault();
        }, false);

        PopQuiz.resize();

        Assets.initialise({
            "self_pp" : Config.getCurrentUserContext().pictureURL,
            "opp_pp" : Config.getOpponentUserContext().pictureURL,
            "load_bg": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/Background.png",
            "logo": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/profile_pic.jpg",
            "quiz_bg": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/quiz_bg.png",
            "test_profile_pic": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/profile_pic.jpg",
            "test_profile_pic2": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/tradeheroprofilepictures/BodyPart_58f65315-7ece-436c-bf90-7034afa64875",
            "bar_bg": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/bar_bg.png",
            "remove2": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/remove2.png"
        }, function () {
            var mainWindow = new UI.View(0, 0, PopQuiz.currentWidth, PopQuiz.currentHeight);
            PopQuiz.Launch.init(mainWindow);
        });

        Assets.beginLoad();
    },

    resize: function () {
        PopQuiz.currentHeight = window.innerHeight;

        // resize width follow the ratio
        PopQuiz.currentWidth = PopQuiz.currentHeight * PopQuiz.ratio;

        // this will create some extra space on the
        // page, allowing us to scroll past
        // the address bar, thus hiding it.
        //if (PopQuiz.android || PopQuiz.ios) {
        //    document.body.style.height = (window.innerHeight + 50) + 'px';
        //}

        PopQuiz.canvas.style.width = PopQuiz.currentWidth + 'px';
        PopQuiz.canvas.style.height = PopQuiz.currentHeight + 'px';

        window.setTimeout(function () {
            window.scrollTo(0, 1);
        }, 1);

        PopQuiz.scale = PopQuiz.currentWidth / PopQuiz.width;
        PopQuiz.offset.top = PopQuiz.canvas.offsetTop;
        PopQuiz.offset.left = PopQuiz.canvas.offsetLeft;
    }
};

window.addEventListener('load', PopQuiz.init, false);
window.addEventListener('resize', PopQuiz.resize, false);


var Config = (function () {
    /**
     *
     * @type {PopQuiz.THUser}
     */
    var _currentUserContext = null;
    /**
     *
     * @type {PopQuiz.THUser}
     */
    var _opponentUserContext = null;

    /**
     *
     * @type {PopQuiz.Game}
     * @private
     */
    var _currentGame = null;

    /**
     * @type {number}
     */
    var _parentGameId;
    return {
        /**
         *
         * @param encodedDTO {string}
         */
        setCurrentUserContext: function (encodedDTO) {
            var dto = JSON.parse(Base64.decode(encodedDTO));
            _currentUserContext = new PopQuiz.THUser(dto);
        },
        /**
         *
         * @returns {PopQuiz.THUser}
         */
        getCurrentUserContext: function () {
            return _currentUserContext;
        },
        /**
         *
         * @param encodedDTO {string}
         */
        setOpponentUserContext: function(encodedDTO){
            var dto = JSON.parse(Base64.decode(encodedDTO));
            _opponentUserContext = new PopQuiz.THUser(dto);
        },
        /**
         *
         * @returns {PopQuiz.THUser}
         */
        getOpponentUserContext: function () {
            return _opponentUserContext;
        },
        /**
         *
         * @returns {PopQuiz.Game}
         */
        getCurrentGame: function(){
            return _currentGame;
        },
        /**
         *
         * @param encodedDTO {string}
         */
        setCurrentGame: function(encodedDTO){
            var gameDTO = JSON.parse(Base64.decode(encodedDTO));
            _currentGame = new PopQuiz.Game(gameDTO)
        },

        /**
         *
         * @returns {number}
         */
        getParentGameId : function(){
            return _parentGameId;
        },

        /**
         *
         * @param parentId {number}
         */
        setParentGameId: function(parentId){
            _parentGameId = parentId;
        }
    }
}());

function debug(message) {
    "use strict";
    console.debug(message);
}

function error(message) {
    "use strict";
    console.error(message);
}

Array.prototype.clone = function () {
    return this.slice(0);
};

Array.prototype.shuffle = function () {
    var clonedArray = this.clone();
    for (var j, x, i = clonedArray.length; i; j = parseInt(Math.random() * i), x = clonedArray[--i], clonedArray[i] = clonedArray[j], clonedArray[j] = x);
    return clonedArray
};