//
//  SecondViewController.swift
//  SONYC-Project
//
//  Created by Modou Niang on 6/22/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit
import AVFoundation

class SecondViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource{
    
    var avgDecibels = 0
    var minDecibels = 0
    var maxDecibels = 0
    
    var decibels: [Int] = []
    //Outlet for table view
     @IBOutlet weak var myTableView: UITableView!
    
    //Variable to track number of current recordings
    var numRecords : Int = 0
    
    //Variables for audio player
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func addNewRecording(decibel: Int) {
        decibels.append(decibel)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decibels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String("Decibel: \(decibels[0])")//String("Recording #\(indexPath.row + 1)")
        
        return cell
    }
}

