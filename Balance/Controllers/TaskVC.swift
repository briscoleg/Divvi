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
    lazy var allTransactions: Results<Transaction> = { realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: true) }()
    lazy var unclearedTransactionsToDate: Results<Transaction> = { self.realm.objects(Transaction.self).filter("transactionDate <= %@", Date().advanced(by: 1000)).filter("isCleared == %@", false).sorted(byKeyPath: "transactionDate", ascending: true) }()
    //    lazy var categories: Results<Category> = { self.realm.objects(Category.self).sorted(byKeyPath: "transactionDate", ascending: true) }()
    //    let categoryVC = CategoryVC()
    var unclearedView = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        updateInstructionsLabel()
        
        setupCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
        
        
    }
    
    //MARK: - Methods
    
    @objc func refresh() {
        collectionView.reloadData()
        updateInstructionsLabel()
        
        
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
                          
             layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
             
             layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 75)
             
             layout.minimumInteritemSpacing = 0
             
             layout.minimumLineSpacing = 5
             
             layout.headerReferenceSize = CGSize(width: 0, height: 25)
             
             collectionView.collectionViewLayout = layout
    }
    
    fileprivate func updateInstructionsLabel() {
        if unclearedTransactionsToDate.count > 0 {
            instructionsLabel.text = "Swipe right to clear transactions.\nSwipe left to delete."
            tabBarController!.tabBar.items![1].badgeValue = "1"
        } else {
            instructionsLabel.text = "All clear!"
            tabBarController!.tabBar.items![1].badgeValue = nil
        }
    }
    
    func displayAmount(with amount: Double) -> NSAttributedString {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        let number = currencyFormatter.string(from: NSNumber(value: amount))
        
        let mutableAttributedString = NSMutableAttributedString(string: number!)
        if let range = mutableAttributedString.string.range(of: #"(?<=.)(\d{2})$"#, options: .regularExpression) {
            mutableAttributedString.setAttributes([.font: UIFont.systemFont(ofSize: 9), .baselineOffset: 6],
                                                  range: NSRange(range, in: mutableAttributedString.string))
        }
        
        return mutableAttributedString
        
    }
    
    func setCategoryImage() {
        
        
        
    }
    
    //MARK: - IBActions
    @IBAction func dismissPressed(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unclearedSegmentedControlSwitched(_ sender: UISegmentedControl) {
        
        switch clearSegmentedControl.selectedSegmentIndex {
        case 0:
            unclearedView = true
            updateInstructionsLabel()
            collectionView.reloadData()
        case 1:
            unclearedView = false
            instructionsLabel.text = "All Transactions:"
            collectionView.reloadData()
        default:
            break
        }
    }
    
    
}

extension TaskVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var transactionToPresent = Transaction()
        if unclearedView {
            transactionToPresent = unclearedTransactionsToDate[indexPath.item]
        } else {
            transactionToPresent = allTransactions[indexPath.item]
        }

        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
                
        vc.transaction = transactionToPresent
        
        present(vc, animated: true, completion: nil)
        
    }
    
    
}

extension TaskVC: UICollectionViewDataSource, SwipeCollectionViewCellDelegate {
    
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
                
                if self.unclearedView {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if unclearedView {
            return unclearedTransactionsToDate.count
        } else {
            return allTransactions.count
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if unclearedView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
            
            cell.delegate = self
            cell.imageView.image = UIImage(named: unclearedTransactionsToDate[indexPath.item].transactionCategory!.categoryName)
            cell.imageView.tintColor = .white
            cell.circleView.backgroundColor = UIColor(rgb: unclearedTransactionsToDate[indexPath.item].transactionCategory!.categoryColor)
            cell.descLabel.textColor = .black
            cell.dateLabel.textColor = .black
            cell.balanceLabel.textColor = .black
            cell.descLabel.text = unclearedTransactionsToDate[indexPath.item].transactionDescription
            cell.amountLabel.attributedText = displayAmount(with: unclearedTransactionsToDate[indexPath.item].transactionAmount)
            
            let balanceAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", unclearedTransactionsToDate[indexPath.item].transactionDate).sum(ofProperty: "transactionAmount")
            cell.balanceLabel.attributedText = displayAmount(with: balanceAtDate)
            
            let formatter = DateFormatter()
            
            formatter.dateFormat = "MMMM dd, yyyy"
            
            let dateString = formatter.string(from: unclearedTransactionsToDate[indexPath.item].transactionDate)
            
            cell.dateLabel.text = dateString
            
            
            if unclearedTransactionsToDate[indexPath.item].transactionAmount > 0 {
                
                cell.amountLabel.textColor = UIColor(rgb: Constants.green)
                
            } else {
                cell.amountLabel.textColor = UIColor(rgb: Constants.red)
                
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
            
            cell.delegate = self
            
            cell.imageView.image = UIImage(named: allTransactions[indexPath.item].transactionCategory!.categoryName)
            cell.imageView.tintColor = .white
            cell.circleView.backgroundColor = UIColor(rgb: allTransactions[indexPath.item].transactionCategory!.categoryColor)
            cell.descLabel.text = allTransactions[indexPath.item].transactionDescription
            cell.amountLabel.attributedText = displayAmount(with: allTransactions[indexPath.item].transactionAmount)
            
            let balanceAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", allTransactions[indexPath.item].transactionDate).sum(ofProperty: "transactionAmount")
            cell.balanceLabel.attributedText = displayAmount(with: balanceAtDate)
            //                balanceAtDate.toCurrency()
            
            let formatter = DateFormatter()
            
            formatter.dateFormat = "MMMM dd, yyyy"
            
            let dateString = formatter.string(from: allTransactions[indexPath.item].transactionDate)
            
            cell.dateLabel.text = dateString
            
            
            
            if allTransactions[indexPath.item].transactionAmount > 0 {
                
                cell.amountLabel.textColor = UIColor(rgb: Constants.green)
                
            } else {
                cell.amountLabel.textColor = UIColor(rgb: Constants.red)
                
            }
            
            if allTransactions[indexPath.item].isCleared == false {
                cell.amountLabel.textColor = .lightGray
                cell.descLabel.textColor = .lightGray
                cell.dateLabel.textColor = .lightGray
                cell.balanceLabel.textColor = .lightGray
                cell.circleView.backgroundColor = .lightGray
            } else {
                cell.descLabel.textColor = .black
                cell.dateLabel.textColor = .black
                cell.balanceLabel.textColor = .black
                cell.circleView.backgroundColor = UIColor(rgb: allTransactions[indexPath.item].transactionCategory!.categoryColor)
            }
            
            return cell
        }
        
        
        
    }
}

extension UIImageView {
    func applyshadowWithCorner(containerView : UIView, cornerRadious : CGFloat){
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 10
        containerView.layer.cornerRadius = cornerRadious
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadious).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
    }
}
