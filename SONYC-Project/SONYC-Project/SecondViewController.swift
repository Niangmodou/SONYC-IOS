//
//  SecondViewController.swift
//  SONYC-Project
//
//  Created by Modou Niang on 6/22/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit
import AVFoundation

class SecondViewController: UIViewController, AVAudioRecorderDelegate{
    
    //Dictionary to store recordings information. {FilePath:[Avg,Min,Max]}
    var recordings: [URL: [Int]] = [:]
    
    //Outlet for table view
     @IBOutlet weak var myTableView: UITableView!
    
    //Variable to track number of current recordings
    var numRecords : Int = 0
    
    //Variables for audio player
    var audioPlayer: AVAudioPlayer!
    
    //Variable to store path for current audio file
    var currPath: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    func addNewRecording(filePath: URL, avg: Int, min: Int, max: Int) {
        var decibelArray: [Int] = []
        //Creating array to store decibel readings for current recording
        decibelArray.append(avg)
        decibelArray.append(min)
        decibelArray.append(max)
        
        recordings[filePath] = decibelArray
        
        print(recordings.count)
    }
}

extension SecondViewController: UITableViewDelegate {
    //Listening to a tapped recording
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
            //Getting index of the tapped recording
            let intIndex = indexPath.row
            let index = recordings.index(recordings.startIndex, offsetBy: intIndex)
            
            //Getting audio of specified index
            audioPlayer = try AVAudioPlayer(contentsOf: recordings[index].key)
            audioPlayer.play()
        }catch{
            
        }
    }
}

extension SecondViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String("Recording #\(indexPath.row + 1)")
        
        return cell
    }
}

/*
 TO-DO____________
1. fix overrite audio issue
2. create a dictionary for audio data
3. audio is playing
4. tableview style
5. succesful deletions
6. decibel readings
 */
