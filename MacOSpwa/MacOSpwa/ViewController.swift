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
    var appDisplay: String = ""
    var appThemeColor: String = ""
    var myWindowController: NSWindowController = NSWindowController()
    var newWebView: WKWebView!
    let backButton = NSButton()
    
    
    /* CUSTOM FUNCTIONS */
    
    /*
     Updates app property variables based on data from PWAinfo/manifest.json
     */
    func read_manifest(){
        let path = Bundle.main.path(forResource: "PWAinfo/manifest", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: jsonData) as! [String:Any]
            appName = json["name"] as! String
            appURL = json["start_url"] as! String
            appDisplay = json["display"] as! String
            appThemeColor = json["theme_color"] as! String
        } catch {
            print(error)
        }
    }
    
    @objc func backButtonPressed(){
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    func fullscreen(){
        //TODO: look into fixing window screen size when exiting full screen mode (works for original ViewController code)
        view.window?.toggleFullScreen(self) //Enter full-screen mode
    }
    
    /*
     Referenced StackOverflow for creating a button in the title bar: https://stackoverflow.com/questions/13475844/in-interface-builder-how-can-i-add-a-custom-button-to-a-window-title-bar
     */
    func minimalUI(){ //Has a back button
        //TODO: Back button design style
        backButton.title = "BACK"
        backButton.bezelStyle = .regularSquare
        backButton.isBordered = false
        
        let titleBarView = view.window!.standardWindowButton(.closeButton)!.superview!
        titleBarView.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[backButton]-2-|", options: [], metrics: nil, views: ["backButton": backButton])) //places back button on right
        titleBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[backButton]-3-|", options: [], metrics: nil, views: ["backButton": backButton]))
        
        backButton.action = #selector(ViewController.backButtonPressed)
    }
    
    /*
     Referenced StackOverflow for converting a hex string to NSColor: https://stackoverflow.com/questions/27430275/how-to-convert-hex-to-nscolor
     */
    func convertHexToNSColor(hexString: String) -> NSColor? {
        var colorString = hexString
        if hexString.hasPrefix("#"){
            colorString.remove(at: colorString.startIndex)
        }
    
        var color: NSColor? = nil
        var colorCode = UInt32()
        
        var redByte: CGFloat = 255
        var greenByte: CGFloat = 255
        var blueByte: CGFloat = 255
        
        let scanner = Scanner(string: colorString)
        if scanner.scanHexInt32(&colorCode) {
            redByte = CGFloat(colorCode & 0xff0000)
            greenByte = CGFloat(colorCode & 0x00ff00)
            blueByte = CGFloat(colorCode & 0xff)
            color = NSColor(red: redByte, green: greenByte, blue: blueByte, alpha: 1.0)
        }
        
        return color
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
    }
    
    override func viewDidAppear() {
        view.window?.title = appName
        view.window?.backgroundColor = convertHexToNSColor(hexString: appThemeColor)
        
        //Display properties: standalone mode is the default
        if appDisplay == "fullscreen" {
            fullscreen()
        } else if appDisplay == "minimal-ui" {
            minimalUI()
        }
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
