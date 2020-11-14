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
    
    //MARK: - Properties
    let realm = try! Realm()
    lazy var postedTransactions: Results<Transaction> = { realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: false).filter("isCleared == %@", true) }()
    lazy var unpostedTransactions: Results<Transaction> = { self.realm.objects(Transaction.self).filter("transactionDate <= %@", Date().advanced(by: 10000)).filter("isCleared == %@", false).sorted(byKeyPath: "transactionDate", ascending: true) }()
    lazy var futureTransactions: Results<Transaction> = { realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: true).filter("isCleared == %@", false) }()
    var transactionView = TransactionView.toDo
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
        
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        
    }
    
    private func updateInstructionsLabel() {
        switch transactionView {
        case .toDo:
            if unpostedTransactions.count > 0 {
                instructionsLabel.text = "Swipe right to clear transactions.\n\nClearing transactions will update your monthly budget\nin the planning tab."
                tabBarController!.tabBar.items![1].badgeValue = "1"
            } else {
                instructionsLabel.text = "Great job! All transactions are cleared.\n\nCheck back after you add a new transaction\n or clear transactions as they come up."
                tabBarController!.tabBar.items![1].badgeValue = nil
            }
        case .posted:
            instructionsLabel.text = ""
        case .future:
            instructionsLabel.text = ""
            
        }
    }
    
    private func presentDetailVC(_ indexPath: IndexPath) {
        
        var transactionToPresent = Transaction()
        
        switch transactionView {
        case .toDo:
            transactionToPresent = unpostedTransactions[indexPath.item]
        case .posted:
            transactionToPresent = postedTransactions[indexPath.item]
        case .future:
            transactionToPresent = futureTransactions[indexPath.item]
            
            if let vc = storyboard?.instantiateViewController(withIdentifier: DetailVC.identifier) as? DetailVC {
                
                vc.transaction = transactionToPresent
                present(vc, animated: true, completion: nil)
                
            }
        }
    }
    
    
    //MARK: - IBActions
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
        presentDetailVC(indexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.reuseIdentifier, for: indexPath) as? TaskCell else { return UICollectionViewCell() }
        
        //SwipeCell Delegate
        cell.delegate = self
        
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
        let balanceAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", transactionResults[indexPath.item].transactionDate).sum(ofProperty: "transactionAmount")
        let balance = balanceAtDate.toAttributedString(size: 9, offset: 6, weight: .regular)
        
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
        } else {
            options.expansionStyle = .destructiveAfterFill
            options.transitionStyle = .drag
        }
        
        return options
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        
        if orientation == .left && transactionView != .future{
            
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
                
                NotificationCenter.default.post(name: NSNotification.Name("transactionCleared"), object: nil)
                
            }
            
            clearAction.image = UIImage(systemName: "checkmark")
            clearAction.backgroundColor = UIColor(rgb: SystemColors.shared.blue)
            
            return [clearAction]
        } else if orientation == .right {
            
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
                
                switch self.transactionView {
                case .toDo:
                    do {
                        try self.realm.write {
                            self.realm.delete(self.unpostedTransactions[indexPath.item])
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
