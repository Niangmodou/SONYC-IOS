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
    
    var avgDecibels = 0
    var minDecibels = 0
    var maxDecibels = 0
    
    var decibels: [Int] = []
    
    var recordings: [URL] = []
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
    
    func addNewRecording(filePath: URL) {
        recordings.append(filePath)
        
        print(recordings.count)
    }
}

extension SecondViewController: UITableViewDelegate {
    //Listening to a tapped recording
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
            //Set up audio player
            audioPlayer = try AVAudioPlayer(contentsOf: currPath)
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

