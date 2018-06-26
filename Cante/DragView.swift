//
//  DragView.swift
//  Cante
//
//  Created by Adrián Camacho Gil on 3/5/18.
//  Copyright © 2018 cofla. All rights reserved.
//

import Cocoa

protocol DragViewDelegate {
    func dragView(didDragFileWith URL: NSURL)
}

// Callback functions
protocol DataModelDelegate: class {
    func itIsDirectory()
    func itIsFile()
    func dragExited()
    func newData()
}

class DragView: NSView {
    
    weak var delegate: DataModelDelegate?
    
    var filePath: String?       // path where the file (or directory) is
    let expectedExt = ["wav"]   // file extensions allowed for Drag&Drop (example: "jpg","png","docx", etc..)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        
        // clear
        self.filePath = ""
        
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        if isDirectory(sender) == true {
            // call itIsDirectory callback function
            delegate?.itIsDirectory()
            
            return .copy
        }else if checkExtension(sender) == true {
            // call itIsFile callback function
            delegate?.itIsFile()
            
            return .copy
        }else {
            return NSDragOperation()
        }
        
    }
    
    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return false }
        
        let suffix = URL(fileURLWithPath: path).pathExtension
        for ext in self.expectedExt {
            if ext.lowercased() == suffix {
                return true
            }
        }
        return false
    }
    
    fileprivate func isDirectory(_ drag: NSDraggingInfo) -> Bool {
        
        guard let board = drag.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return false }

        // Check if is a directory
        var directory: ObjCBool = ObjCBool(false)
        exists = FileManager.default.fileExists(atPath: path, isDirectory: &directory)
        
        if exists && directory.boolValue {
            // It's a Directory.
            return true
        }
        
        return false
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        // call dragExited callback function
        delegate?.dragExited()
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        // do noting
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pasteboard[0] as? String
            else { return false }
        
        // Set the path
        self.filePath = path
        
        // call newData callback function
        delegate?.newData()

        return true
    }
}

