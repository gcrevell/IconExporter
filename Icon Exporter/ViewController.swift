//
//  ViewController.swift
//  Icon Exporter
//
//  Created by Voltage on 7/14/15.
//  Copyright © 2015 Gabriel Revells. All rights reserved.
//

import Cocoa

/**
 Type indexes. Correlates to the dropdown menu values.
 
 The enumeration of the indexes of the given options for
 exporting images.
*/
enum typePickerIndex:Int {
	case iphone = 0
	case ipad
	case universal
	case mac
	case asset
	case animation
	
	func indexIsIcon() -> Bool {
		if self.rawValue <= 3 {
			return true
		}
		
		return false
	}
}

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate {
	
    // References to storyboard elements
	@IBOutlet weak var imageDropper: NSImageView!
	@IBOutlet weak var dropPicker: NSPopUpButton!
	@IBOutlet weak var myView: NSView!
	@IBOutlet weak var table: NSTableView!
	@IBOutlet weak var exportAnimationsButton: NSButton!
	@IBOutlet weak var nameTextField: NSTextField!
	
    // Images and cells arrays. Used to store cells and images for animations
	var images = [NSImage]()
	var cells = [MyImagesCell]()
	
    // State variables to track if its collapsed or not
	var fullWidth: CGFloat!
	var collapsedWidth: CGFloat!
	var fullHeight: CGFloat!
	var collapsedHeight: CGFloat!
	var hidden = true
    
    // Image for the image dropper
    let DEFAULT_IMAGE = NSImage(named: "Drag Image Here")
	
    // View did load function
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
        
        // Unhighlight the image dropper
		imageDropper.highlighted = false
		
        // Reset the drop down menu
		dropPicker.removeAllItems()
		dropPicker.addItemsWithTitles(["iPhone App Icons", "iPad App Icons", "Universal iOS App Icons", "Mac App Icons", "Image Assets (1, 2, 3x)", "Animations"])
		
        // Setup the current view
		myView.wantsLayer = true
		myView.layer!.backgroundColor = NSColor.blueColor().CGColor
		myView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.OnSetNeedsDisplay
		
        // Setup width and height values
		fullWidth = CGFloat(728)
		collapsedWidth = fullWidth - myView.frame.width - 8
		
		fullHeight = CGFloat(374)
		collapsedHeight = fullHeight - 41
		
        // Hide the export button and name field
		exportAnimationsButton.hidden = true
		nameTextField.hidden = true
	}
	
    /// Not sure...
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
    /**
     Dropped an image in the main image dropper.
     
     Called when an image file is dropped into the main image dropper in the app.
     Checks if the image should be (and is) square, adds to the animations list
     if animations is the currently selected output. It then makes the folder
     and exports the images and schedules a notification that it completed.
     
     @param sender The object that called the function. An image dropper for
     this function
    */
	@IBAction func imageDropped(sender: AnyObject) {
        // Get dropped image and set image dropper to origional image
		let droppedImage = imageDropper.image!
		imageDropper.image = DEFAULT_IMAGE
		
		print("Dropped image is of size \(droppedImage.size)")
		
        // Get the current selected output format
		let format = typePickerIndex(rawValue: dropPicker.indexOfSelectedItem)!
		
        // If the format is an icon...
		if format.indexIsIcon()  {
            // ...and not square...
			if droppedImage.size.width != droppedImage.size.height {
                // Tell the user
				let alert = NSAlert()
				
				alert.messageText = "Whoa there."
				alert.informativeText = "You can't make an app icon out of a non square image."
				alert.addButtonWithTitle("Hail Voltage")
				alert.addButtonWithTitle("I'll do better")
				
				alert.alertStyle = NSAlertStyle.CriticalAlertStyle
				
				alert.runModal()
				
                // Cancel
				return
			}
		}
		
		if format == .animation {
            // If we're doing animations, add it to the list and reload the table
			images.append(droppedImage)
			table.reloadData()
			return
		}
		
		// Make the folder
		let ret = makeFolder()
		let folder = ret.folder
		let name = ret.name
		
        // Folder function failed
		if folder.characters.count == 0 {
            print("Fail at line \(#line) in function \(#function)")
			return
		}
		
        // Get image name or leave it as nil if no name is entered
        var imageName:String? = nil
        if nameTextField.stringValue != "" {
            imageName = nameTextField.stringValue
        }
		
        // Export the images based on the selected format
		if format == .iphone {
			// iPhone Icons
			writeSquareImage(droppedImage, toSize: 58, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 87, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 80, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 120, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 180, inFolder: folder)
		} else if format == .asset {
			// Image assets (1,2,3x)
			saveSizedImage(droppedImage, toPath: folder, forNumber: nil, withName: imageName)
		} else if format == .mac {
			// Mac icons
			writeSquareImage(droppedImage, toSize: 1024, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 512, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 256, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 128, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 64, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 32, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 16, inFolder: folder)
		} else if format == .ipad {
			// iPad icons
			writeSquareImage(droppedImage, toSize: 29, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 58, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 40, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 80, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 76, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 152, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 167, inFolder: folder)
		} else if format == .universal {
			// Universal icons (iPhone and iPad)
			writeSquareImage(droppedImage, toSize: 58, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 80, inFolder: folder)
			
			// iPhone icons
			writeSquareImage(droppedImage, toSize: 87, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 120, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 180, inFolder: folder)
			
			//iPad icons
			writeSquareImage(droppedImage, toSize: 29, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 40, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 76, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 152, inFolder: folder)
			writeSquareImage(droppedImage, toSize: 167, inFolder: folder)
		}
		
        // Create and display a notification about the exort being completed
		let not = NSUserNotification()
		not.title = "Complete"
		not.informativeText = "Your images are in  a folder called \(name) on the Desktop"
		not.contentImage = droppedImage
		
		not.deliveryDate = NSDate()
		
		NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(not)
	}
	
    /**
     Write an image, of a specific size, to the given path.
     
     This function takes a size and rescales the image to the size and exports
     it to the given path.
     
     @param image The image to resize
     @param size The CGSize value to change the image to
     @param path The path to save the image to
    */
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
	
    /**
     Wrapper for writeImage. Writes an image to be square.
     
     This function writes a provided image into a square size at a given path.
     
     @param image The image to resize
     @param size The int value to change the image width and height to
     @param path The path to save the image to
    */
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
    
    //MARK: - Table View
	
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
	
    /**
     Make a folder directly on the Desktop, named the current date and time
     
     Function to create a new, empty folder on the desktop. The name of
     the new folder is the current date/time.
     
     @return folder - A reference to the folder created
     @return name - The name of the folder created
    */
	func makeFolder() -> (folder: String, name: String) {
        // Create a directory manager
		let directory = NSFileManager.defaultManager()
		
        // Create string of formatted date/time
		let dateFormat = NSDateFormatter()
		dateFormat.dateFormat = "MM-dd-yyyy hh.mm.ss"
		let name = dateFormat.stringFromDate(NSDate())
		
        // The folders path
		let folder = "\(NSHomeDirectory())/Desktop/\(name)"
		
		do {
            // Create the folder
			try directory.createDirectoryAtPath(folder, withIntermediateDirectories: true, attributes: nil)
		} catch {
            // Failed to create folder. Error
            print("Failed to create the folder!!")
            print("Fail at line \(#line) in function \(#function)")
			return ("", "")
		}
		
        // Return the folder path and name
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
		writeImage(image, toSize: NSSize(width: image.size.width/3.0, height: image.size.height/3.0), toPath: "\(folder)/\(s)@1x")
		writeImage(image, toSize: NSSize(width: image.size.width/3.0*2.0, height: image.size.height/3.0*2.0), toPath: "\(folder)/\(s)@2x")
	}
	
    /**
     Remove a cell from the list of table cells.
     
     This function takes a cell and removes the image from the array of
     images in the animation and removes the cell from the table view.
     
     @param cell The cell to be removed
     
     TODO: Possibly pass index rather than cell?
    */
	func removeCell(cell: MyImagesCell) {
        // Set default index to -1
		var index = -1
		
        // Loop through the list of cells and find the index of the given
        // cell.
		for i in 0..<cells.count {
			if cells[i] == cell {
				index = i
				break
			}
		}
		
        // Remove the image and cell
		images.removeAtIndex(index)
		cells.removeAtIndex(index)
		
        // Remove the cell from the table view
		self.table.removeRowsAtIndexes(NSIndexSet(index:index),
		                               withAnimation: NSTableViewAnimationOptions.SlideRight)
	}
}

