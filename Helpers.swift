//
//  ImageHelpers.swift
//  Icon Exporter
//
//  Created by Gabriel Revells on 6/24/16.
//  Copyright © 2016 Gabriel Revells. All rights reserved.
//

import Cocoa

extension NSData {
    
    /// Return hexadecimal string representation of NSData bytes
    @objc(kdj_hexadecimalString)
    public var hexadecimalString: NSString {
        var bytes = [UInt8](count: length, repeatedValue: 0)
        getBytes(&bytes, length: length)
        
        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }
        
        return NSString(string: hexString)
    }
}

class Helpers: NSObject {
    
    /**
     Write an image, of a specific size, to the given path.
     
     This function takes a size and rescales the image to the size and exports
     it to the given path.
     
     @param image The image to resize
     @param size The CGSize value to change the image to
     @param path The path to save the image to
     */
    static func writeImage(image: NSImage, toSize size: CGSize, toPath path: String) {
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
    static func writeSquareImage(image: NSImage, toSizes sizes: [Int], inFolder path: String) {
        for size in sizes {
            Helpers.writeImage(image, toSize: CGSize(width: size, height: size), toPath: "\(path)/Image size \(size)")
        }
    }
    
    static func saveImageAsset(image: NSImage, toPath folder: String, forNumber num: Int?, withName name: String?) {
        var s = "Image"
        
        if let str = name {
            s = str
        }
        
        if let n = num {
            s = "\(s)\(n)"
        }
        
        Helpers.writeImage(image, toSize: image.size, toPath: "\(folder)/\(s)@3x")
        Helpers.writeImage(image, toSize: NSSize(width: image.size.width/3.0, height: image.size.height/3.0), toPath: "\(folder)/\(s)")
        Helpers.writeImage(image, toSize: NSSize(width: image.size.width/3.0*2.0, height: image.size.height/3.0*2.0), toPath: "\(folder)/\(s)@2x")
    }
    
    /**
     Make a folder directly on the Desktop, named the current date and time
     
     Function to create a new, empty folder on the desktop. The name of
     the new folder is the current date/time.
     
     @return folder - A reference to the folder created
     @return name - The name of the folder created
     */
    static func makeFolder() -> (path: String, name: String) {
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
    
    static func displayNotificationForFolder(folder: String) {
        let not = NSUserNotification()
        not.title = "Complete"
        not.informativeText = "Your images are in  a folder called \(folder) on the Desktop"
        
        not.deliveryDate = NSDate()
        
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(not)
    }

}
