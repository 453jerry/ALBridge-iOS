//
//  WKWebView+ALBridge.swift
//  ALBridge
//
//  Created by Jerry Huang on 2019/11/26.
//  Copyright © 2019 Jerry Huang. All rights reserved.
//

import WebKit

public extension WKWebView {
    
    // MARK: - Associated bridge
    private struct AssociatedKeys {
        static var javascriptBridge = "ANLAN_BRIDGE"
    }
    var javascriptBridge: ALBridge? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.javascriptBridge) as? ALBridge
        }
    }
    
    // MARK: - Register JavaScript bridge
    func registerJSBridge(_ bridge: ALBridge) {
        let script = WKUserScript.init(source: "if (typeof window.webkit != 'undefined' && typeof window.webkit.messageHandlers.Bridge != 'undefined') { window.Bridge = window.webkit.messageHandlers.Bridge;}", injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
        self.configuration.userContentController.addUserScript(script)
        self.configuration.userContentController.add(bridge, name: "Bridge")
        objc_setAssociatedObject(self, &AssociatedKeys.javascriptBridge, bridge, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // MARK: - Dispatch event
    func dispatchEvent( name: String) {
        self.javascriptBridge?.dispatchEvent(to: self, name: name, eventMessage: nil)
    }

    func dispatchEvent<T : Encodable>( name: String, content: T) throws {
        try self.javascriptBridge?.dispatchEvent(to: self, name: name, content: content)
    }
    
    func dispatchEvent(name: String, content: [String: Any]) throws {
        try self.javascriptBridge?.dispatchEvent(to: self, name: name, content: content)
    }
    
    func dispatchEvent(name: String, content: [Any]) throws {
        try self.javascriptBridge?.dispatchEvent(to: self, name: name, content: content)
    }
}
