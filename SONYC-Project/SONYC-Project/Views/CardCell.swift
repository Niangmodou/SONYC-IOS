//
//  CardCell.swift
//  SONYC-Project
//
//  Created by Modou Niang on 6/28/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {
    //UILabels to connect to storyboard
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var recordingNumLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    func configure(recordNum: Int, minDecibel: Int, avgDecibel: Int, maxDecibel: Int){
        //Setting Labels to update recording information
        recordingNumLabel.text = "Recording #\(recordNum)"
        minLabel.text = "Min: \(minDecibel)dB"
        avgLabel.text = "Avg: \(avgDecibel)dB"
        maxLabel.text = "Max: \(maxDecibel)dB"
        
        //Fiting the text to the labels
        recordingNumLabel.sizeToFit()
        minLabel.sizeToFit()
        avgLabel.sizeToFit()
        maxLabel.sizeToFit()
        
        //Styling the card
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 5.0
    }
}
