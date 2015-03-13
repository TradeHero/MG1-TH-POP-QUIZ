/**
 * Created by malvin on 3/12/15.
 */
var BasicGame = {};
var width = 760;
var height = 1349;
var defaultFont = "Avenir Next";

BasicGame.Boot = function (game) {

};

BasicGame.Boot.prototype =
{
    preload: function () {
        this.stage.disableVisibilityChange = true;
    },

    create: function () {
        this.stage.backgroundColor = "#fff";
        this.scale.fullScreenScaleMode = Phaser.ScaleManager.SHOW_ALL;
        this.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL;
        this.scale.refresh();

        this.state.start('Game');
    }
}

function loadExternalUrl(game, url) {
    var file = {
        type: 'image',
        key: url,
        url: url,
        data: null,
        error: false,
        loaded: false
    };

    file.data = new Image();
    file.data.name = file.key;

    file.data.onload = function () {
        file.loaded = true;
        game.cache.addImage(file.key, file.url, file.data);
        game = null;
    };

    file.data.onerror = function () {
        file.error = true;
        game = null;
    };

    file.data.crossOrigin = '';
    file.data.src = file.url;

}