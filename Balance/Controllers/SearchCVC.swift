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
    @IBOutlet weak var viewCircle: UIView!
    
    //MARK: - Properties
    let realm = try! Realm()
    var transaction: Results<Transaction>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupRealm()
        
        
        
        

    }
    
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
    
    
    @IBAction func dismissPressed(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension SearchCVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(transaction[indexPath.item])
    }


}

extension SearchCVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transaction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        
        let transactions = realm.objects(Transaction.self)
        
        cell.nameLabel.text = transactions[indexPath.item].transactionName
        cell.amountLabel.attributedText = displayAmount(with: transactions[indexPath.item].transactionAmount)
        
        if transactions[indexPath.row].transactionAmount > 0 {
            
            cell.amountLabel.textColor = UIColor(rgb: Constants.green)
        } else {
            cell.amountLabel.textColor = UIColor(rgb: Constants.red)
        }
        
        return cell
        
    }
    

    

}
