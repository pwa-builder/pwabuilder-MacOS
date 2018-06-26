//
//  ViewController.swift
//  MacOSpwa
//
//  Created by Rumsha Siddiqui on 6/7/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    // MARK: - App Properties
    var appName: String = ""
    var appURL: String = ""
    var appDisplay: String = ""
    var appThemeColor: String = ""
    
    // MARK: - Local Properties
    var webView: WKWebView!
    var myWindowController: NSWindowController = NSWindowController()
    var newWebView: WKWebView!
    let backButton = NSButton()
    
    
    // MARK: - CUSTOM FUNCTIONS
    
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
    
    /*
     Navigates to the previous webpage when the back button is pressed
    */
    @objc func backButtonPressed(){
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    
    /*
    Displays the application in fullscreen mode
    */
    func fullscreen(){
        //TODO: look into fixing window screen size when exiting full screen mode (works for original ViewController code)
        view.window?.toggleFullScreen(self) //Enter full-screen mode
    }
    
    
    /*
     Displays the application in minimal-UI mode
    */
    func minimalUI(){ //Has a back button
        //TODO: Back button design style
        backButton.title = "BACK"
        backButton.isBordered = false
        
        let titleBarView = view.window!.standardWindowButton(.closeButton)!.superview!
        titleBarView.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[backButton]-2-|", options: [], metrics: nil, views: ["backButton": backButton])) //places back button on right
        titleBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[backButton]-3-|", options: [], metrics: nil, views: ["backButton": backButton]))
        
        backButton.action = #selector(ViewController.backButtonPressed)
    }
    
    
    /*
     Takes a hex string and converts it to NSColor type
     */
    func convertHexToNSColor(hexString: String) -> NSColor? {
        //TODO: Should there be an assert statement instead: assert(hexString.hasPrefix("#"),"Theme-color format in manifest is invalid. Correct emample format: #4F4F4F")
        if !hexString.hasPrefix("#") {
            print("Theme-color format in manifest is invalid. Correct emample format: #4F4F4F. A default color of light grey will be returned")
            return NSColor.lightGray //return gray as the default
        }
        var colorString = hexString
        colorString.remove(at: colorString.startIndex) //assuming '#' is included in the string at this point
        
        //Convert the hex string to a hex number
        let scanner = Scanner(string: colorString)
        var hexNumber = UInt32() //Int32 because that's the closest to 24 bits, which is the size of RGB values
        if scanner.scanHexInt32(&hexNumber) {
            //To convert hex number to CGFloat: apply a mask (if necessary), shift the bits to the right (if necessary), divide by 255
            let red = CGFloat(hexNumber >> 16)/255
            let green = CGFloat((hexNumber & 0x00ff00) >> 8)/255
            let blue = CGFloat(hexNumber & 0x0000ff)/255
            print(red, green, blue)
            return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
        } else { //given hex value is not valid
            return nil
        }
        
    }
    
    
    // MARK: - OVERRIDE FUNCTIONS

    
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
   
    /*
     Called when a JS message is sent to the handler. Receives and prints the JS message
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        NSLog("FromJSConsole: %@", message.body as! NSObject)
    }
    
    
    override func loadView() {
        //Inject JS string to read console.logs
        let configuration = WKWebViewConfiguration()
        let action = "var originalCL = console.log; console.log = function(msg){ originalCL(msg); window.webkit.messageHandlers.iosListener.postMessage(msg); }" //Run original console.log function + print it in Xcode console
        let script = WKUserScript(source: action, injectionTime: .atDocumentStart, forMainFrameOnly: false) //Inject script at the start of the document
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(self, name: "iosListener")
        webView = WKWebView(frame: (NSScreen.main?.frame)!, configuration: configuration)
 
        //Set delegates and load view in the window
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //TODO: Find Safari version automatically
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12"
        
        //Load URL
        read_manifest()
        if let url = URL(string: appURL){
            let request = URLRequest(url: url as URL)
            webView.load(request)
            webView.allowsBackForwardNavigationGestures = true //allow backward and forward navigation by swiping
        }
    }
    
    override func viewDidAppear() {
        view.window?.title = appName
        view.window?.backgroundColor = convertHexToNSColor(hexString: appThemeColor) //set title bar to a custom color
        
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
