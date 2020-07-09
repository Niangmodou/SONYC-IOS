//
//  MapViewController.swift
//  SONYC-Project
//
//  Created by Modou Niang on 6/28/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit
import MapKit
//import MapKitGoogleStyler
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {
    
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
    
    //Dictionary to store buttons and image name
    var reportButtons: [UIButton:String] = [:]
    
    //Variable to store the json returned from the API
    var jsonResponse: Any!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateButtonDictionary()
        styleButtons()
        getData()
        //configureSearchBar()
        mapView.delegate = self
        //searchBar.delegate = self
        
        /*
        //Setting up Location Manager to get current location
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //Getting MapView to display current location
        mapView.showsUserLocation = true
         */
        let location = CLLocationCoordinate2D(latitude: 40.7127, longitude: -74.0059)
        centerMapOnLocation(location, mapView: mapView)
        
        /*
        let london = MKPointAnnotation()
        london.title = "London"
        london.coordinate = CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)
        mapView.addAnnotation(london)
 */
    }
    func centerMapOnLocation(_ location: CLLocationCoordinate2D, mapView: MKMapView) {
        let regionRadius: CLLocationDistance = 5000
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
//    Function to configure search bar
//    func configureSearchBar(){
//        searchBar.tintColor = UIColor.blue
//    }
    
    //Function to get noise complaint data from the 311 API
    func getData(){
        print(1)
        let url = URL(string:"https://data.cityofnewyork.us/resource/p5f6-bkga.json")
        let task = URLSession.shared.dataTask(with: url!){ (data,response,error) in
            //Making a call to the API and retrieving the data response
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            //Retrieving the json data from the data response returned from the server
            do{
                self.jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                self.populateMap(jsonResponse: self.jsonResponse)
            }catch let parsingError{
                print("Error:",parsingError)
            }
        }
        task.resume()
    }
    
    //Function to plot the noise complaint locations received from the 311 API
    func populateMap(jsonResponse: Any){
        print(2)
        for item in jsonResponse as! [Dictionary<String, AnyObject>] {
            if let lon = (item["longitude"] as? NSString)?.doubleValue {
                if let lat = (item["latitude"] as? NSString)?.doubleValue {
                   let location = MKPointAnnotation()
                   //location.title = "London"
                   location.coordinate = CLLocationCoordinate2D(latitude: lat , longitude: lon)
                   mapView.addAnnotation(location)
                }else{
                    print("error")
                }
            }
            /*
            let lon = item["longitude"]?.doubleValue
            let lat = item["latitude"]?.doubleValue
            print(Double(lat),Double(lon))
 */
            let location = MKPointAnnotation()
            //location.title = "London"
            //location.coordinate = CLLocationCoordinate2D(latitude: lat ?? , longitude: lon)
            //mapView.addAnnotation(location)
 
        }
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
            //button.backgroundColor = UIColor.white
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.cornerRadius = 13
            button.layer.borderWidth = 1
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tileOverlay = overlay as? MKTileOverlay {
                return MKTileOverlayRenderer(tileOverlay: tileOverlay)
            } else {
                return MKOverlayRenderer(overlay: overlay)
            }
    }
 */
}
