//
//  RecordDescriptionViewController.swift
//  SONYC-Project
//
//  Created by Modou Niang on 7/7/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit

class RecordDescriptionViewController: UIViewController {
    
    //Variables to reference the buttons
    @IBOutlet weak var locHomeBtn: UIButton!
    @IBOutlet weak var locElsewhereBtn: UIButton!
    @IBOutlet weak var actionSleepingBtn: UIButton!
    @IBOutlet weak var actionWorkingBtn: UIButton!
    @IBOutlet weak var actionRestingBtn: UIButton!
    @IBOutlet weak var actionWalkingBtn: UIButton!
    @IBOutlet weak var actionParentingBtn: UIButton!
    @IBOutlet weak var actionOthersButton: UIButton!
    
    
    @IBOutlet weak var feelingSmileybtn: UIButton!
    @IBOutlet weak var feelingMehFace: UIButton!
    @IBOutlet weak var feelingSadFace: UIButton!
    @IBOutlet weak var feelingAngryFace: UIButton!
    @IBOutlet weak var feelingFrustratedFace: UIButton!
    @IBOutlet weak var feelingDizzyFace: UIButton!
    
    //Variable to reference the identify a noise source button
    @IBOutlet weak var identifyNoiseBtn: UIButton!
    //Array to store the names of the icons
    var iconNames: [String] = []
    
    //Array to store the names of the button titles
    var buttonNames: [String] = []
    
    //Array to store the names of the IBOutlet
    var outletNames: [UIButton] = []
    
    //Dictionary to store smiley faces and names of file
    var smileyFaces: [UIButton:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleIdentifyNoiseBtn()
        populateArrays()
        styleButtons(iconNames: iconNames, buttonNames: buttonNames)
        
        // Do any additional setup after loading the view.
    }
    
    //Function to populate the iconNames array, buttonNames array, and the IBOutlet arrays
    func populateArrays(){
        buttonNames = ["Home","Elsewhere","Sleeping","Working","Resting","Walking","Parenting" ]
        iconNames = ["Icon_Indoor","Icon_Outdoor","Icon_Sleeping man","Icon_Working man", "Icon_Resting man", "Icon_Walking", "Icon_Parenting"]
        
        outletNames = [locHomeBtn,locElsewhereBtn,actionSleepingBtn,actionWorkingBtn,actionRestingBtn,actionWalkingBtn,actionParentingBtn]
        
        smileyFaces = [
            feelingSmileybtn: "Icon_Happy Face",
            feelingMehFace: "Icon_meh face",
            feelingSadFace: "Frustrated face",
            feelingAngryFace: "Icon_Angry Face",
            feelingFrustratedFace: "Icon_Annoyed Face",
            feelingDizzyFace: "Icon_Dizzy Face"
        
        ]
    }
    
    //Function to style the individual buttons on the screen
    func styleButtons(iconNames: [String], buttonNames: [String]){
        //Styling the action icon buttons
        for i in 0..<iconNames.count {
            outletNames[i].setTitle(buttonNames[i], for: .normal)
            let icon = UIImage(named: iconNames[i])
            outletNames[i].setImage(icon, for: .normal)
            outletNames[i].imageView?.contentMode = .scaleAspectFit
            outletNames[i].imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
            //outletNames[i].sizeToFit()
            outletNames[i].tintColor = UIColor.black
            outletNames[i].layer.borderColor = UIColor.black.cgColor
            outletNames[i].layer.cornerRadius = 5
            outletNames[i].layer.borderWidth = 1
        }
        //Setting Other button
        actionOthersButton.setTitle("Other", for: .normal)
        actionOthersButton.tintColor = UIColor.black
        actionOthersButton.layer.borderColor = UIColor.black.cgColor
        actionOthersButton.layer.cornerRadius = 5
        actionOthersButton.layer.borderWidth = 1
        //actionOthersButton.sizeToFit()
        //actionOthersButton.sizeToFit()
        
        //Styling Smiley Faces
        var xStart = 30
        for (button, path) in smileyFaces{
            let image = UIImage(named: "\(path).png") as UIImage?
            button.frame = CGRect(x: xStart ,y: 644, width: 40, height: 40)
            button.setImage(image, for: .normal)
            button.tintColor = UIColor.gray
            self.view.addSubview(button)
            
            xStart += 64
        }
    
    }
  
    //Function to style the identify a noise source button
    func styleIdentifyNoiseBtn(){
        //Styling button
        identifyNoiseBtn.backgroundColor = getColorByHex(rgbHexValue:0x32659F)
        identifyNoiseBtn.layer.cornerRadius = 25.0
        identifyNoiseBtn.tintColor = UIColor.white
        
        //Adding a target for when the button is clicked
        //identifyNoiseBtn.addTarget(self, action: #selector(self.presentRecordOptions(sender:)), for: .touchUpInside)
    }
    
    //Function to get a color by their hex color
    func getColorByHex(rgbHexValue:UInt32, alpha:Double = 1.0) -> UIColor {
        let red = Double((rgbHexValue & 0xFF0000) >> 16) / 256.0
        let green = Double((rgbHexValue & 0xFF00) >> 8) / 256.0
        let blue = Double((rgbHexValue & 0xFF)) / 256.0

        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

