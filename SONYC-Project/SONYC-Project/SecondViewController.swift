//
//  SecondViewController.swift
//  SONYC-Project
//
//  Created by Modou Niang on 6/22/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

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
    
    var myData: [NSManagedObject] = []
    
    var filePath: URL!
    var minDecibels: Int = 0
    var maxDecibels: Int = 0
    var avgDecibels: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //deleteAllData()
        getData()
        
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    func getData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Recording")
        //fetch.returnsObjectsAsFaults = false
        
        do{
            //let results: [NSFetchRequest<NSManagedObject>] = try context.fetch
            
            myData = try context.fetch(fetch)
            
//            for data in results as! [NSManagedObject] {
//                filePath = data.value(forKey: "filePath") as! URL
//                avgDecibels = data.value(forKey: "avgDecibels") as! Int
//                minDecibels = data.value(forKey: "minDecibels") as! Int
//                maxDecibels = data.value(forKey: "maxDecibels") as! Int
//
//                print(myData)
//            }
        }catch{
            print("Error :(")
        }
    }
    
    //Function to delete all instances of Recording in CoreData
    func deleteAllData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recording")
        fetchRequest.returnsObjectsAsFaults = false

        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch {
            //print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
    func addNewRecording(filePath: URL, avg: Int, min: Int, max: Int) {
        //Creating array to store decibel readings for current recording
        var decibelArray: [Int] = []
        
        decibelArray.append(avg)
        decibelArray.append(min)
        decibelArray.append(max)
        
        recordings[filePath] = decibelArray
        
        //print(recordings.count)
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
        //Getting the index of the current recording
        let intIndex = indexPath.row
        let index = recordings.index(recordings.startIndex, offsetBy: intIndex)
        
        //Assigning decibel readings to variables
        let avgDecibel = recordings[index].value[0]
        let minDecibel = recordings[index].value[1]
        let maxDecibel = recordings[index].value[2]
        
        //Assigning text label of cell to decibel readings
        cell.textLabel?.text = String("Avg: \(avgDecibel)dB| Min: \(minDecibel)dB| Max: \(maxDecibel)dB")
        
        return cell
    }
}

/*
 TO-DO____________
1. fix overrite audio issue
2. create a dictionary for audio data
3. make sure audio is playing
4. tableview style
5. succesful deletions
6. decibel readings
7. Make sure monitoring stops after 10 seconds
 */
