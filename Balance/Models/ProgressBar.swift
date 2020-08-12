////
////  ProgressBar.swift
////  Balance
////
////  Created by Bo on 7/29/20.
////  Copyright © 2020 Bo. All rights reserved.
////
//
//import UIKit
//
//class ProgressBar: UIView {
//    
//    public var backgroundCircleColor: CGColor = UIColor(rgb: Constants.lightlightgrey).cgColor
//    public var foregroundCircleColor: CGColor = UIColor.red.cgColor
//    
//    private var backgroundLayer: CAShapeLayer!
//    private var foregroundLayer: CAShapeLayer!
//    
//    override func draw(_ rect: CGRect) {
//        
//        let width = rect.width
//        let height = rect.height
//        let lineWidth = 0.1 * min(width, height)
//        
//        backgroundLayer = createCircularLayer(rect: rect, strokeColor: backgroundCircleColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
//        foregroundLayer = createCircularLayer(rect: rect, strokeColor: foregroundCircleColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
//        
//        foregroundLayer.strokeEnd = 0.6
//    
//        layer.addSublayer(backgroundLayer)
//        layer.addSublayer(foregroundLayer)
//        
//    }
//    
//    private func createCircularLayer(rect: CGRect, strokeColor: CGColor, fillColor: CGColor, lineWidth: CGFloat) -> CAShapeLayer {
//        
//        let width = rect.width
//        let height = rect.height
//        let lineWidth = 0.15 * min(width, height)
//        let center = CGPoint(x: width / 2, y: height / 2)
//        let radius = (min(width, height) / 2.75)
//        let startAngle = -CGFloat.pi / 2
//        let endAngle = startAngle + CGFloat.pi * 2
//        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//        let shapeLayer = CAShapeLayer()
//        
//        shapeLayer.path = circularPath.cgPath
//        shapeLayer.strokeColor = strokeColor
//        shapeLayer.fillColor = fillColor
//        shapeLayer.lineWidth = lineWidth
//        shapeLayer.lineCap = .round
//      
//        return shapeLayer
//        
//    }
//    
//}
