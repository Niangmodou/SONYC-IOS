//
//  MapCardCell.swift
//  SONYC-Project
//
//  Created by Modou Niang on 8/5/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit

class MapCardCell: UITableViewCell {
    
    //Reference to card
    @IBOutlet weak var cardView: UIView!
    
    //Outlets to reference the table view cell
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var apiLabel: UILabel!
    @IBOutlet weak var permitLabel: UILabel!
    
    //Sets up the cell
    func configure(id: String, apiType: String, logo: UIImage, distance: String, address: String, location: String, start: String = "0", end: String = "0", incidentDate: String = "0") {
        
        //Setting labels to update each report
        //Setting labels to update each report
        idLabel.text = id
        logoImage.image = logo
        distanceLabel.text = "\(distance) mi"
        addressLabel.text = address
        locationLabel.text = location
        apiLabel.text = apiType
        
        if incidentDate != "0"{
            permitLabel.text = "Incident Date: \(incidentDate)"
        }else{
            permitLabel.text = "Permit: \(start) to \(end)"
        }
        
        
        //Fitting text to label
        idLabel.sizeToFit()
        apiLabel.sizeToFit()
        distanceLabel.sizeToFit()
        addressLabel.sizeToFit()
        locationLabel.sizeToFit()
        permitLabel.sizeToFit()
        
        //Styling the card
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 5.0
    }
}
