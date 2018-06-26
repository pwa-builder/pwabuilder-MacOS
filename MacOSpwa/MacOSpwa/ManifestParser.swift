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
    
    // MARK: - App Properties
    private var appName: String = ""
    private var appURL: String = ""
    private var appDisplay: String = ""
    private var appThemeColor: String = ""
    private var appScope: String = ""
    
    // MARK: - GETTER METHODS
    func getAppName() -> String { return appName }
    func getAppURL() -> String { return appURL }
    func getAppDisplay() -> String { return appDisplay }
    func getAppThemeColor() -> String { return appThemeColor }
    func getAppScope() -> String { return appScope }
    
    // MARK: - MODEL METHODS
    func parseManifest(json: [String:Any]) -> Void {
        //Xcode throws a runtime error if the json object does not contain a key with the given string
        appName = json["name"] as! String
        appURL = json["start_url"] as! String
        appDisplay = json["display"] as! String
        appThemeColor = json["theme_color"] as! String
        appScope = json["scope"] as! String
    }
    
    func isUrlInManifestScope(url: URL) -> Bool {
        //TODO: check if url valid here?
        if url.absoluteString.hasPrefix("https://" + (url.host)! + appScope){
            return true
        } else {
            return false
        }
    }
    
    func isFullscreen() -> Bool {
        //TODO: Check for different letter cases?
        if appDisplay == "fullscreen" {
            return true
        } else {
            return false
        }
    }
    
    func isMinimalUI() -> Bool {
        //TODO: Check for different letter cases?
        if appDisplay == "minimal-ui" {
            return true
        } else {
            return false
        }
    }
    
    /*
     Takes a hex string and converts it to NSColor type
     */
    func convertHexToNSColor(hexString: String) -> NSColor? {
        //TODO: Should there be an assert statement instead? Ex: assert(hexString.hasPrefix("#"),"Theme-color format in manifest is invalid. Correct emample format: #4F4F4F")
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
            return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
        } else { //given hex value is not valid
            return nil
        }
    }
    
}
