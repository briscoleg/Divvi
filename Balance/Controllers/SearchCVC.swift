//
//  SearchCVC.swift
//  Balance
//
//  Created by Bo on 7/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class SearchCVC: UIViewController{
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Properties
    let realm = try! Realm()
    lazy var transaction: Results<Transaction> = { self.realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: true) }()
//    lazy var categories: Results<Category> = { self.realm.objects(Category.self).sorted(byKeyPath: "transactionDate", ascending: true) }()
//    let categoryVC = CategoryVC()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)

        addInputAccessoryForSearchbars(searchBar: searchBar)
        
    }
    
    //MARK: - Methods
    
    @objc private func refresh() {
        self.collectionView.reloadData()
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
    
}

extension SearchCVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        
        let transactions = realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: true)[indexPath.row]
        
        vc.transaction = transactions
        
        present(vc, animated: true, completion: nil)
        
    }
    
    
}

extension SearchCVC: UICollectionViewDataSource, SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                        
            try! self.realm.write {
                self.realm.delete(self.transaction[indexPath.item])
                
            }
            
            collectionView.reloadData()
            
            NotificationCenter.default.post(name: NSNotification.Name("transactionDeleted"), object: nil)
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = UIColor(rgb: Constants.red)
        
        return [deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transaction.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        
        cell.delegate = self
        
        cell.imageView.image = UIImage(named: transaction[indexPath.item].transactionCategory!.categoryName)
        cell.imageView.tintColor = .white
        cell.circleView.backgroundColor = UIColor(rgb: transaction[indexPath.item].transactionCategory!.categoryColor)
        cell.descLabel.text = transaction[indexPath.item].transactionDescription
        cell.amountLabel.attributedText = displayAmount(with: transaction[indexPath.item].transactionAmount)
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM dd, yyyy"
        
        let dateString = formatter.string(from: transaction[indexPath.item].transactionDate)
        
        cell.dateLabel.text = dateString
        
        
        
        if transaction[indexPath.row].transactionAmount > 0 {
            
            cell.amountLabel.textColor = UIColor(rgb: Constants.green)

        } else {
            cell.amountLabel.textColor = UIColor(rgb: Constants.red)

        }
        
        return cell
        
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
