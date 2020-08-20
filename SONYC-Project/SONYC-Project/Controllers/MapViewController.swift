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
import SwiftSVG
import MapKitGoogleStyler
import CoreLocation
import CoreData

class MapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate{
    
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
    
    //Dictionary to store buttons and image name
    var reportButtons: [UIButton:String] = [:]
    
    //9th Avenue and 34th Street latitude and longitude
    let startLatitude = 40.753365
    let startLongitude = -73.996367
    
    //Varaible to store retrieved data from CoreData
    var myData: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteAllData()
        
        //Loading and storing data from CoreData
        getData()
        
        configureTileOverlay()
        populateButtonDictionary()
        styleButtons()

        mapView.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = true
    
        let location = CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
        centerMapOnLocation(location, mapView: mapView)
        
        //Adding 34th Street and 9th Avenue annotation
        let loc = MKPointAnnotation()
        
        loc.coordinate = CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
        loc.title = "Current"
        
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
    
    //Function to retrieve stored mapdata from CoreData
    func getData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "ReportIncident")
        
        do{
            //Loading data from CoreData
            myData = try context.fetch(fetch)
            
            //Plot annotations onto Map
            plotAnnotations(data: myData)
            
            //Sort Data array
            /*
            myData.sort(by: {
                guard let first: Float = ($0.value(forKey: "distance") as! Float) else {}
                guard let second: Float = ($1.value(forKey: "distance") as! Float) else {}
                
                return first < second
                
            })
            */
        }catch let error{
            print("Error: \(error)")
        }
    }
    
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
    
    //Function to center map on New York City
    func centerMapOnLocation(_ location: CLLocationCoordinate2D, mapView: MKMapView) {
        let regionRadius: CLLocationDistance = 5000
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius * 0.0625, longitudinalMeters: regionRadius * 0.0625)
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
    
    //Function to plot annotations onto Map
    func plotAnnotations(data: [NSManagedObject]) {
        
        for each in data {
            let latitude = each.value(forKey: "latitude")
            let longitude = each.value(forKey: "longitude")
            let title = each.value(forKey: "sonycType")
            
            //Creating and plotting the DOB annotation on the map
            plotAnnotation(title: title as! String, latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
        }
    }
    
    //Function to plot annotations on the map
    func plotAnnotation(title: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        let loc = MKPointAnnotation()
        
        loc.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        loc.title = title
        //print(loc.coordinate)
        mapView.addAnnotation(loc)
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
        print("hi")
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        if annotation.title == "311 pin" {
            annotationView?.image = UIImage(named: "Pin_311_non-color.png")
        }else if annotation.title == "DOB" || annotation.title == "AHV" {
            print("hi")
            annotationView?.image = UIImage(named: "Pin_dob_non-color.png")
        }else if annotation.title == "Current"{
            print("hi")
            annotationView?.image = UIImage(named: "Location_Original.png")
        }/*else {
            annotationView?.image = UIImage(named: "Pin_History_non-color.png")
        }
         */
        
        return annotationView
    }
    
    
    //Function to find the distance between two points in miles
    func getDistance(reportLocation: CLLocation) -> String {
        let currLocation = CLLocation(latitude: startLatitude, longitude: startLongitude)
        
        let distanceMeters = currLocation.distance(from: reportLocation)
        
        let distanceMiles = distanceMeters/1609.344
        
        return String(distanceMiles)
    }
    
    //Function to get logo image based on type
    func getImage(reportType: String) -> UIImage {
        var image: UIImage!
        if reportType == "DOB" || reportType == "AHV" {
            //print("hi")
            image = UIImage(named: "dob.png")
        }else if reportType == "311" {
            image = UIImage(named: "Logo_311_non color.png")
        }else if reportType == "DOT" {
            image = UIImage(named: "Logo_Dot_not color.png")
        }
        
        return image
    }
    
    //Function to get api name based on type
    func getType(api: String) -> String {
        var text: String!
        
        if api == "DOB" {
            text = "Building Construction Permit"
        }else if api == "DOT" {
            text = "Street Construction Permit"
        }else if api == "311" {
            text = "311 Noise Report"
        }else if api == "AHV" {
            text = "After Hour Variances"
        }
        
        return text
    }
    
    //Function to drop a pin when a user long presses the map
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer){
        //Gets the location and coordinates of where the map was pressed at
        let touchedAt = recognizer.location(in: self.mapView)
        let _: CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
    }
    
    //Function to retrieve google maps overlay and style the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tileOverlay = overlay as? MKTileOverlay {
                return MKTileOverlayRenderer(tileOverlay: tileOverlay)
            } else {
                return MKOverlayRenderer(overlay: overlay)
       }
    }
}



extension MapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapCardCell", for: indexPath) as! MapCardCell
        
        //Get the contents of the current row
        let currentRow = myData[indexPath.row]
        
        //Parsing information from currentRow
        let api = currentRow.value(forKey: "sonycType") as! String
        let type = getType(api: api)
        
        //Location Data
        let id = currentRow.value(forKey: "unique_id") as! String
        
        var address: String!
        var startDate: String!
        var endDate: String!
        var incidentDate: String!
        
        if api == "DOB" {
            let house = currentRow.value(forKey: "house_num") as! String
            let street = currentRow.value(forKey: "street") as! String
        
            address = "\(house) \(street)"
            
            startDate = (currentRow.value(forKey: "startDate") as! String)
            endDate = (currentRow.value(forKey: "endDate") as! String)
        }else if api == "AHV"  {
            address = (currentRow.value(forKey: "street") as! String)
            startDate = (currentRow.value(forKey: "startDate") as! String)
            endDate = (currentRow.value(forKey: "endDate") as! String)
        }else if api == "311" {
            address = (currentRow.value(forKey: "street") as! String)
            
            incidentDate = (currentRow.value(forKey: "created_date") as! String)
        }
        
        let borough = currentRow.value(forKey: "borough") as! String
        let zipcode = currentRow.value(forKey: "zipcode") as! String
        
        //Getting the logo image based on which type of recording
        let image = getImage(reportType: api)
        
        let distance = currentRow.value(forKey: "distance") as! String
        
        let location = "\(borough),NY \(zipcode)"
   
    
        if api == "311" {
            print("BENCHMARK 3 ---------------------")
            cell.configure(id: id,
                           apiType: type,
                           logo: image,
                           distance: distance,
                           address: address,
                           location: location,
                           incidentDate: incidentDate)
        }else {
            cell.configure(id: id,
                           apiType: type,
                           logo: image,
                           distance: distance,
                           address: address,
                           location: location,
                           start: startDate,
                           end: endDate)
        }
        
        return cell
    }
}

extension MapViewController: UITableViewDelegate{
    //Displaying a tapped location on the map
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Get the contents of the current row
        let currentRow = myData[indexPath.row]
        
        //Extracting lat and lon
        let latitude = currentRow.value(forKey: "latitude") as! CLLocationDegrees
        let longitude = currentRow.value(forKey: "longitude") as! CLLocationDegrees
        print(latitude, longitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
       
        //Focusing map on that location
        centerMapOnLocation(location, mapView: mapView)

    }
    
}
