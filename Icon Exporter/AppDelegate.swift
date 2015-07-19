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


}

