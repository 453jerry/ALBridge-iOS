//
//  ALBridge.swift
//  ALBridge
//
//  Created by Jerry Huang on 2019/11/26.
//  Copyright © 2019 Jerry Huang. All rights reserved.
//

import WebKit

public typealias JSActionCompletionCallback = (_ callbackParameter: String) -> Void

public typealias JSActionProgresseChangedCallback = (_ progress: Int) -> Void

public typealias JSAction = (_ message: WKScriptMessage, _ parameter: Any?, _ completionHandler: @escaping JSActionCompletionCallback, _ progressChangedHandler: @escaping JSActionProgresseChangedCallback) -> Void

public class ALBridge: NSObject, WKScriptMessageHandler {
    
    // MARK: - Whitelist
    private var whiteList: Set<String> = []
    private func simplifyURL(_ url: URL) -> String {
        return "\(url.scheme ?? "")://\(url.host ?? ""):\(url.port ?? 0)"
    }
    
    private func verifyWhitelist(url: URL) -> Bool {
        let simplifiedURL = simplifyURL(url)
        
        if (whiteList.count > 0 && whiteList.contains(simplifiedURL) == false) {
            return false
        }
        return true
    }
    
    public func addWhitelist(_ url: URL) {
        let simplifiedURL = simplifyURL(url)
        
        whiteList.insert(simplifiedURL)
    }
    
    public func removeWhitelist(_ url: URL) {
        let simplifiedURL = simplifyURL(url)
        
        whiteList.remove(simplifiedURL)
    }
    
    public func clearWhitelist() {
        whiteList.removeAll()
    }
    
    // MARK: - WKScriptMessageHandler
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (verifyWhitelist(url: (message.webView?.url)!) == false) {
            return
        }
        
        guard message.name == "Bridge" else {
            return
        }
        invokeJSAction(scriptMessage: message)
    }
    
    // MARK: - JS Action
    public var handlers: [String : JSAction] = [:]
    
    private func invokeJSAction(scriptMessage: WKScriptMessage) {
        let body = scriptMessage.body as! String
        let data = body.data(using: String.Encoding.utf8)
        let dic = (try? JSONSerialization.jsonObject(with: data!, options: [])) as! Dictionary<String, Any>
        
        
        let callbackHandler = dic["callback"]
        let progressChangedHandler = dic["progressChanged"]
        let userInfo = dic["userinfo"]
        let param = dic["param"]
        let actionName = dic["action"] as! String
        
        guard let handler: JSAction = handlers[actionName] else {
            return
        }
        
        let callback = { (callbackParameter: String?) in
            guard let callbackHandler = callbackHandler else {
                return
            }
            var userInfoJSONStr: String? = nil
            if let userInfo = userInfo {
                if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: []) {
                    userInfoJSONStr = String.init(data: jsonData, encoding: .utf8)
                }
            }
            let callbackJSCode = "\(callbackHandler)(\(callbackParameter ?? "null"), \(userInfoJSONStr ?? "null"))"
            
            scriptMessage.webView?.evaluateJavaScript(callbackJSCode, completionHandler: nil)
        }
        
        let progressChanged = { (progress: Int) in
            guard  let progressChangedHandler = progressChangedHandler else {
                return
            }
            var userInfoJSONStr: String? = nil
            if let userInfo = userInfo {
                if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: []) {
                    userInfoJSONStr = String.init(data: jsonData, encoding: .utf8)
                }
            }
            let callbackJSCode = "\(progressChangedHandler)(\(progress), \(userInfoJSONStr ?? "null"))"
            
            scriptMessage.webView?.evaluateJavaScript(callbackJSCode, completionHandler: nil)
            
        }
        
        handler(scriptMessage, param, callback, progressChanged)
    }
    
    // MARK: - Event
    
    public func dispatchEvent(to webView:WKWebView, name: String, eventMessage: String?) {
        if (verifyWhitelist(url: (webView.url)!) == false) {
            return
        }
        
        let js = "var bridgeEvent=new Event('\(name)');bridgeEvent.msg=\(eventMessage ?? "null"); window.dispatchEvent(bridgeEvent);"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}

