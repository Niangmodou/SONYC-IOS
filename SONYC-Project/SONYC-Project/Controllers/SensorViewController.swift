//
//  SensorViewController.swift
//  SONYC-Project
//
//  Created by Modou Niang on 7/2/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit
import CoreData
import SwiftCSV

class SensorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
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
        UIView.setAnimationsEnabled(false)
        performSegue(withIdentifier: "recordingPipeline", sender: self)
        UIView.setAnimationsEnabled(true)
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
        self.present(nextViewController, animated: false, completion: nil)
    }
    
    //Functions to fetch data from the APIS and save them to CoreData
    func loadData(){
        print("hi")
        getDOBPermitData()
    }
    
    func getDOBPermitData(){
        let url = URL(string: "https://data.cityofnewyork.us/resource/ipu4-2q9a.json?zip_code=10001")
    
        let task = URLSession.shared.dataTask(with: url!){ (data,response,error) in
            //Making a call to the API and retrieving the data response
            guard let dataResponse = data, error == nil else{
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do{
                let jsonResult = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [Dictionary<String, AnyObject>]
                
                //print(jsonResult as Any)
                self.saveToCoreData(jsonResponse: jsonResult as Any)
                
            }catch let parsingError{
                print("Error:", parsingError)
            }
            
        }
        task.resume()
    }
    
    func getAFHVData(){
        let url = URL(string: "https://raw.githubusercontent.com/NYCDOB/ActiveAHVs/gh-pages/data/activeAHVs.csv")
        
        do{
            let csv: CSV = try CSV(url: URL(resolvingAliasFileAt: url!))
        }catch{
            
        }
        
    }
    
    func saveToCoreData(jsonResponse: Any){
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "ReportIncident", in: context)
            
            for item in jsonResponse as! [Dictionary<String, AnyObject>] {
                //print(item)
                if let longitude = (item["gis_longitude"] as? NSString)?.doubleValue {
                    if let latitude = (item["gis_latitude"] as? NSString)?.doubleValue {
                        
                        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                        print(latitude,longitude)
                        newEntity.setValue(latitude, forKey: "latitude")
                        newEntity.setValue(longitude, forKey: "longitude")
                        newEntity.setValue("DOB", forKey: "sonycType")
                    }else{
                        print("error")
                    }
                }
            }
        }
        
    }
}

