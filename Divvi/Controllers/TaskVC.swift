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

enum TransactionView {
    case toDo
    case posted
    case future
}

class TaskVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var clearSegmentedControl: UISegmentedControl!
    @IBOutlet weak var clearAllButton: UIButton!
    
    //MARK: - Properties
    let realm = try! Realm()
    lazy var allTransactions: Results<Transaction> = {realm.objects(Transaction.self)}()
    lazy var postedTransactions: Results<Transaction> = { realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: false).filter("isCleared == %@", true) }()
    lazy var unpostedTransactions: Results<Transaction> = { self.realm.objects(Transaction.self).filter("transactionDate <= %@", Date().localDate().removeTime!).filter("isCleared == %@", false).sorted(byKeyPath: "transactionDate", ascending: true) }()
    lazy var futureTransactions: Results<Transaction> = { realm.objects(Transaction.self).filter("transactionDate > %@", Date().localDate().removeTime!).filter("isCleared == %@", false).sorted(byKeyPath: "transactionDate", ascending: true) }()
    lazy var unclearedTransactionsToDate: Results<Transaction> = { allTransactions.filter("transactionDate <= %@", Date()).filter("isCleared == %@", false).sorted(byKeyPath: "transactionDate", ascending: true) }()
    var transactionView = TransactionView.toDo
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        updateInstructionsLabel()
        configureCollectionViewLayout()
        configureObservers()
        
        showBadgeForUnclearedTransactions()
        
        configureUI()
        
    }
    
    //MARK: - Methods
    
    private func configureUI() {
        clearAllButton.setTitleColor(UIColor(rgb: SystemColors.shared.blue), for: .normal)
    }
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
    }
    
    func showBadgeForUnclearedTransactions() {
        
        if unclearedTransactionsToDate.count > 0 {
            tabBarController!.tabBar.items![3].badgeValue = "1"
        } else {
            tabBarController!.tabBar.items![3].badgeValue = nil
        }
        
    }
    
    @objc func refresh() {
        collectionView.reloadData()
        updateInstructionsLabel()
        showBadgeForUnclearedTransactions()
        
    }
    
    private func configureCollectionViewLayout() {
        
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        
    }
    
    private func updateInstructionsLabel() {
        switch transactionView {
        case .toDo:
            if allTransactions.count == 0 {
                instructionsLabel.text = "No transactions yet.\n\nCheck back\nafter adding transactions."
                clearAllButton.isHidden = true
            } else if unpostedTransactions.count > 0 {
                instructionsLabel.text = "Swipe right to clear transactions.\n\nTap to edit."
                tabBarController!.tabBar.items![3].badgeValue = "1"
                clearAllButton.isHidden = false
            } else {
                instructionsLabel.text = "All done!\n\nCheck back later\nor add transactions."
                tabBarController!.tabBar.items![3].badgeValue = nil
                clearAllButton.isHidden = true
            }
        case .posted:
            instructionsLabel.text = ""
            clearAllButton.isHidden = true
        case .future:
            instructionsLabel.text = ""
            clearAllButton.isHidden = true
            
        }
    }
    
    private func presentDetailVC(at indexPath: IndexPath) {
        
//        var transactionToPresent = Transaction()
//
//        switch transactionView {
//        case .toDo:
//            transactionToPresent = unpostedTransactions[indexPath.item]
//        case .posted:
//            transactionToPresent = postedTransactions[indexPath.item]
//        case .future:
//            transactionToPresent = futureTransactions[indexPath.item]
//
//            if let vc = storyboard?.instantiateViewController(withIdentifier: DetailVC.identifier) as? DetailVC {
//
//                vc.transaction = transactionToPresent
//                present(vc, animated: true, completion: nil)
//
//            }
//        }
    }
    
    
    //MARK: - IBActions
    
    @IBAction func clearAllButtonPressed(_ sender: UIButton) {
        
        
        
        do {
            try realm.write {
                for transaction in unpostedTransactions {
                    transaction.isCleared = true
                }
            }
        } catch {
            print("Error clearing transactions \(error)")
        }
        
        updateInstructionsLabel()
        collectionView.reloadData()
    }
    @IBAction func unclearedSegmentedControlSwitched(_ sender: UISegmentedControl) {
        
        switch clearSegmentedControl.selectedSegmentIndex {
        case 0:
            transactionView = .toDo
            updateInstructionsLabel()
            collectionView.reloadData()
        case 1:
            transactionView = .posted
            updateInstructionsLabel()
            collectionView.reloadData()
        case 2:
            transactionView = .future
            updateInstructionsLabel()
            collectionView.reloadData()
            
        default:
            break
        }
    }
}

//MARK: - CollectionView Delegate/DataSource
extension TaskVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        switch transactionView {
        case .toDo:
            if let vc = storyboard?.instantiateViewController(withIdentifier: DetailVC.identifier) as? DetailVC {
                vc.transaction = unpostedTransactions[indexPath.item]
                present(vc, animated: true, completion: nil)
            }
        case .posted:
            if let vc = storyboard?.instantiateViewController(withIdentifier: DetailVC.identifier) as? DetailVC {
                vc.transaction = postedTransactions[indexPath.item]
                present(vc, animated: true, completion: nil)
            }
        case .future:
            if let vc = storyboard?.instantiateViewController(withIdentifier: DetailVC.identifier) as? DetailVC {
                vc.transaction = futureTransactions[indexPath.item]
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch transactionView {
        case .toDo:
            return unpostedTransactions.count
        case .posted:
            return postedTransactions.count
        case .future:
            return futureTransactions.count
        }
    }
    
