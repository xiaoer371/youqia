
if (!window.mc){
    window.mc = {};
}

mc.getDeviceId = function(args){
    mc.mailchatBridge.call("getDeviceId",args);
}

// @param desiredAccuracy   The desired accuracy in meters
mc.getLocation = function(args){
    mc.mailchatBridge.call("getLocation",args);
}

mc.checkJsApi = function(args){
    mc.mailchatBridge.call("checkJsApi",args);
}

mc.authExpire = function(args){
    mc.mailchatBridge.call("authExpire",args);
}

mc.getToken = function(args){
    mc.mailchatBridge.call("getToken",args);
}

mc.showBackButton = function(args){
    mc.mailchatBridge.call("showBackButton",args);
}

mc.showBackButton = function(args){
    mc.mailchatBridge.call("showBackButton",args);
}

mc.setNavTitle = function(args){
    mc.mailchatBridge.call("setNavTitle",args);
}

mc.setNavRightButtons = function(args){
    mc.mailchatBridge.call("setNavRightButtons",args);
}

mc.on = function(eventName, callback){
    var args = {
        "event" : eventName,
        "success" : callback
    };
    mc.mailchatBridge.call("on",args);
}



