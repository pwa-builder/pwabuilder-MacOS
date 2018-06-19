//
//  ViewController.swift
//  MacOSpwa
//
//  Created by Rumsha Siddiqui on 6/7/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webView: WKWebView!
    var appName: String = ""
    var appURL: String = ""
    var myWindowController: NSWindowController = NSWindowController()
    var newWebView: WKWebView!
    
    
    /* CUSTOM FUNCTIONS */
    
    /*
     Updates appName and appURL based on name and start_url from PWAinfo/manifest.json
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
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        //TODO: Open new app window or safari based on manifest scope and URL
        
        //Open new app window
        myWindowController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "mainWindow")) as! NSWindowController
        myWindowController.showWindow(self)
        newWebView = WKWebView()
        newWebView.navigationDelegate = self
        newWebView.uiDelegate = self
        newWebView.load(navigationAction.request)
        newWebView.allowsBackForwardNavigationGestures = true //allow backward and forward navigation by swiping
        myWindowController.contentViewController?.view = newWebView
        
        // Open new window in Safari
        //NSWorkspace.shared.open(navigationAction.request.url!)
        return nil
    }
    
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
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
        
        //Create a back button for the minimal-ui display
        //let button =
    }
    
    override func viewDidAppear() {
        view.window?.title = appName
        //TODO: look into fixing window screen size when exiting full screen mode (works for original ViewController code)
        //view.window?.toggleFullScreen(self) //Enter full-screen mode
        //standalone mode is the default
        
        //Create back button
        /*let path = Bundle.main.path(forResource: "PWAinfo/icon_16", ofType: "png")
        let url = URL(fileURLWithPath: path!)
        var backButton = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier("backButton"))
        backButton.image = NSImage(byReferencing: url)
        
        //Create title bar
        let toolBar = NSToolbar(identifier: NSToolbar.Identifier("toolBar"))
        toolBar.items.append(backButton)
        
        view.window?.toolbar? = toolBar
        */
        let backButton = NSButton()
        backButton.title = "BACK"
        backButton.bezelStyle = .regularSquare
        backButton.isBordered = false
        
        
        let titleBarView = view.window!.standardWindowButton(.closeButton)!.superview!
        titleBarView.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[backButton]-2-|", options: [], metrics: nil, views: ["backButton": backButton])) //places back button on right
        titleBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[backButton]-3-|", options: [], metrics: nil, views: ["backButton": backButton]))
        
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
