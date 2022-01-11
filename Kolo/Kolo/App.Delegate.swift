//
//  AppDelegate.swift
//  Kolo
//
//  Created by Ivan Kh on 23.12.2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if !FileManager.default.fileExists(atPath: URL.plugins.path) {
            try? FileManager.default.createDirectory(at: URL.plugins, withIntermediateDirectories: true, attributes: nil)
        }

        if !FileManager.default.fileExists(atPath: URL.settings.path) {
            try? FileManager.default.createDirectory(at: URL.settings, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - Core Data stack

    @IBAction func saveAction(_ sender: AnyObject?) {
        do {
            try NSManagedObjectContext.main.commitAndSaveIfNeeded()
        }
        catch {
            NSApplication.shared.presentError(error as NSError)
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return NSManagedObjectContext.main.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        do {
            return try NSManagedObjectContext.main.commitAndSaveBeforeTerminate()
        }
        catch {
            let result = sender.presentError(error as NSError)
            
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
           
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
                        
            if alert.runModal() == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }

        return .terminateNow
    }

}


extension AppDelegate {
    private var windowController: WindowController? {
        NSApp.mainWindow?.windowController as? WindowController
    }
    
    @IBAction func plusButtonAction(_ sender: Any) {
        windowController?.plusButtonAction(sender)
    }
    
    @IBAction func closeTabAction(_ sender: Any) {
        windowController?.closeAction(sender)
    }
}
