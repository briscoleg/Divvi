//
//  ExampleViewController.swift
//  Balance
//
//  Created by Bo on 9/10/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "chartSliceSelected"), object: nil)

        }
        
        //MARK: -  Methods
        
        @objc private func refresh() {
            collectionView.reloadData()
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCell", for: indexPath) as! ExampleCell
        
        cell.configureCell(with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExampleHeader", for: indexPath) as! ExampleHeader
        
        header.configureHeader()
        return header
    }
    
}

class ExampleHeader: UICollectionReusableView {
    
    var selectedDate = Date()
    
    func configureHeader() {
        //Configure stuff
    }
    
    @IBAction func addMonthButtonTapped(_ sender: UIButton) {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
        
        //Tell the ExampleCell class to add a month to its selectedDate property.
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
    }
    }
    
    class ExampleCell: UICollectionViewCell {
        
        var selectedDate = Date()
        
        func configureCell(with indexPath: IndexPath) {
            //Configure stuff
        }
        
        
}

