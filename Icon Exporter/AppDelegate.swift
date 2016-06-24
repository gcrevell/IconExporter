//
//  AppDelegate.swift
//  Icon Exporter
//
//  Created by Voltage on 7/14/15.
//  Copyright © 2015 Gabriel Revells. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func application(sender: NSApplication, openFile filename: String) -> Bool {
        print("Dropped file \(filename) onto the app icon.")
        
        if let image = NSImage(byReferencingFile: filename) {
            
            let folder = Helpers.makeFolder()
            
            Helpers.saveImageAsset(image, toPath: folder.path, forNumber: nil, withName: nil)
            
            Helpers.displayNotificationForFolder(folder.name)
        }
        
        return true
    }
    
}

