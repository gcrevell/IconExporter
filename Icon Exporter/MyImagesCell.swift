//
//  MyImagesCell.swift
//  Icon Exporter
//
//  Created by Voltage on 7/18/15.
//  Copyright © 2015 Gabriel Revells. All rights reserved.
//

import Cocoa

class MyImagesCell: NSTableCellView {

	@IBOutlet weak var displayedImage: NSImageView!
	@IBOutlet weak var imageNumberLabel: NSTextField!
	
	var currentView: ViewController!
	var index: Int!
	
	@IBAction func deleteButtonPushed(sender: AnyObject) {
		NSLog("Pushed")
		
		currentView.removeCell(self)
	}
    
    
}
