//
//  AppDelegate.swift
//  macWebretail
//
//  Created by Gerardo Grisolini on 19/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        var mainWindow = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "mainWindow")

//        let storyboard = NSStoryboard(name: "Main", bundle: nil)
//        guard let mainWC = storyboard.instantiateController(withIdentifier: "MainController") as? WindowController else {
//            fatalError("Error getting main window controller")
//        }
//        // optionally store the reference here
//        self.mainWindowController = mainWC
//        mainWC.window?.makeKeyAndOrderFront(nil) // or use `.showWindow(self)`    
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}
