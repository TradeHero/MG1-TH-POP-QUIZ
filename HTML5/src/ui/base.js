var UI = {};

UI = {
    version: "0.0.1"
};
function inherit(proto) {
    function F() {
    }

    F.prototype = proto;
    return new F;
}
