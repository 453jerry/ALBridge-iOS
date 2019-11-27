# ALBridge
ALBridge is a lightweight JavaScript bridge for WKWebView on iOS.  
AL is short for Anlan, the name of an ancient bridge in Dujiangyan, China.  

# Functions
- JSAction  
    JSAction is a block of code that can be invoked by JavaScript. It needs to be registered in ALBridge before it can be invoked by JavaScript. The result of JSAction is returned through asynchronous callbacks.
- Dispatch native event  
    Native event can be dispatched to the window object and in JavaScript code it can be subscribed by  ```window.addEventListener(event, handler)```
- White list  
    Only sites on the white list can use ALBridge.


# How to install
```
pod 'ALBridge'
```

# How to use
## Register ALBridge

```swift
let bridge = ALBridge.init()
webView.registerJSBirdge(bridge)
```

## Register JSAction
JSAction is a block of code that can be invoked by JavaScript. It needs to be registered in ALBridge before it can be invoked by JavaScript. The result of JSAction is returned through asynchronous callbacks.  
   
You can add JSAction and action name in to ```ALBridge.handler``` directly.
```swift
bridge.handlers["action_name"] = { (message, param, callback) in
    /* implement */
}
```
or you can invoke ``` registerJSAction(_ name: String, action: @escaping JSAction)```
```swift
webView.registerJSAction("test_action1", action: { (message, param, callback) in
    /* implement */
})
```
The callback handler of JSAction can be ignored if there is no result to return.

## Dispatch native event
ALBridge supports dispatch native events to the windows object of JavaScript.

```swift
webView.dispatchEvent(name: "event_name", content: params)
```

## White list
ALBridge will check whether the current url of wkwebview is on the white list before the native event is dispatched or JSActivon be executed.  
Whitelist verification only validates the scheme, host, and port of the url.  
If the white list of ALBrige is empty it means there is no verification. 

- Add url to white list:  
    ```swift
    webView.addWhitList(url)
    ```
    or
    ```swift
    bridge.addWhitList(url)
    ```
- Remove url from white list  
    ```swift
    webView.removeWhitList(url)
    ```
    or
    ```swift
    bridge.removeWhitList(url)
    ```

- Clean white list      
    ```swift
    webView.clearWhitList()
    ```
    or
    ```swift
    bridge.clearWhitList()
    ```
