import Cocoa
import os

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        os_log("applicationWillTerminate")
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        os_log("applicationShouldTerminate")
        
        let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
        let quitInfo = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info")
        let quitButton = NSLocalizedString("Quit", comment: "Quit anyway button title")
        let cancelButton = NSLocalizedString("Cancel", comment: "Cancel")
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = quitInfo
        alert.addButton(withTitle: quitButton)
        alert.addButton(withTitle: cancelButton)
        
        let answer = alert.runModal()
        if answer == .alertSecondButtonReturn {
            return .terminateCancel
        }

        return .terminateNow
    }

}

