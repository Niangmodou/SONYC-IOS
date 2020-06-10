//
//  ViewController.swift
//  SONYC Initial Project
//
//  Created by Modou Niang on 6/10/20.
//  Copyright © 2020 modouniang. All rights reserved.
//


import UIKit
import AVFoundation

class ViewController : UIViewController, AVAudioRecorderDelegate {
    //Variables for recording session and audio recorder
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    //Variable to track number of current recordings
    var numRecords : Int = 0
    
    //Outlet for Button
    @IBOutlet weak var button: UIButton!
    
    //Action for record button
    @IBAction func record(_ sender: Any) {
        //Check for active recording
        if audioRecorder == nil {
            numRecords += 1
            
            let fileName = getPathDirectory().appendingPathComponent("\(numRecords).m4a")
            
            //Define settings for current recording
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Start Audio recording
            do {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                
                audioRecorder.record(forDuration: 10)
                
                button.setTitle("Stop Recording", for: .normal)
                button.setTitleColor(UIColor.red, for: .normal)
            }catch {
                displayAlert(title: "Error", message: "Recording Failed")
            }
        }else{
            //Stop Recording
            audioRecorder.stop()
            audioRecorder = nil
            
            //Saving number of recording to user defaults
            UserDefaults.standard.set(numRecords, forKey: "myNumber")
            button.setTitle("Record Sound", for: .normal)
            button.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting Up Session
        recordingSession = AVAudioSession.sharedInstance()
        
        if let number : Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            numRecords = number
        }
        // Ask user for permission to use microphone
        AVAudioSession.sharedInstance().requestRecordPermission{ (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
        
        //UI Button for user to record
    }
    
    //Gets path to directory
    func getPathDirectory() -> URL {
        //Searches a FileManager for paths and returns the first one
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        
        return documentDirectory
    }
    
    //Displays alert
    func displayAlert(title:String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated:true, completion: nil)
    }
}

