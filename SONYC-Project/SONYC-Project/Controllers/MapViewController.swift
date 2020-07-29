//
//  MapViewController.swift
//  SONYC-Project
//
//  Created by Modou Niang on 6/28/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit
import MapKit
import SwiftCSV
import MapKitGoogleStyler
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate{
    
    //Variable to reference to the map
    @IBOutlet weak var mapView: MKMapView!
    
    //Variable to track current user location
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    
    //Variable to refernce the search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Variables to reference the buttons
    @IBOutlet weak var buildingButton: UIButton!
    @IBOutlet weak var streetButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    
    //Variable to reference the table view
    @IBOutlet weak var tableView: UITableView!
    
    //Variable to reference the address label within the TableView
    @IBOutlet weak var addressLabel: UILabel!
    
    //Varaible to reference the distance for each location within the TableView
    @IBOutlet weak var distance: UILabel!
    
    //Dictionary to store buttons and image name
    var reportButtons: [UIButton:String] = [:]
    
    //Variables to store the json returned from the APIs
    var jsonResponse311: Any!
    var jsonResponseDOB: Any!
    var jsonResponseStreet: Any!
    
    //9th Avenue and 34th Street latitude and longitude
    let startLatitude = 40.753365
    let startLongitude = -73.996367
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateButtonDictionary()
        styleButtons()
        //getDOBPermitData()
        //get311Data()
        //print(self.jsonResponseDOB as Any)
        //configureSearchBar()
        getAHVData()
        mapView.delegate = self
        configureTileOverlay()
    
        let location = CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
        centerMapOnLocation(location, mapView: mapView)
        
        //Adding 34th Street and 9th Avenue annotation
        let loc = MKPointAnnotation()
        
        loc.coordinate = CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
        loc.title = title
        
        mapView.addAnnotation(loc)
        
        //Adding Gesture Recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.5 // in seconds
        //add gesture recognition
        mapView.addGestureRecognizer(longPress)
    }
    
    private func configureTileOverlay() {
        // We first need to have the path of the overlay configuration JSON
        guard let overlayFileURLString = Bundle.main.path(forResource: "overlay", ofType: "json") else {
                return
        }
        let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
        
        // After that, you can create the tile overlay using MapKitGoogleStyler
        guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else {
            return
        }
        
        // And finally add it to your MKMapView
        mapView.addOverlay(tileOverlay)
    }
    
    //Function to combine data returned from the APIs to sort by distance from the current location
    func getAHVData(){
        let url = URL(string: "https://raw.githubusercontent.com/NYCDOB/ActiveAHVs/gh-pages/data/activeAHVs.csv")

        //let csv: 
        
    }
    
    
    
    //Function to center map on New York City
    func centerMapOnLocation(_ location: CLLocationCoordinate2D, mapView: MKMapView) {
        let regionRadius: CLLocationDistance = 5000
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius * 1.00, longitudinalMeters: regionRadius * 1.00)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Function to get and display the user's current location
    func getUserCurrentLocation(){
        //Setting up Location Manager to get current location
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        
        //Updaye locationManager to get user's current location
        locationManager.startUpdatingLocation()
        
        //Getting MapView to display current location
        mapView.showsUserLocation = true
        
    }
    
    //Function to get after hours variances csv data
    //func
    
    //Function to geocode address to a latitude and longitude
    func getCoordFromAddress() {
        
    }
    
