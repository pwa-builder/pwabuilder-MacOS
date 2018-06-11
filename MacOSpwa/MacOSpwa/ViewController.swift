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
    var appName: String = ""
    var appURL: String = ""
    
    
    /* CUSTOM FUNCTIONS */
    
    /*
     updates appName and appURL based on name and start_url from PWAinfo/manifest.json
     */
    func read_manifest(){
        let path = Bundle.main.path(forResource: "PWAinfo/manifest", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: jsonData) as! [String:Any]
            
            appName = json["name"] as! String
            appURL = json["start_url"] as! String
            
        } catch {
            print(error)
        }
    }
    
    
    /* OVERRIDE FUNCTIONS */
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //TODO: Find Safari version automatically
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12"
        
        read_manifest()
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


