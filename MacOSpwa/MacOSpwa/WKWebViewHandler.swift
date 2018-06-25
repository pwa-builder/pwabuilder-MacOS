//
//  WKWebViewHandler.swift
//  MacOSpwa
//
//  Created by Rumsha Siddiqui on 6/25/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Cocoa
import WebKit

class WKWebViewHandler: NSObject, WKScriptMessageHandler {
    
    var wkWebView: WKWebView
    
    init(webView: WKWebView) {
        wkWebView = webView
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        NSLog("testing testing testing")
        print("hello")
    }
    
    
}
