//
//  WKWebView+ALBridge.swift
//  ALBridge
//
//  Created by Jerry Huang on 2019/11/26.
//  Copyright © 2019 Jerry Huang. All rights reserved.
//

import WebKit

public extension WKWebView {
    
    // MARK: - Associated birdge
    private struct AssociatedKeys {
        static var javascriptBirdge = "ANLAN_BIRDGE"
    }
    var javascriptBirdge: ALBridge {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.javascriptBirdge) as! ALBridge
        }
    }
    
    // MARK: - Register java script birdge
    func registerJSBirdge(_ bridge: ALBridge) {
        let script = WKUserScript.init(source: "if (typeof window.webkit != 'undefined' && typeof window.webkit.messageHandlers.Bridge != 'undefined') { window.Bridge = window.webkit.messageHandlers.Bridge;}", injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
        self.configuration.userContentController.addUserScript(script)
        self.configuration.userContentController.add(bridge, name: "Bridge")
        objc_setAssociatedObject(self, &AssociatedKeys.javascriptBirdge, bridge, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // MARK: - Regist JSAction
    func registerJSAction(_ name: String, action: @escaping JSAction) {
        self.javascriptBirdge.handlers[name] = action
    }
    
    func unregisterJSAction(_ name: String) {
        self.javascriptBirdge.handlers.removeValue(forKey: name)
    }
    
    // MARK: - Dispatch event
    func dispatchEvent( name: String) {
        self.javascriptBirdge.dispatchEvent(to: self, name: name, eventMessage: nil)
    }

    func dispatchEvent<T : Encodable>( name: String, content: T) {
        let data = try! JSONEncoder().encode(content)
        let msg = String.init(data: data, encoding: .utf8)
        self.javascriptBirdge.dispatchEvent(to: self, name: name, eventMessage: msg)
    }
    
    func dispatchEvent(name: String, content: [String: Any]) {

        let data = try! JSONSerialization.data(withJSONObject: content, options: [])
        let msg: String? = String.init(data: data, encoding: .utf8)
        self.javascriptBirdge.dispatchEvent(to: self, name: name, eventMessage: msg)
    }
    
    func dispatchEvent(name: String, content: [Any]) {

        let data = try! JSONSerialization.data(withJSONObject: content, options: [])
        let msg: String? = String.init(data: data, encoding: .utf8)
        self.javascriptBirdge.dispatchEvent(to: self, name: name, eventMessage: msg)
    }
    
    //MARK: - White list
    func addWhitList(_ url: URL) {
        self.javascriptBirdge.addWhitList(url)
    }
    
    func removeWhitList(_ url: URL) {
        self.javascriptBirdge.removeWhitList(url)
    }
    
    func cleanWhitList() {
        self.javascriptBirdge.clearWhitList()
    }
}
