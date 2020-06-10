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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting Up Session
        recordingSession = AVAudioSession.sharedInstance()
        
        // Ask user for permission to use microphone
        AVAudioSession.sharedInstance().requestRecordPermission{ (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
        
        //UI Button for user to record
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

