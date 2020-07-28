//
//  BudgetCategoryCell.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class BudgetCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressRingView: UIView!
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var amountBudgetedLabel: UILabel!
    
    lazy var ringShapeLayer = CAShapeLayer()
    lazy var borderShapeLayer = CAShapeLayer()
    
    
    //MARK: - Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateBorderLayer()
        setupProgressRing()
        
    }
    
    
    //MARK: - Init
     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         
         setupBorderLayer()

     }
    
    //MARK: - Methods
    private func setupBorderLayer() {
        borderShapeLayer.strokeColor = UIColor.black.cgColor
        borderShapeLayer.lineWidth = 2
        borderShapeLayer.fillColor = nil
        borderShapeLayer.lineDashPattern = [10, 10]
        layer.addSublayer(borderShapeLayer)
    }
    
    private func updateBorderLayer() {
        borderShapeLayer.frame = bounds
        borderShapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 6).cgPath
    }
    
    private func setupProgressRing() {
        
        let center = progressRingView.center
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 40, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi + CGFloat.pi / 2, clockwise: true)
        
        let trackLayer = CAShapeLayer()
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 15
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        
        progressRingView.layer.addSublayer(trackLayer)
        
        ringShapeLayer.path = circularPath.cgPath
        ringShapeLayer.strokeColor = UIColor.red.cgColor
        ringShapeLayer.lineWidth = 15
        ringShapeLayer.fillColor = UIColor.clear.cgColor
        ringShapeLayer.lineCap = .round
//        ringShapeLayer.strokeEnd = 0.75
        progressRingView.layer.addSublayer(ringShapeLayer)
        
        progressRingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))

    }
    
    @objc private func handleTap() {
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 0.75
        
        basicAnimation.duration = 0.75
        
        basicAnimation.fillMode = .forwards
        
        basicAnimation.isRemovedOnCompletion = false
        
        ringShapeLayer.add(basicAnimation, forKey: "urSoBasic")
        
    }
    
    
    
    
    
    
}
