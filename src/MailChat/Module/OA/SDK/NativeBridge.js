
var NativeBridge = {
  callbacksCount : 1,
  callbacks : {},
  
  // Automatically called by native layer when a result is available
  resultForCallback : function resultForCallback(callbackId, callbackType, resultArray) {
      try {
          
        var callback = NativeBridge.callbacks[callbackId];
        if (!callback) return;
            
        var callbackFunc;
        if (callbackType == "ok"){
            callbackFunc = callback.success;
        }
        else if (callbackType == "fail"){
            callbackFunc = callback.failure;
        }
        else if (callbackType == "cancel"){
            callbackFunc = callback.cancel;
        }
        else{
            callbackFunc = callback.complete;
        }
        
        if(callbackFunc){
          callbackFunc.apply(null,resultArray);
        }
        
      } catch(e) {
            alert(e)
      }
      
  },
  
  // Use this in javascript to request native objective-c code
  // functionName : string (I think the name is explicit :p)
  // args : the argument json object,including callback functions.
  call : function call(functionName, args) {
    
    var hasCallback = args.success || args.failure || args.complete || args.cancel;
    var callbackId = hasCallback ? NativeBridge.callbacksCount++ : 0;
      if (functionName == "on") {
          callbackId = args.event;
      }
    
    if (hasCallback)
      NativeBridge.callbacks[callbackId] = args;
    
    var iframe = document.createElement("IFRAME");
    iframe.setAttribute("src", "mc:" + functionName + ":" + callbackId+ ":" + encodeURIComponent(JSON.stringify(args)));
    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
    
  }
};

if (!window.mc){
    window.mc = {};
}

window.mc.mailchatBridge = NativeBridge;




