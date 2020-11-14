//
//  PlanVC.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

class PlanVC: UIViewController {
    
    static let identifier = "PlanVC"
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    
    private let realm = try! Realm()
    private lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    private lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self) }()
    
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
        configureObservers()
        
    }
    
    //MARK: -  Methods
    @objc private func refresh() {
        collectionView.reloadData()
    }

    private func setCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "planningAmountAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionCleared"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "chartSliceSelected"), object: nil)
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
        if let vc = storyboard?.instantiateViewController(identifier: SubVC.identifier) as? SubVC {
            vc.categorySelected = categories[indexPath.item]
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
        
        let plannedTotal: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory == %@", categories[indexPath.item])).filter(SelectedMonth.shared.selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))
                
        let spentTotal: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory == %@ && isCleared == true", categories[indexPath.row])).filter(SelectedMonth.shared.selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))
        
        let plannedToSpentRatio = spentTotal / plannedTotal
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlanningCell.identifier, for: indexPath) as? PlanningCell else { return UICollectionViewCell() }

        cell.configure(
            name: categories[indexPath.item].categoryName,
            image: UIImage(named: categories[indexPath.item].categoryName)!,
            color: UIColor(rgb: categories[indexPath.item].categoryColor)
        )
        
        cell.amountBudgetedLabel.text = "\(plannedTotal.toCurrency())\n Planned"

        cell.percentLabel.text = plannedToSpentRatio.toPercent()
        
        if categories[indexPath.item].categoryName == "Income" {
            cell.amountSpentLabel.text = "\(spentTotal.toCurrency()) \nEarned"
        } else {
            cell.amountSpentLabel.text = "\(spentTotal.toCurrency()) \nSpent"
        }
        
        if plannedTotal == 0 {
            cell.progressBar.progress = 0
        } else {
            cell.progressBar.progress = CGFloat(plannedToSpentRatio)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BudgetHeader.identifier, for: indexPath) as? BudgetHeader else { fatalError("Invalid view type") }
            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }
}

extension PlanVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/1.1, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 25, bottom: 25, right: 25)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 125)
    }

}
