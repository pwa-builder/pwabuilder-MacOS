//
//  ManifestParser.swift
//  MacOSpwa
//
//  Created by Rumsha Siddiqui on 6/26/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

import Foundation

//TODO: Add class description based on proper Swift structure
class ManifestParser {
    
    // MARK: - App Properties
    var appName: String = ""
    var appURL: String = ""
    var appDisplay: String = ""
    var appThemeColor: String = ""
    var appScope: String = ""
    
    // MARK: - GETTER METHODS
    func getAppName() -> String { return appName }
    func getAppURL() -> String { return appURL }
    func getAppDisplay() -> String { return appDisplay }
    func getAppThemeColor() -> String { return appThemeColor }
    func getAppScope() -> String { return appScope }
}
