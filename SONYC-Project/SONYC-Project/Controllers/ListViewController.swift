//
//  ListViewController.swift
//  SONYC-Project
//
//  Created by Modou Niang on 6/22/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class ListViewController: UIViewController, AVAudioRecorderDelegate{
    //Outlet for table view
    @IBOutlet weak var myTableView: UITableView!
    
    //Variables for audio player
    var audioPlayer: AVAudioPlayer!
    
    //Variable to store retrieved data from CoreData
    var myData: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Loading stored recording data from CoreData
        getData()
        
        //TableView setup
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    //Function to get current data from CoreData
    func getData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Recording")
        
        do{
            //Loading data from CoreData
            myData = try context.fetch(fetch)

        }catch let error{
            print("Error: \(error) :(")
        }
    }
}

extension SecondViewController: UITableViewDelegate {
    //Listening to a tapped recording
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
            //Getting the contents of the selected row
            let selectedRow = myData[indexPath.row]
            
            //Getting URL of selected audio
            let stringUrl: String = selectedRow.value(forKey: "filePath") as! String
            let currURL = URL(string: stringUrl)
            
            //Getting audio of specified index
            audioPlayer = try AVAudioPlayer(contentsOf: currURL!)
            audioPlayer.play()
        }catch{
            
        }
    }
}

extension SecondViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardCell
        
        //Getting the contents of the selected row
        let selectedRow = myData[indexPath.row]
        
        //Assigning decibel readings to variables
        let avgDecibel = selectedRow.value(forKey: "avgDecibel") as! Int
        let minDecibel = selectedRow.value(forKey: "minDecibel") as! Int
        let maxDecibel = selectedRow.value(forKey: "maxDecibel") as! Int
        
        //print("hi")
        //Assigning text label of cell to decibel readings
        cell.configure(recordNum: indexPath.row+1, avg: avgDecibel, min: minDecibel, max: maxDecibel)
        //cell.textLabel?.text = String("Avg: \(avgDecibel)dB| Min: \(minDecibel)dB| Max: \(maxDecibel)dB")
        
        return cell
    }
    
    //Remove a recording from CoreData by swiping right
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let commit = myData[indexPath.row]
            myData.remove(at: indexPath.row)
            context.delete(commit)
            
            do{
                try context.save()
                myTableView.deleteRows(at: [indexPath], with: .fade)
            }catch{
                print("Error Deleting")
            }

            myTableView.reloadData()
        }
    }
}

/*
 TO-DO____________
1. TableViews are not matching up
4. tableview style
6. decibel readings
7. Make sure monitoring stops after 10 seconds
 */
