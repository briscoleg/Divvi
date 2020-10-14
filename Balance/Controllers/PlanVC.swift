//
//  Budget2VC.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class PlanVC: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    
    let realm = try! Realm()
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    //MARK: - ViewDidLoad/ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        

 
        setCollectionViewLayout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "planningAmountAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionCleared"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "chartSliceSelected"), object: nil)

    }
    
    //MARK: -  Methods
    
    @objc private func refresh() {
        collectionView.reloadData()
    }

    private func setCollectionViewLayout() {
        
        let layout = UICollectionViewFlowLayout()
                
        layout.sectionInset = UIEdgeInsets(top: 0, left: 25, bottom: 25, right: 25)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/1.1, height: 100)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 12
        layout.headerReferenceSize = CGSize(width: 0, height: 150)
        
        collectionView.collectionViewLayout = layout
        
    }
    
    //MARK: - IBActions
    
    
    
//    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
//
//        var textField = UITextField()
//
//        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
//
//        let action = UIAlertAction(title: "Add", style: .default) { (action) in
//
//            try! self.realm.write {
//
//                let newCategory = Category()
//                newCategory.categoryName = textField.text!
//                newCategory.categoryColor = 0xd8d8d8
//
//                self.realm.add(newCategory)
//
//            }
//
//            self.categories = self.realm.objects(Category.self)
//
//
//            self.collectionView.reloadData()
//
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
//
//
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
//            self.dismiss(animated: true, completion: nil)
//        }
//
//        alert.addTextField { (field) in
//
//            textField = field
//            textField.placeholder = "Enter a category name"
//            textField.autocapitalizationType = .words
//
//
//        }
//        alert.addAction(action)
//        alert.addAction(cancelAction)
//
//        self.present(alert, animated: true, completion: nil)
//    }
//
    
}

//MARK: - CollectionView Delegate
extension PlanVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(identifier: "SubVC") as? SubVC {
            
            vc.categorySelected = categories[indexPath.item]
//            vc.subCategories = categories[indexPath.item].subCategories
            vc.viewTitle = categories[indexPath.item].categoryName
            show(vc, sender: self)
            
        }
    }
    
}

//MARK: - CollectionView DataSource
extension PlanVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categories.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Budget3Cell.identifier, for: indexPath) as! Budget3Cell
        
        cell.configure(with: indexPath)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {

        case UICollectionView.elementKindSectionHeader:

            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? BudgetHeader else { fatalError("Invalid view type") }
            
//            headerView.configureHeader()
            
            return headerView
            
        default:

            assert(false, "Invalid element type")
        }
        
    }
    
}

