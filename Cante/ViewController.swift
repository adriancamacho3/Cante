//
//  ViewController.swift
//  Cante
//
//  Created by Adrián Camacho Gil on 23/3/18.
//  Copyright © 2018 cofla. All rights reserved.
//

import Cocoa
import CSV
import AVFoundation
//import Charts
//import MIKMIDI

var onset: [String] = []
var duration: [String] = []
var MIDInote: [String] = []

var flag: Bool = false
var exists: Bool = false


var path: String = ""
var songs = [String]()

var valueProgressBar: Int = -1
var finalValueProgressBar: Int = -1

var CppClassInstance: [CppWrapper] = []

var image:NSImage!

var beforeImage:NSImage!

var statusOfTheApp:Int = 0
// statusOfTheApp
// 0 = No file added
// 1 = Audio file added
// 2 = Folder added
// 3 = Transcription Complete

class ViewController: NSViewController, DataModelDelegate {
    
    @IBOutlet weak var imageView: NSImageView!                  // Show images
    @IBOutlet weak var dragView: DragView!                      // Place to drag items
    @IBOutlet weak var progressBar: NSProgressIndicator!        // Progress Bar
    @IBOutlet weak var transcribeButton: NSButton!              // Button to run the code
    @IBOutlet weak var progressIndicator: NSProgressIndicator!  // Circle Progress Status
    @IBOutlet weak var midiButton: NSButton!
    @IBOutlet weak var csvButton: NSButton!
    @IBOutlet weak var jpgButton: NSButton!
    
    @IBAction func csvButtonAction(_ sender: Any) {
        // Write csv
        for i in 0...songs.count-1 {
            let stream = OutputStream(toFileAtPath: path + "/" + songs[i].split(separator: ".")[0] + ".csv", append: false)!
            let csv = try! CSVWriter(stream: stream)
            
            for index in 0...onset.count-1 {
                try! csv.write(row: [onset[index], duration[index], MIDInote[index]])
            }
            csv.stream.close()
        }
    }
    
    @IBAction func midiButtonAction(_ sender: Any) {
    }
    
