////
////  PlanningVC.swift
////  Balance
////
////  Created by Bo on 9/28/20.
////  Copyright © 2020 Bo. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//
//class PlanningVC: UIViewController {
//    
//    @IBOutlet weak var collectionView: UICollectionView!
//    
//    let realm = try! Realm()
//    
//    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
//    
//    let cellID = "Planning Cell ID"
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        
////        collectionView.register(PlanningCell.self, forCellWithReuseIdentifier: cellID)
//        collectionView.register(PlanningCell.self, forCellWithReuseIdentifier: cellID)
//        
//        configureCollectionView()
//
//    }
//    
//    fileprivate func configureCollectionView() {
//        let layout = UICollectionViewFlowLayout()
//                
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 25, bottom: 25, right: 25)
//        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/1.1, height: 100)
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 12
//        layout.headerReferenceSize = CGSize(width: 0, height: 425)
//        
//        collectionView.collectionViewLayout = layout
//    }
//
//}
//
//extension PlanningVC: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return categories.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PlanningCell
//        cell.progressView.progress = 0.75
//        return cell
//    }
//    
//    
//}
