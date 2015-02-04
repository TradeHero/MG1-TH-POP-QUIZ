var Network = (function(root){

    var _exports = {};


    /**
     *
     * @param req
     * @returns {*[]}
     * @private
     */
    var _parse = function (req) {
        /**
         * @type {object|string}
         */
        var result;
        try {
            /**
             * @type {object}
             */
            result = JSON.parse(req.responseText);
        } catch (e) {
            /**
             * @type {string}
             */
            result = req.responseText;
        }
        /**
         * @type {*[]}
         */
        return [result, req];
    };

    /**
     *
     * @param type
     * @param url
     * @param data
     * @param auth {string}
     * @returns {{success: Function, error: Function}}
     * @private
     */
    var _xhr = function (type, url, data, auth) {
        var methods = {
            success: function () {
            },
            error: function () {
            }
        };

        /**
         *
         * @type {XMLHttpRequest|Function}
         */
        var XHR = root.XMLHttpRequest || ActiveXObject;
        var request = new XHR('MSXML2.XMLHTTP.3.0');
        request.open(type, url, true);
        request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        if (auth != undefined){
            request.setRequestHeader('Authorization', auth);
        }
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

    _exports['get'] = function (src, auth) {
        return _xhr('GET', src, auth);
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
