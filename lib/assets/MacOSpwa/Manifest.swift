//
//  Manifest.swift
//  MacOSpwa
//
//  Created by Rumsha Siddiqui on 6/26/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation
import Cocoa

// Represents the PWA manifest
class Manifest {
    
    // MARK: - App Properties
    private var appName: String = ""
    private var appStartUrl: String = ""
    private var appDisplay: String = ""
    private var appThemeColor: String = ""
    private var appScope: String = ""
    
    // MARK: - Initialize App Properties  //TODO: Remove this later --- PWABuilder will load data from manifest
    init(json: [String:Any]){
        //Xcode throws a runtime error if the json object does not contain a key with the given string
        appName = json["name"] as! String
        appStartUrl = json["start_url"] as! String
        appDisplay = json["display"] as! String
        appThemeColor = json["theme_color"] as! String
        appScope = json["scope"] as! String
    }
    
    init(name: String, startUrl: String, display: String, themeColor: String, scope: String){
        appName = name
        appStartUrl = startUrl
        appDisplay = display
        appThemeColor = themeColor
        appScope = scope
    }
    
    // MARK: - GETTER METHODS
    public func getAppName() -> String { return appName }
    public func getAppStartUrl() -> String { return appStartUrl }
    public func getAppDisplay() -> String { return appDisplay }
    public func getAppThemeColor() -> String { return appThemeColor }
    public func getAppScope() -> String { return appScope }
    
    
    // MARK: - MODEL METHODS
    public func isUrlInManifestScope(urlString: String) -> Bool {
        //TODO: check if url valid here?
        let startUrl = URL(string: appStartUrl)
        if (urlString.hasPrefix("https://" + (startUrl?.host)! + appScope)) {
            return true
        } else {
            return false
        }
    }
    
    public func isFullscreen() -> Bool {
        if appDisplay == "fullscreen" {
            return true
        } else {
            return false
        }
    }
    
    public func isMinimalUI() -> Bool {
        if appDisplay == "minimal-ui" {
            return true
        } else {
            return false
        }
    }
    
    public func isBrowser() -> Bool {
        if appDisplay == "browser" {
            return true
        } else {
            return false
        }
    }
    
    public func isThemeColorTransparent() -> Bool {
        if appThemeColor.lowercased() == "transparent" {
            return true
        } else {
            return false
        }
    }
    
}