//REFACTOR CODE TO MAKE CODE DRY CODENSE THESE FUNCTIONS -----------------------------------------------------
    //Function to fetch and query data using Socrata
    func getDataSocrata(){
        //let client = SODAClient(domain: "https://data.cityofnewyork.us/resource/tqtj-sjs8.json", token: "uoF7GWNArky47qzdc4kD2S4RV")
    }
    
    //Function to get noise complaint data from the 311 API
    func get311Data(){
        //print(1)
        //var jsonResponse: Any!
        let url = URL(string:"https://data.cityofnewyork.us/resource/ipu4-2q9a.json?bourough=MANHATTAN&zip_code=10001")
        let task = URLSession.shared.dataTask(with: url!){ (data,response,error) in
            //Making a call to the API and retrieving the data response
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            //Retrieving the json data from the data response returned from the server
            do{
                self.jsonResponse311 = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [Dictionary<String, AnyObject>]
                
                self.populate311Map(jsonResponse: self.jsonResponse311 as Any)
                //print(self.jsonResponse311 as Any)
                
        
            }catch let parsingError{
                print("Error:", parsingError)
            }
        }
        //print(self.jsonResponse311 as Any)
        task.resume()
        //return jsonResponse as Any
    }
    
    
    
    
    //Function to get building data from the DOB permit API
    func getDOBPermitData(){
        //print(2)
        //var jsonResponse: Any!
        
        let url = URL(string: "https://data.cityofnewyork.us/resource/ipu4-2q9a.json?borough=MANHATTAN")
        var jsonResult: [Dictionary<String, AnyObject>]!
        let task = URLSession.shared.dataTask(with: url!){ (data,response,error) in
            //Making a call to the API and retrieving the data response
            guard let dataResponse = data, error == nil else{
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do{
                jsonResult = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [Dictionary<String, AnyObject>]
                self.jsonResponseDOB = jsonResult
                self.populateDOBMap(jsonResponse: jsonResult as Any)
                //print("hi")
                /*
                if let jsonResult = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.jsonResponseDOB = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                        self.populateDOBMap(jsonResponse: self.jsonResponseDOB as Any)
                    }
                }
                */
                //print(self.jsonResponseDOB)
                
                
            }catch let parsingError{
                print("Error:", parsingError)
            }
            
        }
        task.resume()
        //print(jsonResponseDOB)
        //return jsonResult as Any
    }
//Radius - 500m
//34th - 9th
/*
    //Function to get street construction permit data from the API
    func getStreetPermitData(){
        let url = URL(string: "https://data.cityofnewyork.us/resource/tqtj-sjs8.json")
        let task = URLSession.shared.dataTask(with: url!){ (data,response,error) in
            //Making a call to the API and retrieving the data response
            guard let dataResponse = data, error == nil else{
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do{
                self.jsonResponseStreet = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                print(self.jsonResponseStreet)
                self.populatePermitMap(jsonResponse: self.jsonResponseStreet as Any)
            }catch let parsingError{
                print("Error:", parsingError)
            }
        }
    }
     */
    
    
    //Function to plot the noise complaint locations received from the 311 API
    func populate311Map(jsonResponse: Any){
        print(1)
        print(self.jsonResponse311 as Any)
        for item in jsonResponse as! [Dictionary<String, AnyObject>] {
            if let longitude = (item["longitude"] as? NSString)?.doubleValue {
                if let latitude = (item["latitude"] as? NSString)?.doubleValue {
                    
                    let title = "311 pin"
                    
                    //Creating and plotting the 311 annotation on the map
                    plotAnnotation(title: title, latitude: latitude, longitude: longitude)
                }else{
                    print("error")
                }
            }
        }
        
        
    }
    
    //Function to plot the buildings under construction obtained from the DOB permit data API
    func populateDOBMap(jsonResponse: Any){
        //print(2)
        self.jsonResponseDOB = jsonResponse as! [Dictionary<String, AnyObject>]
        for item in jsonResponse as! [Dictionary<String, AnyObject>] {
            //print(item)
            if let longitude = (item["gis_longitude"] as? NSString)?.doubleValue {
                if let latitude = (item["gis_latitude"] as? NSString)?.doubleValue {
                    //print(latitude,longitude)
                    let title = "DOB pin"
                    
                    //Creating and plotting the DOB annotation on the map
                    plotAnnotation(title: title, latitude: latitude, longitude: longitude)
                }else{
                    print("error")
                }
            }
        }
    }
    
    /*
    //Function to plot the street construction permits obtained from the API
    func populatePermitMap(jsonResponse: Any){
        print(3)
        for item in jsonResponse as! [Dictionary<String, AnyObject>] {
            print(item)
            if let longitude = (item["longitude"] as? NSString)?.doubleValue {
                if let latitude = (item["latitude"] as? NSString)?.doubleValue {
                    print(latitude,longitude)
                    let title = "Permit pin"
                    
                    //Creating and plotting the permit annontation on the map
                    plotAnnotation(title: title, latitude: latitude, longitude: longitude)
                }
            }
        }
    }
     */
    
    //Function to plot annotations on the map
    func plotAnnotation(title: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let location = MKPointAnnotation()
        
        location.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        location.title = title
        
        mapView.addAnnotation(location)
    }
    
    //Function to populate dictionary button
    func populateButtonDictionary(){
        reportButtons = [
            buildingButton: "Logo_Dob_non color",
            streetButton: "Logo_Dot_not color",
            reportButton: "Logo_311_non color",
            historyButton: "Pin_History_non-color"
        ]
    }
    
    //Function to style buttons
    func styleButtons(){
        //Styling the map buttons
        for (button,path) in reportButtons{
            let icon = UIImage(named: path)
            button.setImage(icon, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
            button.tintColor = UIColor.black
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.cornerRadius = 13
            button.layer.borderWidth = 1
        }
    }
    
    //Fucntion to add image to an annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        if annotation.title == "311 pin" {
            annotationView?.image = UIImage(named: "Pin_311_non-color.png")
        }else if annotation.title == "DOB pin" {
            annotationView?.image = UIImage(named: "Pin_dob_non-color.png")
        }else {
            annotationView?.image = UIImage(named: "Pin_History_non-color.png")
        }
        
        
        return annotationView
    }
    
    //Function to drop a pin when a user long presses the map
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer){
        //Gets the location and coordinates of where the map was pressed at
        let touchedAt = recognizer.location(in: self.mapView)
        let _: CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tileOverlay = overlay as? MKTileOverlay {
                return MKTileOverlayRenderer(tileOverlay: tileOverlay)
            } else {
                return MKOverlayRenderer(overlay: overlay)
            }
    }
    
    /*
    //Functions to style MapKit
    private func configureOverlay(){
        guard let overlayFileURLString = Bundle.main.path(forResource: "overlay", ofType: "string") else {
            return
        }
        
        let overlayFileUrl = URL(fileURLWithPath: overlayFileURLString)
        
        //Creating tile overlay using MapKitGoogleStyler
        guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileUrl) else{
            return
        }
        
        mapView.add(tileOverlay)
    }
    */
}

/*
extension MapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        <#code#>
    }
}

*/
