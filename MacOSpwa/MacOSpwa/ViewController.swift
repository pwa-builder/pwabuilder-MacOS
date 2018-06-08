//
//  ViewController.swift
//  MacOSpwa
//
//  Created by Rumsha Siddiqui on 6/7/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    let appName: String = "Bing"
    let appURL: String = "https://www.bing.com"
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let url = URL(string: appURL){
            let request = URLRequest(url: url as URL)
            webView.load(request)
            webView.allowsBackForwardNavigationGestures = true //allow backward and forward navigation by swiping
        }
    }
    
    override func viewDidAppear() {
        view.window?.title = appName
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}


