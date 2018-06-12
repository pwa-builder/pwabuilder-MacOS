//
//  ViewController.swift
//  MacOSpwa
//
//  Created by Rumsha Siddiqui on 6/7/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, WebUIDelegate, WebPolicyDelegate, WKUIDelegate {
    
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
    
    func webView(_: WKWebView, didCommit: WKNavigation!){
        print("didCommit")
    }
    
    func webView(_: WKWebView, didReceiveServerRedirectForProvisionalNavigation: WKNavigation!){
        print("server redirect")
    }
    
    func webView(_ webView: WebView!, decidePolicyForNewWindowAction actionInformation: [AnyHashable : Any]!, request: URLRequest!, newFrameName frameName: String!, decisionListener listener: WebPolicyDecisionListener!) {
        print("decide policy") //not called
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (_: WKNavigationResponsePolicy) -> Void) {
        print("decidePolicyForNavigationResponse")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (_: WKNavigationActionPolicy) -> Void) {
        print("navigation action")
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView) -> WKWebView?{
        print("creating new webview") //does not work
        let webView2: WKWebView! = WKWebView()
        return webView2
    }
    
    /* override func webView(_ webView: WebView!, decidePolicyForNavigationAction actionInformation: [AnyHashable : Any]!, request: URLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
        print("listener")
    }
    */
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("configuration/n") 
        NSWorkspace.shared.open(navigationAction.request.url!)
        
        return nil
    }
    

    
    /*func webView(_ webView: WebView!, decidePolicyForNewWindowAction actionInformation: [AnyHashable : Any]!, request: URLRequest!, newFrameName frameName: String!, decisionListener listener: WebPolicyDecisionListener!) {
        print("in listener")
        
    }
    
    
    func webView(_ sender: WebView!, createWebViewWith request: URLRequest!) -> WebView! {
        print("create with request")
        return sender
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        print("in here")
        //this is a 'new window action' (aka target="_blank") > open this URL externally. If we´re doing nothing here, WKWebView will also just do nothing. Maybe this will change in a later stage of the iOS 8 Beta
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            print("here link Activated!!!")
            let url = navigationAction.request.url!
            
            let urlString = url.absoluteString
            
            if let urlOpen = URL(string: urlString), NSWorkspace.shared.open(url) {
                print("default browser was successfully opened")
            }
            
            decisionHandler(WKNavigationActionPolicy.cancel)
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    */
    
    
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("testing")
        if let url = URL(string: "https://www.google.com"), NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
        print("testing2")
        
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


