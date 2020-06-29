//
//  FirstViewController.swift
//  SONYC-Project
//
//  Created by Modou Niang on 6/22/20.
//  Copyright © 2020 modouniang. All rights reserved.
//
import UIKit
import AVFoundation
import Foundation
import CoreAudio
import CoreAudioKit
import AVKit
import CoreData

class RecordViewController: UIViewController, AVAudioRecorderDelegate{
    
    //Variable for Gauge ShapeLayer
    let shapeLayer = CAShapeLayer()
    
    //Variable to track current decibel readings
    var decibels : Int = 0
    var minDecibels: Int = 0
    var maxDecibels: Int = 0
    var avgDecibels: Int = 0
    
    //Array to store all decibel readings
    var decibelReadings: [Int] = []
    
    //Label to display currnet decibel reading
    let label: UILabel = {
        let label = UILabel()
        label.text = "0dB"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        
        return label
    }()
    
    //Varialbe to store path of current recording
    var path: String = ""
    
    //Variables for storing recording session and audio recorder
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    //Variable to update the sound meter every 0.1 seconds
    var timer: Timer?
    
    //Varaible to get the id of the current recording
    var prevID: Int = 0
    
    //Variable to store retrieved data from CoreData
    var myData: [NSManagedObject] = []
    
    //Button to start recording
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
          super.viewDidLoad()
          deleteAllData()
          getData()
          createDecibelGauge()
          
          //Setting Up Audio Recording Session
          recordingSession = AVAudioSession.sharedInstance()
      }
    
    //Function to record user's mictrophone
    @IBAction func record(_ sender: Any) {
        //Check for active recording
        if audioRecorder == nil {
            prevID = getCurrID()
            
            let fileName = getPathDirectory().appendingPathComponent("test\(minDecibels+maxDecibels+avgDecibels).m4a")
                path = fileName.absoluteString
    
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
                    
                startMonitoring()
                    
                button.setTitle("Stop Recording", for: .normal)
                button.setTitleColor(UIColor.red, for: .normal)
            }catch {
                displayAlert(title: "Error", message: "Recording Failed")
                }
            }else{
                //Stop Recording
                stopMonitoring()
                
                button.setTitle("Record Sound", for: .normal)
                button.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
    //Function to start voice and decibel monitoring
    func startMonitoring(){
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record(forDuration: 10)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {(timer) in
            if self.audioRecorder != nil {
                self.decibels = self.calculateSPL(audioRecorder: self.audioRecorder)
                self.decibelReadings.append(self.decibels)
            }
        })
    }
    
    //Function to stop current audio recording
    func stopMonitoring() {
        audioRecorder.stop()
        audioRecorder = nil
        
        //Resetting decibels alongside decibel gauge
        decibels = 0
        self.label.text = "\(decibels)dB"
        shapeLayer.strokeEnd = 0
        
        //Getting decibel readings for current session
        avgDecibels = getAvgDecibel()
        minDecibels = getMinDecibel()
        maxDecibels = getMaxDecibel()
        
        //Clear Decibel Readings for session
        decibelReadings.removeAll()
        
        //Saving recording data to CoreData
        saveData(filePath: path, avg: avgDecibels, min: minDecibels, max: maxDecibels)
        
        //Performing Segue to send data to second viewcontroller
        self.performSegue(withIdentifier: "pipeline", sender: self)
    }
    
    //Function to send recording information to TableView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination as! RecordListViewController

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
    
    //Function to save an instance of a recording to CoreData
    func saveData(filePath: String, avg: Int, min: Int, max: Int){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Recording", in: context)
        
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        
        newEntity.setValue(filePath,forKey: "filePath")
        newEntity.setValue(avg, forKey: "avgDecibel")
        newEntity.setValue(min, forKey: "minDecibel")
        newEntity.setValue(max, forKey: "maxDecibel")
        
        let currID: Int = getCurrID()
        newEntity.setValue(currID, forKey: "id")
        
        do{
            try context.save()
            print("Saved")
        }catch{
            print("failed")
        }
    }
    
    //Function to delete all instances of Recording in CoreData
    func deleteAllData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recording")
        fetchRequest.returnsObjectsAsFaults = false

        do{
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results{
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error {
            print("Error: \(error) :(")
        }
    }
    
    //Function to get the current ID of the record
    func getCurrID() -> Int{
        if myData.count == 0 {
            return 0
            
        }else{
            //Get the previous recording's ID
            let prevNum = myData[myData.count - 1].value(forKey: "id") as! Int
            
            return prevNum+1
        }
    }
    //Function to get the minium decibel in the recording
    func getMinDecibel() -> Int {
        var currMin: Int = Int.max
        for decibel in decibelReadings {
            if decibel < currMin {
                currMin = decibel
            }
        }
        
        return currMin
    }

    
    //Function to get the maximum decibel in the recording
    func getMaxDecibel() -> Int {
        var currMax: Int = Int.min
        for decibel in decibelReadings {
            if decibel > currMax{
                currMax = decibel
            }
        }
        
        return currMax
    }
    
    //Function to the average decibel in the recording
    func getAvgDecibel() -> Int {
        var sum: Int = 0
        
        for decibel in decibelReadings {
            sum += decibel
        }
        
        //Maybe handle division by Zero error????
        let avg: Int = sum/decibelReadings.count
        
        return avg
    }
    
    //Function to update the audio recorder and text
    func update(){
        if let audioRecorder = audioRecorder {
            audioRecorder.updateMeters()
            self.label.text = "\(decibels)dB"
            
            updateMeter()
        }
    }
    
    //Function to calculate the decibels
    func calculateSPL(audioRecorder : AVAudioRecorder) -> Int {
        update()
        
        //Get Current decibels for sound
        let spl = audioRecorder.averagePower(forChannel: 0)
        let decibels : Int = Int(abs(spl))//pow(10.0, spl/20.0) * 20//20 * log10(spl)
    
        return decibels
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
    
    //Function to convert hexadecimal color into type UIColor
    func getColorByHex(rgbHexValue:UInt32, alpha:Double = 1.0) -> UIColor {
        let red = Double((rgbHexValue & 0xFF0000) >> 16) / 256.0
        let green = Double((rgbHexValue & 0xFF00) >> 8) / 256.0
        let blue = Double((rgbHexValue & 0xFF)) / 256.0

        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    //Function to update gauge after decibel change
    private func updateMeter() {
        shapeLayer.strokeEnd = 0
        
        DispatchQueue.main.async {
            self.label.text = "\(self.decibels)dB"
            
            self.shapeLayer.strokeEnd = CGFloat(self.getPercent())
        }
    }
 
    //Function to get current percent of gauge fill
    func getPercent() -> Float {
        let decibelRatio = Float(decibels)/120
        
        return (decibelRatio*90)/120
    }
    
    //Function to create the decibel gauge
    fileprivate func createDecibelGauge() {
        let center = view.center
        
        //Creating a label to display decibel readings
        view.addSubview(label)
        label.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        label.center = center
        
        //Creating Decibel Gauge
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        
        //Gauge TrackLayer configurations
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = getColorByHex(rgbHexValue:0xE6F4F1).cgColor
        trackLayer.lineWidth = 15
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = center
        view.layer.addSublayer(trackLayer)
        
        //Gauge ShapeLayer configurations
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = getColorByHex(rgbHexValue:0x32659F).cgColor
        shapeLayer.lineWidth = 15
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = center
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
        
        shapeLayer.transform = CATransform3DMakeRotation(-5*CGFloat.pi/4, 0, 0, 1)
    }

}

