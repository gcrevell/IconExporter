//
//  MyImageWell.swift
//  Icon Exporter
//
//  Created by Voltmeter Amperage on 7/11/16.
//  Copyright © 2016 Gabriel Revells. All rights reserved.
//

import Cocoa

class MyImageWell: NSImageView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Declare and register an array of accepted types
        registerForDraggedTypes([NSFilenamesPboardType, NSURLPboardType, NSPasteboardTypeTIFF])
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        Swift.print(checkGif(sender))
        
        return .Copy
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        let data = NSData(contentsOfURL: NSURL(fromPasteboard: sender.draggingPasteboard())!)
        
        if data!.subdataWithRange(NSMakeRange(0, 6)).isEqualToData(NSData(hexString: "474946383961")) {
            Swift.print("Here")
            
            return true
        } else {
            Swift.print("Not there")
            
            return false
        }
        
//        if let board = sender.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray {
//            
//            Swift.print(NSData(contentsOfURL: NSURL(fromPasteboard: sender.draggingPasteboard())!))
//        }
//        if let board = sender.draggingPasteboard().propertyList(forType: "NSFilenamesPboardType") as? NSArray,
//            imagePath = board[0] as? String {
//            // THIS IS WERE YOU GET THE PATH FOR THE DROPPED FILE
//            droppedFilePath = imagePath
//            return true
//        }
        return false
    }
    
    func checkGif(drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray,
            path = board[0] as? String {
            let url = NSURL(fileURLWithPath: path)
            if let fileExtension = url.pathExtension?.lowercaseString {
                return fileExtension == "gif"
            }
        }
        return false
    }
    
}
