//
//  ManifestParser.swift
//  MacOSpwa
//
//  Created by Rumsha Siddiqui on 6/26/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation
import Cocoa

//TODO: Add class description based on proper Swift structure
class ManifestParser {
    
    // MARK: - App Properties //TODO: Remove this later --- PWABuilder will load data from manifest
    
    private static var appName: String = ""
    private static var appURL: String = ""
    private static var appDisplay: String = ""
    private static var appThemeColor: String = ""
    private static var appScope: String = ""
    
    // MARK: - Initialize App Properties  //TODO: Remove this later --- PWABuilder will load data from manifest
    public static func parseManifest(json: [String:Any]) -> Void {
        //Xcode throws a runtime error if the json object does not contain a key with the given string
        appName = json["name"] as! String
        appURL = json["start_url"] as! String
        appDisplay = json["display"] as! String
        appThemeColor = json["theme_color"] as! String
        appScope = json["scope"] as! String
    }
    
    // MARK: - GETTER METHODS //TODO: Remove this later --- PWABuilder will load data from manifest
    public static func getAppName() -> String { return appName }
    public static func getAppURL() -> String { return appURL }
    public static func getAppDisplay() -> String { return appDisplay }
    public static func getAppThemeColor() -> String { return appThemeColor }
    public static func getAppScope() -> String { return appScope }
    
    
    // MARK: - MODEL METHODS
    public static func isUrlInManifestScope(url: URL, scope: String) -> Bool {
        //TODO: check if url valid here?
        if url.absoluteString.hasPrefix("https://" + (url.host)! + scope){
            return true
        } else {
            return false
        }
    }
    
    public static func isFullscreen(display: String) -> Bool {
        if display == "fullscreen" {
            return true
        } else {
            return false
        }
    }
    
    public static func isMinimalUI(display: String) -> Bool {
        if display == "minimal-ui" {
            return true
        } else {
            return false
        }
    }
    
    
    
}