    private func swipeCells(_ cell: TaskCell) {
        cell.showSwipe(orientation: .left)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.reuseIdentifier, for: indexPath) as? TaskCell else { return UICollectionViewCell() }
        
        //SwipeCell Delegate
        cell.delegate = self
        swipeCells(cell)
        var transactionResults: Results<Transaction>
        
        switch transactionView {
        case .toDo:
            transactionResults = unpostedTransactions
        case .posted:
            transactionResults = postedTransactions
        case .future:
            transactionResults = futureTransactions
        }
        
        let image = UIImage(named: transactionResults[indexPath.item].transactionCategory!.categoryName)
        let color =  UIColor(rgb: transactionResults[indexPath.item].transactionCategory!.categoryColor)
        let name = transactionResults[indexPath.item].transactionName
        let amount = transactionResults[indexPath.item].transactionAmount.toAttributedString(size: 9, offset: 6, weight: .regular)
        
        let date = transactionResults[indexPath.item].transactionDate.toString(.custom("MMMM dd, yyyy"))
        let transactionsTotalAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", transactionResults[indexPath.item].transactionDate).sum(ofProperty: "transactionAmount")
        
        let startingBalance: Double = realm.objects(StartingBalance.self).sum(ofProperty: "amount")
        
        let totalBalance: Double = transactionsTotalAtDate + startingBalance
        
        let balance = totalBalance.toAttributedString(size: 9, offset: 6, weight: .regular)
        
        cell.configureCells(image: image!, color: color, name: name, amount: amount, date: date, balance: balance)
        
        if transactionResults[indexPath.item].transactionAmount > 0 {
            
            cell.amountLabel.textColor = UIColor(rgb: SystemColors.shared.green)
            
        } else {
            
            cell.amountLabel.textColor = UIColor(rgb: SystemColors.shared.red)
            
        }
        
        if !transactionResults[indexPath.item].isCleared && transactionView != .toDo {
            
            cell.amountLabel.textColor = .systemGray2
            cell.nameLabel.textColor = .systemGray2
            cell.dateLabel.textColor = .systemGray2
            cell.balanceLabel.textColor = .systemGray2
        } else {
            cell.nameLabel.textColor = .label
            cell.dateLabel.textColor = .label
            cell.balanceLabel.textColor = .label
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
        } else if orientation == .left {
            options.expansionStyle = .destructiveAfterFill
            options.transitionStyle = .drag
        }
        
        return options
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
                
        if orientation == .left && transactionView != .future {

            print("Swipe Left")
            
            var actionTitle = ""
            
            if transactionView == .toDo {
                actionTitle = "Clear"
            } else {
                actionTitle = "Unclear"
            }
            let clearAction = SwipeAction(style: .default, title: actionTitle) { [self] action, indexPath in
                
                var transactionToEdit: Results<Transaction>
                
                switch self.transactionView {
                case .toDo:
                    transactionToEdit = unpostedTransactions
                case .posted:
                    transactionToEdit = postedTransactions
                case .future:
                    transactionToEdit = futureTransactions
                }
                
                try! realm.write {
                    transactionToEdit[indexPath.item].isCleared = !transactionToEdit[indexPath.item].isCleared
                }
                
                
                updateInstructionsLabel()
                
                action.fulfill(with: .reset)
                
                collectionView.reloadData()
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                NotificationCenter.default.post(name: NSNotification.Name("transactionCleared"), object: nil)
                
            }
            
            clearAction.image = UIImage(systemName: "checkmark")
            clearAction.backgroundColor = UIColor(rgb: SystemColors.shared.blue)
            
            return [clearAction]
        } else if orientation == .right {
            
            print("Swipe Right")

            
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
                
                switch self.transactionView {
                case .toDo:
                    do {
                        try self.realm.write {
                            self.realm.delete(self.unpostedTransactions[indexPath.item])
//                        try self.realm.write {
//                            self.unpostedTransactions[indexPath.item].isCleared = !self.unpostedTransactions[indexPath.item].isCleared
                        }
                    } catch {
                        print("Error deleting unposted transaction: \(error)")
                    }
                case .posted:
                    do {
                        try self.realm.write {
                            self.realm.delete(self.postedTransactions[indexPath.item])
                        }
                    } catch {
                        print("Error deleting posted transaction: \(error)")
                    }
                case .future:
                    do {
                        try self.realm.write {
                            self.realm.delete(self.futureTransactions[indexPath.item])
                        }
                    } catch {
                        print("Error deleting transaction: \(error)")
                    }
                }
                
                action.fulfill(with: .delete)
                collectionView.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
            }
            
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = UIColor(rgb: SystemColors.shared.red)
            
            return [deleteAction]
        } else {
            return nil
        }
    }
}

extension TaskVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 25)
    }
    
}
