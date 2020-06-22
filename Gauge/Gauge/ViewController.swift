//
//  ViewController.swift
//  Gauge
//
//  Created by Modou Niang on 6/22/20.
//  Copyright © 2020 modouniang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let shapeLayer = CAShapeLayer()

    var decibels = 75
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "0dB"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        
        return label
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Creating Gauge to view decibels
        view.addSubview(label)
        label.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        label.center = view.center
        //create track layer
        let trackLayer = CAShapeLayer()
        
        let center = view.center
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = center //change!!!
        view.layer.addSublayer(trackLayer)
        
        //let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -5*CGFloat.pi/4, endAngle: 2*CGFloat.pi, clockwise: true)
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = getColorByHex(rgbHexValue:0x32659F).cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = center
        shapeLayer.strokeEnd = 0
        
        shapeLayer.transform = CATransform3DMakeRotation(-5*CGFloat.pi/4, 0, 0, 1)
        
        view.layer.addSublayer(shapeLayer)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    func getColorByHex(rgbHexValue:UInt32, alpha:Double = 1.0) -> UIColor {
        let red = Double((rgbHexValue & 0xFF0000) >> 16) / 256.0
        let green = Double((rgbHexValue & 0xFF00) >> 8) / 256.0
        let blue = Double((rgbHexValue & 0xFF)) / 256.0

        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }

    
    private func begin() {
        print("Begin")
        shapeLayer.strokeEnd = 0
        
        finish()
    }
    
    private func finish(){
        print("finish")
        DispatchQueue.main.async {
            self.label.text = "75dB"
            self.shapeLayer.strokeEnd = CGFloat(self.getPercent())
        }
        
    }
    
    //Function to find current percentage of circle
    func getPercent() -> Float {
        print(((75/120)*75)/120)
        return ((75/120)*75)/120
    }
    
    fileprivate func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation,forKey: "Stroke")
    }
    
    @objc private func handleTap() {
        print("Attempting to tap")
        
        begin()
        
        //animateCircle()

    }


}

