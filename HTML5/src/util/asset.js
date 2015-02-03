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

