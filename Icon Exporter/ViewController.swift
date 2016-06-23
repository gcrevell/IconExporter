//
//  ViewController.swift
//  Icon Exporter
//
//  Created by Voltage on 7/14/15.
//  Copyright © 2015 Gabriel Revells. All rights reserved.
//

import Cocoa

enum typePickerIndex:Int {
	case iphone = 0
	case mac = 1
	case asset = 2
	case animation = 3
	
	func indexIsIcon() -> Bool {
		if self.rawValue <= 1 {
			return true
		}
		
		return false
	}
}

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate {
	
	@IBOutlet weak var imageDropper: NSImageView!
	@IBOutlet weak var dropPicker: NSPopUpButton!
	@IBOutlet weak var myView: NSView!
	@IBOutlet weak var table: NSTableView!
	@IBOutlet weak var exportAnimationsButton: NSButton!
	@IBOutlet weak var nameTextField: NSTextField!
	
	var images = [NSImage]()
	var cells = [MyImagesCell]()
	
	var fullWidth: CGFloat!
	var collapsedWidth: CGFloat!
	var fullHeight: CGFloat!
	var collapsedHeight: CGFloat!
	var hidden = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		imageDropper.highlighted = false
		
		dropPicker.removeAllItems()
		dropPicker.addItemsWithTitles(["iPhone App Icons", "Mac App Icons", "Image Assets (1, 2, 3x)", "Animations"])
		
		myView.wantsLayer = true
		
		myView.layer!.backgroundColor = NSColor.blueColor().CGColor
		
		myView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.OnSetNeedsDisplay
		
		fullWidth = CGFloat(728)
		collapsedWidth = fullWidth - myView.frame.width - 8
		
		fullHeight = CGFloat(374)
		collapsedHeight = fullHeight - 41
		
		exportAnimationsButton.hidden = true
		nameTextField.hidden = true
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	@IBAction func imageDropped(sender: AnyObject) {
		let droppedImage = imageDropper.image!
		imageDropper.image = NSImage(named: "Drag Image Here")
		
		print("Dropped image is of size \(droppedImage.size)")
		
		let format = typePickerIndex(rawValue: dropPicker.indexOfSelectedItem)!
		
		if format.indexIsIcon()  {
			if droppedImage.size.width != droppedImage.size.height {
				let alert = NSAlert()
				
				alert.messageText = "Whoa there."
				alert.informativeText = "You can't make an app icon out of a non square image."
				alert.addButtonWithTitle("Hail Voltage")
				alert.addButtonWithTitle("I'll do better")
				
				alert.alertStyle = NSAlertStyle.CriticalAlertStyle
				
				alert.runModal()
				
				return
			}
		}
		
		if format == .animation {
			images.append(droppedImage)
			table.reloadData()
			return
		}
		
		
		let ret = makeFolder()
		let folder = ret.folder
		let name = ret.name
		
		if folder.characters.count == 0 {
			return
		}
		
		let imageName = nameTextField.stringValue
		
		if format == .iphone {
			//iPhone Icons
			writeSquareImage(droppedImage, toSize: 58, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 87, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 80, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 120, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 180, inFolder: folder)
		} else if format == .asset {
			//Image assets (1,2,3x)
			saveSizedImage(droppedImage, toPath: folder, forNumber: nil, withName: imageName)
		} else if format == .mac {
			//Mac icons
			writeSquareImage(droppedImage, toSize: 1024, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 512, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 256, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 128, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 64, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 32, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 16, inFolder: folder)
		}
		
		let not = NSUserNotification()
		not.title = "Complete"
		not.informativeText = "Your images are in  a folder called \(name) on the Desktop"
		not.contentImage = droppedImage
		
		not.deliveryDate = NSDate()
		
		NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(not)
	}
	
	func writeImage(image: NSImage, toSize size: CGSize, toPath path: String) {
		let outputWidth = CGFloat(size.width)/(NSScreen.mainScreen()?.backingScaleFactor)!
		let outputHeight = CGFloat(size.height)/(NSScreen.mainScreen()?.backingScaleFactor)!
		
		let output = NSImage(size: NSSize(width: outputWidth, height: outputHeight))
		
		output.lockFocus()
		
		image.drawInRect(NSRect(x: 0, y: 0, width: outputWidth, height: outputHeight), fromRect: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height), operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
		
		output.unlockFocus()
		
		let i = NSBitmapImageRep(data: output.TIFFRepresentation!)?.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [String : AnyObject]())
		
		i?.writeToFile("\(path).png", atomically: true)
	}
	
	func writeSquareImage(image: NSImage, toSize size: Int, inFolder path: String) {
		writeImage(image, toSize: CGSize(width: size, height: size), toPath: "\(path)/Image size \(size)")
	}
	
	@IBAction func typeChanged(sender: AnyObject) {
		print("Type changed")
		
		let window = NSApplication.sharedApplication().mainWindow!
		let format = typePickerIndex(rawValue: (dropPicker?.indexOfSelectedItem)!)!
		
		if format.indexIsIcon() {
			nameTextField.hidden = true
		}
		
		/*
		// This code is no longer used. It is replaced by the
		// above if statement as it makes more maintainable code.
		switch format {
		case .iphone, .mac:
			nameTextField.hidden = true
			
		default:
			print("Nothing needed")
		}
*/
		
		if format == .animation {
			var x = CGFloat(0)
			
			if hidden {
				x = CGFloat(41)
			}
			
			window.setFrame(NSRect(x: window.frame.origin.x, y: window.frame.origin.y - x, width: fullWidth, height: fullHeight), display: true, animate: true)
			
			myView.hidden = false
			hidden = false
			exportAnimationsButton.hidden = false
			
			table.reloadData()
			
		} else {
			var x = CGFloat(0)
			
			if !hidden {
				x = CGFloat(41)
			}
			
			myView.hidden = true
			hidden = true
			exportAnimationsButton.hidden = true
			
			window.setFrame(NSRect(x: window.frame.origin.x, y: window.frame.origin.y + x, width: collapsedWidth, height: collapsedHeight), display: true, animate: true)
			
			images = [NSImage]()
		}
		
		if format.indexIsIcon() {
			nameTextField.hidden = true
		} else {
			nameTextField.hidden = false
		}
		
		/*
		// This switch statement is no longer used in favor of the
		// more maintainable if above.
		switch format {
		case .iphone, .mac:
			nameTextField.hidden = true
			
		case .asset, .animation:
			nameTextField.hidden = false
			
		default:
			print("wat")
		}
*/
		
		nameTextField.stringValue = ""
	}
	
	@IBAction func buttonPressed(sender: AnyObject) {
		print(images.count)
		let ret = makeFolder()
		let folder = ret.folder
		let name = ret.name
		
		if folder.characters.count == 0 {
			return
		}
		
		for i in 0..<images.count {
			saveSizedImage(images[i], toPath: folder, forNumber: i + 1, withName: nameTextField.stringValue)
		}
		
		let not = NSUserNotification()
		not.title = "Complete"
		not.informativeText = "Your images are in  a folder called \(name) on the Desktop"
		
		not.deliveryDate = NSDate()
		
		NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(not)
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = (tableView.makeViewWithIdentifier("MyImagesCell", owner: self) as! MyImagesCell)
		
		for v in cell.subviews {
			if let iv = v as? NSImageView {
				iv.image = images[row]
			}
		}
		cell.imageNumberLabel.stringValue = "Image \(row + 1)"
		
		cell.currentView = self
		
		if cells.contains(cell) {
		} else {
			cells.append(cell)
		}
		
		return cell
	}
	
	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		return 70
	}
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return images.count
	}
	
	func tableView(tableView: NSTableView, didClickTableColumn tableColumn: NSTableColumn) {
		tableView.deselectAll(self)
	}
	
	func makeFolder() -> (folder: String, name: String) {
		let directory = NSFileManager.defaultManager()
		
		let dateFormat = NSDateFormatter()
		
		dateFormat.dateFormat = "MM-dd-yyyy hh.mm.ss"
		
		let name = dateFormat.stringFromDate(NSDate())
		
		let folder = "\(NSHomeDirectory())/Desktop/\(name)"
		
		do {
			try directory.createDirectoryAtPath(folder, withIntermediateDirectories: true, attributes: nil)
		} catch {
			return ("", "")
		}
		
		return (folder, name)
	}
	
	func saveSizedImage(image: NSImage, toPath folder: String, forNumber num: Int?, withName name: String?) {
		var s = "Image"
		
		if let str = name {
			s = str
		}
		
		if let n = num {
			s = "\(s)\(n)"
		}
		
		writeImage(image, toSize: image.size, toPath: "\(folder)/\(s)@3x")
		writeImage(image, toSize: NSSize(width: image.size.width/3.0, height: image.size.height/3.0), toPath: "\(folder)/\(s)")
		writeImage(image, toSize: NSSize(width: image.size.width/3.0*2.0, height: image.size.height/3.0*2.0), toPath: "\(folder)/\(s)@2x")
	}
	
	func removeCell(cell: MyImagesCell) {
		var index = 0
		
		for i in 0..<cells.count {
			if cells[i] == cell {
				index = i
				break
			}
		}
		
		images.removeAtIndex(index)
		cells.removeAtIndex(index)
		
		self.table.removeRowsAtIndexes(NSIndexSet(index:index),
		                               withAnimation: NSTableViewAnimationOptions.SlideRight)
	}
}

