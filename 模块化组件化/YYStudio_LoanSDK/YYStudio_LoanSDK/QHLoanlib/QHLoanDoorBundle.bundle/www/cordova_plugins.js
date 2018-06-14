



cordova.define('cordova/plugin_list', function(require, exports, module) {
    module.exports = [
          {
          "id": "qhCordova-plugin-navigationBar.navigationBar",
          "file": "plugins/qhCordova-plugin-navigationBar/www/QHNavigationBar.js",
          "pluginId": "qhCordova-plugin-navigationBar",
          "merges": [
                     "QHNavigationBar"
                     ]
          },
        {
              "id": "qhCordova-plugin-file.QHFile",
              "file": "plugins/qhCordova-plugin-file/www/QHFile.js",
              "pluginId": "qhCordova-plugin-file",
              "clobbers": [
                           "QHFile"
                           ]
        },
        {
              "id": "qhCordova-plugin-pop.QHPop",
              "file": "plugins/qhCordova-plugin-pop/www/QHPop.js",
              "pluginId": "qhCordova-plugin-pop",
              "clobbers": [
                           "QHPop"
                           ]
        },
        {
              "id": "qhCordova-plugin-camera.QHCamera",
              "file": "plugins/qhCordova-plugin-camera/www/QHCamera.js",
              "pluginId": "qhCordova-plugin-camera",
              "clobbers": [
                           "QHCamera"
                           ]
        },
        {
            "id": "cordova-plugin-geolocation.Coordinates",
            "file": "plugins/cordova-plugin-geolocation/www/Coordinates.js",
            "pluginId": "cordova-plugin-geolocation",
            "clobbers": [
                "Coordinates"
            ]
        },
        {
            "id": "cordova-plugin-geolocation.PositionError",
            "file": "plugins/cordova-plugin-geolocation/www/PositionError.js",
            "pluginId": "cordova-plugin-geolocation",
            "clobbers": [
                "PositionError"
            ]
        },
        {
            "id": "cordova-plugin-geolocation.Position",
            "file": "plugins/cordova-plugin-geolocation/www/Position.js",
            "pluginId": "cordova-plugin-geolocation",
            "clobbers": [
                "Position"
            ]
        },
        {
            "id": "cordova-plugin-geolocation.geolocation",
            "file": "plugins/cordova-plugin-geolocation/www/geolocation.js",
            "pluginId": "cordova-plugin-geolocation",
            "clobbers": [
                "navigator.geolocation"
            ]
        },
        {
            "id": "cordova-plugin-dialogs.notification",
            "file": "plugins/cordova-plugin-dialogs/www/notification.js",
            "pluginId": "cordova-plugin-dialogs",
            "merges": [
                "navigator.notification"
            ]
        },
        {
            "id": "qhCordova-plugin-basicMessage.basicMessage",
            "file": "plugins/qhCordova-plugin-basicMessage/www/QHBasicMessage.js",
            "pluginId": "qhCordova-plugin-basicMessage",
            "merges": [
                "QHBasicMessage"
            ]
        },
        {
            "id": "qhCordova-plugin-contacts.contacts",
            "file": "plugins/qhCordova-plugin-contacts/www/QHContacts.js",
            "pluginId": "qhCordova-plugin-contacts",
            "merges": [
                "QHContacts"
            ]
        },
        {
            "id": "qhCordova-plugin-scanQRCode.scanQRCode",
            "file": "plugins/qhCordova-plugin-scanQRCode/www/QHScanQRCode.js",
            "pluginId": "qhCordova-plugin-scanQRCode",
            "merges": [
                "QHScanQRCode"
            ]
        },
          {
          "id": "cordova-plugin-wkwebview-engine.ios-wkwebview-exec",
          "file": "plugins/cordova-plugin-wkwebview-engine/www/ios-wkwebview-exec.js",
          "pluginId": "cordova-plugin-wkwebview-engine",
          "clobbers": [
                       "cordova.exec"
                       ]
          },
          {
          "id": "cordova-plugin-wkwebview-engine.ios-wkwebview",
          "file": "plugins/cordova-plugin-wkwebview-engine/www/ios-wkwebview.js",
          "pluginId": "cordova-plugin-wkwebview-engine",
          "clobbers": [
                       "window.WkWebView"
                       ]
          }
    ];
    module.exports.metadata = 
    // TOP OF METADATA
    {
        "cordova-plugin-geolocation": "2.4.1",
       "cordova-plugin-whitelist": "1.3.3",
       "cordova-plugin-wkwebview-engine": "1.1.4"
    };
    // BOTTOM OF METADATA
});
