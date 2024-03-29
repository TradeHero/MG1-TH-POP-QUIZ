/**
 * Created by malvin on 3/13/15.
 */
var LabelButton = function (game, x, y, key, label, style, callback,
                            callbackContext, overFrame, outFrame, downFrame, upFrame) {
    Phaser.Button.call(this, game, x, y, key, callback,
        callbackContext, overFrame, outFrame, downFrame, upFrame);

    this.anchor.setTo(0.5, 0.5);
    this.label = new Phaser.Text(game, 0, 0, label, style);

    //puts the label in the center of the button
    this.label.anchor.setTo(0.5, 0.5);

    this.addChild(this.label);
    this.setLabel(label);

    //adds button to game
    game.add.existing(this);
};

LabelButton.prototype = Object.create(Phaser.Button.prototype);
LabelButton.prototype.constructor = LabelButton;

LabelButton.prototype.setLabel = function (label) {

    this.label.setText(label);

};