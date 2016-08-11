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
    case watch
	case asset
	case animation
	
	func indexIsIcon() -> Bool {
		if self.rawValue <= 4 {
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
		dropPicker.addItemsWithTitles(["iPhone App Icons", "iPad App Icons", "Universal iOS App Icons", "Mac App Icons", "Apple Watch Icons", "Image Assets (1, 2, 3x)", "Animations"])
		
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
                // ...tell the user...
				let alert = NSAlert()
				
				alert.messageText = "Whoa there."
				alert.informativeText = "You can't make an app icon out of a non square image."
				alert.addButtonWithTitle("Hail Voltage")
				alert.addButtonWithTitle("I'll do better")
				
				alert.alertStyle = .Critical
				
				alert.runModal()
				
                // ...and cancel
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
		let ret = Helpers.makeFolder()
		let folder = ret.path
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
            Helpers.writeSquareImage(droppedImage,
                                          toSizes: [40, 58, 80, 87, 80, 120, 180],
                                          inFolder: folder)
		} else if format == .asset {
			// Image assets (1,2,3x)
			Helpers.saveImageAsset(            droppedImage,
			                            toPath:     folder,
			                            forNumber:  nil,
			                            withName:   imageName)
		} else if format == .mac {
			// Mac icons
            Helpers.writeSquareImage(droppedImage,
                                          toSizes: [16, 32, 64, 128, 256, 512, 1024],
                                          inFolder: folder)
		} else if format == .ipad {
			// iPad icons
            Helpers.writeSquareImage(droppedImage,
                                          toSizes: [20, 29, 58, 40, 80, 76, 152, 167],
                                          inFolder: folder)
		} else if format == .universal {
			Helpers.writeSquareImage(droppedImage,
                                          // Universal Icons
                                          toSizes: [20, 29, 40, 50,
                                            57, 58, 60, 72, 76, 80,
                                            87, 100, 114, 120, 144,
                                            152, 167, 180],
                                          inFolder: folder)
        } else if format == .watch {
            Helpers.writeSquareImage(droppedImage,
                                     // Apple watch notification center
                                     toSizes: [48, 55,
                                        // Apple watch settings app
                                        58, 87,
                                        // Apple watch home screen
                                        80,
                                        // Short look
                                        172, 196],
                                     inFolder: folder)
        }
		
        // Create and display a notification about the exort being completed
		let not = NSUserNotification()
		not.title = "Complete"
		not.informativeText = "Your images are in  a folder called \(name) on the Desktop"
		not.contentImage = droppedImage
		
		not.deliveryDate = NSDate()
		
		NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(not)
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
		let ret = Helpers.makeFolder()
		let folder = ret.path
		let name = ret.name
		
		if folder.characters.count == 0 {
			return
		}
		
		for i in 0..<images.count {
			Helpers.saveImageAsset(images[i], toPath: folder, forNumber: i + 1, withName: nameTextField.stringValue)
		}
		
		Helpers.displayNotificationForFolder(name)
	}
    
    //MARK: - Table View
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = (tableView.makeViewWithIdentifier("MyImagesCell", owner: self) as! MyImagesCell)
		
		cell.displayedImage.image = images[row]
        
		cell.imageNumberLabel.stringValue = "Image \(row + 1)"
		
		cell.currentView = self
        
        if cells.count > row && cells[row] == cell {
            // Cells array contains current cell in the correct place
        } else if cells.count > row {
            cells[row] = cell
        } else {
            cells.insert(cell, atIndex: row)
        }
		
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
			if cells[i] === cell {
				index = i
				break
			}
		}
        
        print(index)
		
        // Remove the image and cell
		images.removeAtIndex(index)
		cells.removeAtIndex(index)
		
        // Remove the cell from the table view
		self.table.removeRowsAtIndexes(NSIndexSet(index:index),
		                               withAnimation: NSTableViewAnimationOptions.SlideRight)
	}
}

