//
//  BudgetVC.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class BudgetVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    let category = Category()
    let shapeLayer = CAShapeLayer()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    //MARK: - Methods
//    func setProgress(progress: CGFloat){
//        cell.ringShapeLayer.strokeEnd = progress
//    }
    
    @objc private func handleTap() {
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 0.75
        
        basicAnimation.duration = 0.75
        
        basicAnimation.fillMode = .forwards
        
        basicAnimation.isRemovedOnCompletion = true
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
        
    }
    
}

extension BudgetVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension BudgetVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.mainCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BudgetCell", for: indexPath) as! BudgetCell
        
        cell.nameLabel.text = category.mainCategories[indexPath.item]
        
        handleTap()
        
        return cell
    }
    
    
}
