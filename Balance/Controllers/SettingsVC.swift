//
//  SettingsVC.swift
//  Balance
//
//  Created by Bo LeGrand on 10/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    static let identifier = "SettingsVC"
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    private var settingsItems = [SettingsItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegates()
        configureSettingsItems()
        configureCollectionViewLayout()

    }
    
    private func setDelegates() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configureCollectionViewLayout() {
        
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        
    }
    
    private func configureSettingsItems() {
        
        let names = ["About", "Calendar Scroll Direction", "Reset Starting Balance"]
        
        for name in names {
            settingsItems.append(SettingsItem(name: name))
        }
        
    }
    
}

extension SettingsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingsItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCell.identifier, for: indexPath) as? SettingsCell else { return UICollectionViewCell() }
        cell.nameLabel.text = settingsItems[indexPath.item].name
        return cell
    }
}

extension SettingsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
