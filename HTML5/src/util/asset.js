var Asset;
Asset = (function () {
    // images dictionary
    //this.images = {
    //    "load_bg": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/Background.png",
    //    "logo": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/profile_pic.jpg",
    //    "quiz_bg": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/quiz_bg.png",
    //    "test_profile_pic": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/profile_pic.jpg",
    //    "test_profile_pic2": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/tradeheroprofilepictures/BodyPart_58f65315-7ece-436c-bf90-7034afa64875",
    //    "bar_bg": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/bar_bg.png",
    //    "remove2": "http://portalvhdskgrrf4wksb8vq.blob.core.windows.net/minigame1/html5_resources/remove2.png"
    //};
    this.images = {
        "load_bg": "resources/Background.png",
        "logo": "resources/th.svg",
        "quiz_bg": "resources/quiz_bg.png",
        "test_profile_pic": "resources/profile_pic.jpg",
        "test_profile_pic2": "resources/profile_pic.jpg",
        "bar_bg": "resources/bar_bg.png",
        "remove2": "resources/remove2.png"
    };

    var assetsLoaded = 0;                                // how many assets have been loaded
    this.totalAsset = Object.keys(this.images).length;  // total number of assets
    /**
     * Ensure all assets are loaded before using them
     * @param {number} dic  - Dictionary name ('images')
     * @param {number} name - Asset name in the dictionary
     */
    function assetLoaded(dic, name) {

        // don't count assets that have already loaded
        if (this[dic][name].status !== "loading") {
            return;
        }
        this[dic][name].status = "loaded";
        assetsLoaded++;
        // finished callback
        if (assetsLoaded === Asset.totalAsset && typeof Asset.finished === "function") {
            Asset.finished();
        }
    }

    /**
     * Create assets, set callback for asset loading, set asset source
     */
    this.downloadAll = function () {
        var _this = this;
        var src;
        // load images
        for (var img in this.images) {

            if (this.images.hasOwnProperty(img)) {
                src = this.images[img];
                // create a closure for event binding
                (function (_this, img) {
                    _this.images[img] = new Image();
                    _this.images[img].status = "loading";
                    _this.images[img].name = img;
                    _this.images[img].onload = function () {
                        assetLoaded.call(_this, "images", img);
                    };

                    _this.images[img].src = src;
                })(_this, img);
            }
        }
    };
    return {
        images: this.images,
        totalAsset: this.totalAsset,
        downloadAll: this.downloadAll
    };
})();
Asset.finished = function () {
    var mainWindow = new UI.View(0, 0, PopQuiz.currentWidth, PopQuiz.currentHeight);
    PopQuiz.Launch.init(mainWindow);
};