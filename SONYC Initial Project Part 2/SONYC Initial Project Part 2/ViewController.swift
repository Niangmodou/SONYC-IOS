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

class ViewController: UIViewController, AVAudioRecorderDelegate{
    
    //Variable for Gauge ShapeLayer
    let shapeLayer = CAShapeLayer()
    
    //Variable to track current decibels
    var decibels : Int = 0
    var minDecibels: Int = 0
    var maxDecibels: Int = 0
    var avgDecibels: Int = 0
    
    //Label to display currnet decibel reading
    let label: UILabel = {
        let label = UILabel()
        label.text = "0dB"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        
        return label
    }()
    
    
    //Variables for storing recording session and audio recorder
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    //Variable to update the sound meter every 0.1 seconds
    var timer: Timer?
    
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
                    
                    startMonitoring()
                    //decibels = calculateSPL(audioRecorder: audioRecorder)
                    
                    
                    
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
    
    func startMonitoring(){
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {(timer) in
                self.decibels = self.calculateSPL(audioRecorder: self.audioRecorder)
            
        })
        
        //begin()
    }
    
    func getMinDecibel() {
        
    }
    
    func getMaxDecibel(){
        
        
    }
    
    func getAvgDecibel(){
        
    }
    
    func stopMonitoring() {
        audioRecorder.stop()
        audioRecorder = nil
        
        decibels = 0
    }
    
    func update(){
        if let audioRecorder = audioRecorder {
            audioRecorder.updateMeters()
            self.label.text = "\(decibels)dB"
            
            updateMeter()
        }
    }
    
    func calculateSPL(audioRecorder : AVAudioRecorder) -> Int {
        update()
        //Get Current decibels for sound
        let spl = audioRecorder.averagePower(forChannel: 0)
        print(spl)
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
    
    private func updateMeter() {
        print("Begin")
        shapeLayer.strokeEnd = 0
        
        DispatchQueue.main.async {
            self.label.text = "\(self.decibels)dB"
            print(self.getPercent())
            self.shapeLayer.strokeEnd = CGFloat(self.getPercent())
        }
    }
 
    
    //Function to get current percent of gauge fill
    func getPercent() -> Float {
        let decibelRatio = Float(decibels)/120
        
        return (decibelRatio*90)/120
    }
    
    fileprivate func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation,forKey: "Stroke")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //Setting Up Session
        recordingSession = AVAudioSession.sharedInstance()

        // Ask user for permission to use microphone
        AVAudioSession.sharedInstance().requestRecordPermission{ (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
        
    }

}

