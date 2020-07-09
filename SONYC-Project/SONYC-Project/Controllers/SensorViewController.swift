//
//  SensorViewController.swift
//  SONYC-Project
//
//  Created by Modou Niang on 7/2/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit

class SensorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSensor()
        
        addHamburgerIcon()
        
    }
    
    //Adding the Sensor Button
    func addSensor(){
        let image = UIImage(named: "logo.png") as UIImage?
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        button.frame = CGRect(x: 72, y: 233, width: 230, height: 230)
        //button.center = view.center
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(self.beginRecording(sender:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    //Addding the button to redirect to the maps page
    func addHamburgerIcon(){
        let image = UIImage(named: "Hamburger.png") as UIImage?
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        button.frame = CGRect(x: 18, y: 57, width: 26, height: 18)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(self.navigateMap(sender:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    //Function for sensor button to begin recording
    @objc func beginRecording(sender: UIButton){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        //Getting and presenting recording view controller
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "soundLevel")
        nextViewController.modalPresentationStyle = .fullScreen
        performSegue(withIdentifier: "recordingPipeline", sender: self)
        //self.present(nextViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! RecordViewController
        
        destination.startRecording()
    }
    
    //Function for hamburger button to naviage to map
    @objc func navigateMap(sender: UIButton){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        //Getting and presenting map view controller
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "map")
        self.present(nextViewController, animated: true, completion: nil)
    }
}

/*
 TODO
 - create segue to send recording data from sensor to recording
 - Handle recordings in sensr
 */
