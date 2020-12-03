//
//  Extension.swift
//  MacOSpwa
//
//  Created by Rumsha Siddiqui on 7/2/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation
import Cocoa

extension NSColor {
    /*
     Takes a hex string and converts it to NSColor type
     */
    public static func convertHexToNSColor(hexString: String) -> NSColor {
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
            return NSColor.lightGray //return gray as the default
        }
    }
}