    @IBAction func jpgButtonAction(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set the delegate from de drag view
        dragView.delegate = self
        
        // Timers
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setProgressBar), userInfo: nil, repeats: true)
        
        // Set initial image
        image = NSImage(named:NSImage.Name(rawValue: "add.png"))
        imageView.image = image
        
        // Disable button
        transcribeButton.isEnabled = false
        
        // PRUEBA ***
        hideExportButtons()
    }
    
    // Process new Data  (callback from dragView)
    func newData() {
        // clear
        path = ""
        songs.removeAll()
        
        // Disable button
        hideExportButtons()
        
        // Set Progress Bar to 0 (if finalValueProgressBar is equal to -1)
        finalValueProgressBar = -1
        
        // Check if item drag to dragView is a directory or a file
        var directory: ObjCBool = ObjCBool(false)
        exists = FileManager.default.fileExists(atPath: dragView.filePath!, isDirectory: &directory)
        
        if exists && directory.boolValue {
            // It's a Directory.
            let fileManager = FileManager.default
            // Get contents in directory
            do {
                path = dragView.filePath!
                songs = try fileManager.contentsOfDirectory(atPath: dragView.filePath!)
                
                //Only keep .wav
                for (i,song) in songs.enumerated().reversed() {
                    if song.split(separator: ".").endIndex == 2 {
                        if song.split(separator: ".")[1] != "wav" {
                            songs.remove(at: i)
                        }
                    } else {
                        songs.remove(at: i)
                    }
                }
                
                print("It's a Directory")
                print(path)
                print(songs)
                
                statusOfTheApp = 2
                
            }
            catch let error as NSError {
                print("\(error)")
            }
        } else if exists {
            // It's a File.
            let splitPath = dragView.filePath!.split(separator: "/")
            for i in splitPath.dropLast() {
                path = path + "/" + i
            }
            songs.append(String(splitPath.last!))
            
            print("It's a File")
            print(path)
            print(songs)
            
            statusOfTheApp = 1
            
        }
        
        // Enable button
        transcribeButton.isEnabled = true
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        
        // You can not drag
        dragView.isHidden = true
        
        // Enable convertirButton
        transcribeButton.isEnabled = false
        
        // Set Progress Indicator On
        progressIndicator.startAnimation(nil)
        
        // Set converting image
        image = NSImage(named:NSImage.Name(rawValue: "converting.png"))
        self.imageView.image = image
        
        // Clear onset, duration and MIDInote
        onset.removeAll()
        duration.removeAll()
        MIDInote.removeAll()
        
        DispatchQueue.global(qos: .background).async { // Working in background
            
            for i in 0...songs.count-1 {
                // Set Progress Bar Values
                valueProgressBar = i+1
                finalValueProgressBar = songs.count
                
                // Call Transcribe Code
                CppClassInstance.append(CppWrapper())
                CppClassInstance[i].runCode(path + "/" + songs[i])
            }
            
            DispatchQueue.main.async { // When transcription finish
                
                for i in 0...songs.count-1 {
                    let csvFileArray = CppClassInstance[i].getCsv()!
                    
                    for csvItems in csvFileArray {
                        let string = "\(csvItems)"
                        let stringSeparated = string.components(separatedBy: ",")
                        onset.append(stringSeparated[0].components(separatedBy: CharacterSet.init(charactersIn: "0123456789.").inverted).joined(separator: ""))
                        duration.append(stringSeparated[1].components(separatedBy: CharacterSet.init(charactersIn: "0123456789.").inverted).joined(separator: ""))
                        MIDInote.append(stringSeparated[2].components(separatedBy: CharacterSet.init(charactersIn: "0123456789.").inverted).joined(separator: ""))
                    }
                    
                    
                }
                
                // Set Progress Bar to 0
                finalValueProgressBar = -1
                
                // Enable button
                self.transcribeButton.isEnabled = true
                
                // Set Progress Indicator Off
                self.progressIndicator.stopAnimation(nil)
                
                // Set complete image
                image = NSImage(named:NSImage.Name(rawValue: "complete.png"))
                self.imageView.image = image
                
                // Set add image two seconds later
                //Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setAddImage), userInfo: nil, repeats: false)
                
                // Show Buttons
                self.showExportButtons()
                
                self.imageView.image = nil          // Hide image
                statusOfTheApp = 3                  // Status of the app 3
                self.dragView.isHidden = false      // You can drag again
                
            }
        }
    }
    
    @objc func setProgressBar() {
        if (finalValueProgressBar != -1) {
            self.progressBar.doubleValue = Double(valueProgressBar*100/finalValueProgressBar)
        } else {
            self.progressBar.doubleValue = 0
        }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // Callbacks from dragView
    func dragExited() {
        switch statusOfTheApp {
        case 0:
            image = NSImage(named:NSImage.Name(rawValue: "add.png"))
            imageView.image = image
        case 1:
            image = NSImage(named:NSImage.Name(rawValue: "audio.png"))
            imageView.image = image
        case 2:
            image = NSImage(named:NSImage.Name(rawValue: "folder.png"))
            imageView.image = image
        case 3:
            showExportButtons()
            imageView.image = nil
        default:
            print("Error")
        }
    }
    
    func hideExportButtons() {
        midiButton.isHidden = true
        csvButton.isHidden = true
        jpgButton.isHidden = true
    }
    
    func showExportButtons() {
        midiButton.isHidden = false
        csvButton.isHidden = false
        jpgButton.isHidden = false
    }
    
    func itIsDirectory() {
        hideExportButtons()
        image = NSImage(named:NSImage.Name(rawValue: "folder.png"))
        imageView.image = image
    }
    
    func itIsFile() {
        hideExportButtons()
        image = NSImage(named:NSImage.Name(rawValue: "audio.png"))
        imageView.image = image
    }
    
}

