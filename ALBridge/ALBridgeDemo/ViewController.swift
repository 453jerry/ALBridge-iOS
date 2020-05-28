//
//  ViewController.swift
//  ALBridgeDemo
//
//  Created by Jerry Huang on 2019/11/26.
//  Copyright © 2019 Jerry Huang. All rights reserved.
//

import UIKit
import WebKit
import ALBridge

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var logView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let bundlePath = Bundle.main.bundlePath
        let path = "file://\(bundlePath)/demo.htm"
        guard let url = URL(string: path) else {
            return
        }
        
        let bridge = ALBridge.init()
        webView.registerJSBridge(bridge)
        
        webView.javascriptBridge?.handlers["test_action1"] = { (message, param, _, _) in
            self.logView.text += "\(param as! String) \n"
        }
        
        webView.javascriptBridge?.handlers["test_action2"] = { (message, param, completionHandler, progressChangedHandler) in
            
            self.logView.text += "\(String(describing: param)) \n"
            
            let queue = DispatchQueue.global()
            queue.async {
                DispatchQueue.main.async {
                    progressChangedHandler(25)
                }
                Thread.sleep(forTimeInterval: 1)
                DispatchQueue.main.async {
                    progressChangedHandler(50)
                }
                Thread.sleep(forTimeInterval: 1)
                DispatchQueue.main.async {
                    progressChangedHandler(75)
                }
                Thread.sleep(forTimeInterval: 1)
                DispatchQueue.main.async {
                    progressChangedHandler(100)
                    completionHandler("\"call back param\"")
                }
            }
            
        }
        
        webView.javascriptBridge?.addWhitelist(url)
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @IBAction func sendEvent_Touched(_ sender: Any) {
        try! webView.dispatchEvent(name: "bridge_event", content: "event param")
    }
}

