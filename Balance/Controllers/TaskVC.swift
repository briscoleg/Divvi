//
//  TaskVC.swift
//  Balance
//
//  Created by Bo on 7/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class TaskVC: UIViewController{
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var clearSegmentedControl: UISegmentedControl!
    
    //MARK: - Properties
    let realm = try! Realm()
    lazy var allTransactions: Results<Transaction> = { realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: false).sorted(byKeyPath: "isCleared", ascending: false) }()
    lazy var unclearedTransactionsToDate: Results<Transaction> = { self.realm.objects(Transaction.self).filter("transactionDate <= %@", Date().advanced(by: 1000)).filter("isCleared == %@", false).sorted(byKeyPath: "transactionDate", ascending: true) }()
    
    
    var taskView = true
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateInstructionsLabel()
        configureCollectionViewLayout()
        configureObservers()
        
    }
    
    //MARK: - Methods
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
    }
    
    @objc func refresh() {
        collectionView.reloadData()
        updateInstructionsLabel()
        
    }
    
    private func configureCollectionViewLayout() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 75)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(width: 0, height: 25)
        
        collectionView.collectionViewLayout = layout
        
    }
    
    private func updateInstructionsLabel() {
        if unclearedTransactionsToDate.count > 0 {
            instructionsLabel.text = "Swipe right to clear transactions\nthat have posted to your account.\nSwipe left to delete."
            tabBarController!.tabBar.items![1].badgeValue = "1"
        } else {
            instructionsLabel.text = "All clear!"
            tabBarController!.tabBar.items![1].badgeValue = nil
        }
    }
    
    private func presentDetailVC(_ indexPath: IndexPath) {
        var transactionToPresent = Transaction()
        
        if taskView {
            transactionToPresent = unclearedTransactionsToDate[indexPath.item]
        } else {
            transactionToPresent = allTransactions[indexPath.item]
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        
        vc.transaction = transactionToPresent
        
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: - IBActions
    @IBAction func unclearedSegmentedControlSwitched(_ sender: UISegmentedControl) {
        
        switch clearSegmentedControl.selectedSegmentIndex {
        case 0:
            taskView = true
            updateInstructionsLabel()
            collectionView.reloadData()
        case 1:
            taskView = false
            instructionsLabel.text = ""
            collectionView.reloadData()
        default:
            break
        }
    }
}

//MARK: - CollectionView Delegate/DataSource
extension TaskVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        presentDetailVC(indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if taskView {
            return unclearedTransactionsToDate.count
        } else {
            return allTransactions.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.reuseIdentifier, for: indexPath) as! TaskCell
        
        //SwipeCell Delegate
        cell.delegate = self
        
        var transactionResults: Results<Transaction>
        
        if taskView {
            transactionResults = unclearedTransactionsToDate
        } else {
            transactionResults = allTransactions
        }
        
        cell.configureCollectionViewCells(indexPath, transactionResults)
        
        let balanceAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", transactionResults[indexPath.item].transactionDate).sum(ofProperty: "transactionAmount")

        cell.balanceLabel.attributedText = balanceAtDate.toAttributedString(size: 9, offset: 6, weight: .regular)
        
//        let balanceAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", transactionResults[indexPath.item].transactionDate).sum(ofProperty: "transactionAmount")
//
//        cell.balanceLabel.attributedText = transactionResults[indexPath.item].transactionAmount.toAttributedString(size: 9, offset: 6, weight: .regular)
        
        if transactionResults[indexPath.item].isCleared == false && !taskView {
            cell.amountLabel.textColor = .lightGray
            cell.subcategoryLabel.textColor = .lightGray
            cell.dateLabel.textColor = .lightGray
            cell.balanceLabel.textColor = .lightGray
        } else {
            cell.subcategoryLabel.textColor = .black
            cell.dateLabel.textColor = .black
            cell.balanceLabel.textColor = .black
            cell.circleView.backgroundColor = UIColor(rgb: transactionResults[indexPath.item].transactionCategory!.categoryColor)
        }
        
        return cell
    }
}


//MARK: - SwipeCell Delegate
extension TaskVC: SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        if orientation == .right {
            options.expansionStyle = .destructiveAfterFill
            options.transitionStyle = .drag
        } else {
            options.expansionStyle = .destructiveAfterFill
            options.transitionStyle = .drag
        }
        
        return options
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        
        if orientation == .left {
            
            
            let clearAction = SwipeAction(style: .default, title: "Clear") { action, indexPath in
                
                var transactionToEdit = self.allTransactions[indexPath.item]
                
                if self.taskView {
                    transactionToEdit = self.unclearedTransactionsToDate[indexPath.item]
                }
                
                try! self.realm.write {
                    transactionToEdit.isCleared = !transactionToEdit.isCleared
                }
                
                self.updateInstructionsLabel()
                
                action.fulfill(with: .reset)
                
                collectionView.reloadData()
                
                NotificationCenter.default.post(name: NSNotification.Name("transactionCleared"), object: nil)
                
            }
            
            clearAction.image = UIImage(systemName: "checkmark")
            clearAction.backgroundColor = UIColor(rgb: Constants.blue)
            
            return [clearAction]
        } else if orientation == .right {
            
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
                try! self.realm.write {
                    self.realm.delete(self.allTransactions[indexPath.item])
                }
                action.fulfill(with: .delete)
                collectionView.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
            }
            
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = UIColor(rgb: Constants.red)
            
            return [deleteAction]
        } else {
            return nil
        }
        
    }
    
    
}
