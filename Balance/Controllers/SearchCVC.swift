//
//  SearchCVC.swift
//  Balance
//
//  Created by Bo on 7/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

class SearchCVC: UIViewController{

    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    let realm = try! Realm()
    var transaction: Results<Transaction>!
    let categoryVC = CategoryVC()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        setupRealm()
    }
    
    //MARK: - Methods
    func setupRealm() {
        
        transaction = realm.objects(Transaction.self)
        
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

extension SearchCVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transaction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        
        let transactions = realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: true)
        
        cell.imageView.image = UIImage(named: transactions[indexPath.item].transactionCategory)
        cell.imageView.makeCircular()
        
        cell.nameLabel.text = transactions[indexPath.item].transactionName
        cell.amountLabel.attributedText = displayAmount(with: transactions[indexPath.item].transactionAmount)
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM dd, yyyy"
        
        let dateString = formatter.string(from: transactions[indexPath.item].transactionDate)
        
        cell.dateLabel.text = dateString
        
        
        
        if transactions[indexPath.row].transactionAmount > 0 {
            
            cell.amountLabel.textColor = UIColor(rgb: Constants.green)
//            cell.colorBar.backgroundColor = UIColor(rgb: Constants.green)
        } else {
            cell.amountLabel.textColor = UIColor(rgb: Constants.red)
//            cell.colorBar.backgroundColor = UIColor(rgb: Constants.red)
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
