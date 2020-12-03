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

    // MARK: - Local Properties
    var webUrl: String = ""
    var webView: WKWebView!
    var newWindowController: NSWindowController = NSWindowController()
    var newWebView: WKWebView!
    var manifest: Manifest!


    // MARK: - CUSTOM FUNCTIONS

    /*
     Navigates to the previous webpage when the back button is pressed
     */
    @objc func backButtonPressed(){
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }



    // MARK: - OVERRIDE FUNCTIONS

    /*
     Called when a "open new window" link is clicked. Opens a Safari window is the link is out of scope.
     */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let newUrlString = (navigationAction.request.url?.absoluteString)!

        if manifest.isUrlInManifestScope(urlString: newUrlString) {
            //Within scope: Open new app window
            newWindowController = storyboard?.instantiateController(withIdentifier: "mainWindow") as! NSWindowController
            let vc = newWindowController.contentViewController as! ViewController
            vc.manifest = manifest
            vc.webUrl = newUrlString
            newWindowController.showWindow(self)
        } else{
            //Out of scope: Open new window in Safari
            NSWorkspace.shared.open(URL(string: newUrlString)!)
        }
        return nil
    }

    /*
     Called when a JS message is sent to the handler. Receives and prints the JS message. This is for JS debugging.
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        NSLog("FromJSConsole: %@", message.body as! NSObject)
    }


    override func loadView() {
        //Inject JS string to read console.logs for debugging
        let configuration = WKWebViewConfiguration()
        let action = "var originalCL = console.log; console.log = function(msg){ originalCL(msg); window.webkit.messageHandlers.iosListener.postMessage(msg); }" //Run original console.log function + print it in Xcode console
        let script = WKUserScript(source: action, injectionTime: .atDocumentStart, forMainFrameOnly: false) //Inject script at the start of the document
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(self, name: "iosListener")

        //Initialize WKWebView
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
    }

    /*
        Manifest path defined in the `Bundle.main.path` function call.
        If the manifest.json file does not exist at this path the app will not work.
     */
    override func viewWillAppear() {
        if manifest == nil {
            if let path = Bundle.main.path(forResource: "manifest", ofType: "json") {
                let url = URL(fileURLWithPath: path)
                do {
                    let jsonData = try Data(contentsOf: url)
                    let json = try JSONSerialization.jsonObject(with: jsonData) as! [String:Any]
                    manifest = Manifest(json: json)
                    webUrl = manifest.getAppStartUrl()
                } catch {
                    print(error)
                }
            } else {
                print("unable to find manifest within bundle path")
            }
        }

        //Load URL
        if let url = URL(string: webUrl){
            let request = URLRequest(url: url as URL)
            webView.load(request)
            webView.allowsBackForwardNavigationGestures = true //allow backward and forward navigation by swiping
        }

    }

    /*
        If you are getting an error in view did appear, you need to specify the correct manifest path.
        The default is MacOSpwa/manifest.json
     */
    override func viewDidAppear() {
        view.window?.title = manifest.getAppName()

        //Set title bar to a custom color
        if manifest.isThemeColorTransparent() {
            view.window?.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0)
        } else {
            view.window?.backgroundColor = NSColor.convertHexToNSColor(hexString: manifest.getAppThemeColor())
        }

        //Display properties: standalone mode is the default
        if manifest.isFullscreen() {
            fullscreen()
        } else if manifest.isMinimalUI() || manifest.isBrowser() {
            minimalUI()
        } //default is standalone mode
    }

    /*
     Displays the application in fullscreen mode
     */
    func fullscreen(){
        view.window?.toggleFullScreen(self) //Enter full-screen mode
    }


    /*
     Displays the application in minimal-UI mode
     */
    func minimalUI(){ //Has a back button
        let backButton = NSButton()
        backButton.title = "BACK"
        backButton.isBordered = false

        let titleBarView = view.window!.standardWindowButton(.closeButton)!.superview!
        titleBarView.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[backButton]-2-|", options: [], metrics: nil, views: ["backButton": backButton])) //places back button on right
        titleBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[backButton]", options: [], metrics: nil, views: ["backButton": backButton])) //vertically aligns the button
        backButton.action = #selector(ViewController.backButtonPressed)
    }


    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
