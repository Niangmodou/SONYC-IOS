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
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    //Sets up the cell
    func configure(logo: UIImage, distance: String, address: String, location: String) {
        
        //Setting labels to update each report
        logoImage.image = logo
        distanceLabel.text = "\(distance) mi"
        addressLabel.text = address
        locationLabel.text = "\(location), NY"
        
        //Fitting text to label
        distanceLabel.sizeToFit()
        addressLabel.sizeToFit()
        locationLabel.sizeToFit()
        
        //Styling the card
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 5.0
    }
}
