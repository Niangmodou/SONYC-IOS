//
//  ViewController.swift
//  SONYC Initial Project Part 2
//
//  Created by Modou Niang on 6/10/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import CoreAudio
import CoreAudioKit
import AVKit

class ViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    //Variables for storing recording session and audio recorder
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    //Variable to track current decibel
    var decibels : Float = 0.0
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBAction func record(_ sender: Any) {
        //Check for active recording
        if audioRecorder == nil {
            let fileName = getPathDirectory().appendingPathComponent("test.m4a")
                
                //Define settings for current recording
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
                
                //Start Audio recording
                do {
                    audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                    audioRecorder.delegate = self
                    audioRecorder.isMeteringEnabled = true
                    
                    audioRecorder.record()
                    decibels = calculateSPL(audioRecorder: audioRecorder)
                    
                    //Refresh table to show new recording
                    myTableView.reloadData()
                    
                    
                    button.setTitle("Stop Recording", for: .normal)
                    button.setTitleColor(UIColor.red, for: .normal)
                }catch {
                    displayAlert(title: "Error", message: "Recording Failed")
                }
            }else{
                //Stop Recording
                audioRecorder.stop()
                audioRecorder = nil
            
                //Refresh table to show new recording
                myTableView.reloadData()
                
                button.setTitle("Record Sound", for: .normal)
                button.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
    func update(){
        if let audioRecorder = audioRecorder {
            audioRecorder.updateMeters()
        }
    }
    
    func calculateSPL(audioRecorder : AVAudioRecorder) -> Float {
        audioRecorder.updateMeters()
        //Get Current decibels for sound
        decibels = audioRecorder.averagePower(forChannel: 0)
    
        return abs(decibels)
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
    }

    //Setting up tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }

    //Inserting a new recording to tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String("\(decibels)dB")
           
        return cell
    }

}

