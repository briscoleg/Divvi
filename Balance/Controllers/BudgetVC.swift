//
//  BudgetVC.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

class BudgetVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    
    let realm = try! Realm()
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self)}()
    
    //    var selectedCategory: Category!
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupCategories()
        
//        progressRingSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "reloadCategoryCollectionView"), object: nil)
        
        //        populateDefaultCategories()
        //        populateDefaultColors()
        
        
        tabBarController!.tabBar.items![2].badgeValue = nil
        
        
        //        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        
        
    }
    
    
    //MARK: -  Methods
    
    @objc private func refresh() {
        self.collectionView.reloadData()
    }
    
    public func setupCategories() {
        
        if categories.count == 0 {
            
            //Income Category
            let paycheck = SubCategory()
            paycheck.subCategoryName = "Paycheck"
            paycheck.amountBudgeted = 0.0
            
            let bonus = SubCategory()
            bonus.subCategoryName = "Bonus"
            bonus.amountBudgeted = 0.0
            
            let rentalIncome = SubCategory()
            rentalIncome.subCategoryName = "Rental Income"
            rentalIncome.amountBudgeted = 0.0
            
            let dividendIncome = SubCategory()
            dividendIncome.subCategoryName = "Dividend"
            dividendIncome.amountBudgeted = 0.0
            
            let incomeCategory = Category()
            incomeCategory.categoryName = "Income"
            incomeCategory.categoryColor = 0x20bf6b
            incomeCategory.subCategories.append(paycheck)
            incomeCategory.subCategories.append(bonus)
            incomeCategory.subCategories.append(rentalIncome)
            incomeCategory.subCategories.append(dividendIncome)
            
            //Housing Category
            let mortgageRent = SubCategory()
            mortgageRent.subCategoryName = "Mortgage/Rent"
            mortgageRent.amountBudgeted = 0.0
            
            let propertyTaxes = SubCategory()
            propertyTaxes.subCategoryName = "Property Taxes"
            propertyTaxes.amountBudgeted = 0.0
            
            let hoaFees = SubCategory()
            hoaFees.subCategoryName = "HOA Fees"
            hoaFees.amountBudgeted = 0.0
            
            let householdRepairs = SubCategory()
            householdRepairs.subCategoryName = "Household Repairs"
            householdRepairs.amountBudgeted = 0.0
            
            let housingCategory = Category()
            housingCategory.categoryName = "Housing"
            housingCategory.categoryColor = 0x778ca3
            housingCategory.subCategories.append(mortgageRent)
            housingCategory.subCategories.append(propertyTaxes)
            housingCategory.subCategories.append(hoaFees)
            housingCategory.subCategories.append(householdRepairs)
            
            //Transportation Category
            let carPayment = SubCategory()
            carPayment.subCategoryName = "Car Payment"
            carPayment.amountBudgeted = 0.0
            
            let gasFuel = SubCategory()
            gasFuel.subCategoryName = "Gas/Fuel"
            gasFuel.amountBudgeted = 0.0
            
            let carRepairs = SubCategory()
            carRepairs.subCategoryName = "Car Repairs"
            carRepairs.amountBudgeted = 0.0
            
            let carRegistration = SubCategory()
            carRegistration.subCategoryName = "Registration"
            carRegistration.amountBudgeted = 0.0
            
            let transportationCategory = Category()
            transportationCategory.categoryName = "Transportation"
            transportationCategory.categoryColor = 0xeb3b5a
            
            transportationCategory.subCategories.append(carPayment)
            transportationCategory.subCategories.append(gasFuel)
            transportationCategory.subCategories.append(carRepairs)
            transportationCategory.subCategories.append(carRegistration)
            
            //Food Category
            let groceries = SubCategory()
            groceries.subCategoryName = "Groceries"
            groceries.amountBudgeted = 0.0
            
            let restaurants = SubCategory()
            restaurants.subCategoryName = "Restaurants"
            restaurants.amountBudgeted = 0.0
            
            let bars = SubCategory()
            bars.subCategoryName = "Bars"
            bars.amountBudgeted = 0.0
            
            let foodDrinkCategory = Category()
            foodDrinkCategory.categoryName = "Food/Drink"
            foodDrinkCategory.categoryColor = 0xfed330
            
            foodDrinkCategory.subCategories.append(groceries)
            foodDrinkCategory.subCategories.append(restaurants)
            foodDrinkCategory.subCategories.append(bars)
            
            //Clothing Category
            let essentialClothing = SubCategory()
            essentialClothing.subCategoryName = "Essential Clothing"
            essentialClothing.amountBudgeted = 0.0
            
            let shoes = SubCategory()
            shoes.subCategoryName = "Shoes"
            shoes.amountBudgeted = 0.0
            
            let clothingCategory = Category()
            clothingCategory.categoryName = "Clothing"
            clothingCategory.categoryColor = 0xfa8231
            
            clothingCategory.subCategories.append(essentialClothing)
            clothingCategory.subCategories.append(shoes)
            
            //Utilities Category
            let electricity = SubCategory()
            electricity.subCategoryName = "Electricity"
            electricity.amountBudgeted = 0.0
            
            let water = SubCategory()
            water.subCategoryName = "Water"
            water.amountBudgeted = 0.0
            
            let trashSewer = SubCategory()
            trashSewer.subCategoryName = "Trash/Sewer"
            trashSewer.amountBudgeted = 0.0
            
            let internet = SubCategory()
            internet.subCategoryName = "Internet"
            internet.amountBudgeted = 0.0
            
            let cable = SubCategory()
            cable.subCategoryName = "Cable"
            cable.amountBudgeted = 0.0
            
            let cellPhone = SubCategory()
            cellPhone.subCategoryName = "Cell Phone"
            cellPhone.amountBudgeted = 0.0
            
            let utilitiesCategory = Category()
            utilitiesCategory.categoryName = "Utilities"
            utilitiesCategory.categoryColor = 0x45aaf2
            
            utilitiesCategory.subCategories.append(electricity)
            utilitiesCategory.subCategories.append(water)
            utilitiesCategory.subCategories.append(trashSewer)
            utilitiesCategory.subCategories.append(internet)
            utilitiesCategory.subCategories.append(cable)
            utilitiesCategory.subCategories.append(cellPhone)
            
            //Insurance Category
            let carInsurance = SubCategory()
            carInsurance.subCategoryName = "Car/Truck"
            carInsurance.amountBudgeted = 0.0
            
            let healthInsurance = SubCategory()
            healthInsurance.subCategoryName = "Health"
            healthInsurance.amountBudgeted = 0.0
            
            let dentalInsurance = SubCategory()
            dentalInsurance.subCategoryName = "Dental"
            dentalInsurance.amountBudgeted = 0.0
            
            let homeOwnersInsurance = SubCategory()
            homeOwnersInsurance.subCategoryName = "Homeowner's"
            homeOwnersInsurance.amountBudgeted = 0.0
            
            let rentersInsurance = SubCategory()
            rentersInsurance.subCategoryName = "Renter's"
            rentersInsurance.amountBudgeted = 0.0
            
            
            let insuranceCategory = Category()
            insuranceCategory.categoryName = "Insurance"
            insuranceCategory.categoryColor = 0xfc5c65
            
            insuranceCategory.subCategories.append(carInsurance)
            insuranceCategory.subCategories.append(healthInsurance)
            insuranceCategory.subCategories.append(dentalInsurance)
            insuranceCategory.subCategories.append(homeOwnersInsurance)
            insuranceCategory.subCategories.append(rentersInsurance)
            
            //Entertainment Category
            let movies = SubCategory()
            movies.subCategoryName = "Movies"
            movies.amountBudgeted = 0.0
            
            let shopping = SubCategory()
            shopping.subCategoryName = "Shopping"
            shopping.amountBudgeted = 0.0
            
            let entertainmentCategory = Category()
            entertainmentCategory.categoryName = "Entertainment"
            entertainmentCategory.categoryColor = 0xa55eea
            entertainmentCategory.subCategories.append(movies)
            entertainmentCategory.subCategories.append(shopping)
            
            //Savings Category
            let emergencyFund = SubCategory()
            emergencyFund.subCategoryName = "Emergency Fund"
            emergencyFund.amountBudgeted = 0.0
            
            let carFund = SubCategory()
            carFund.subCategoryName = "Car Fund"
            carFund.amountBudgeted = 0.0
            
            let savingsCategory = Category()
            savingsCategory.categoryName = "Savings"
            savingsCategory.categoryColor = 0x20bf6b
            
            savingsCategory.subCategories.append(emergencyFund)
            savingsCategory.subCategories.append(carFund)
            
            //Debt Category
            let creditCard = SubCategory()
            creditCard.subCategoryName = "Credit Card Payment"
            creditCard.amountBudgeted = 0.0
            
            let loanPayment = SubCategory()
            loanPayment.subCategoryName = "Loan Payment"
            loanPayment.amountBudgeted = 0.0
            
            let debtCategory = Category()
            debtCategory.categoryName = "Debt"
            debtCategory.categoryColor = 0xeb3b5a
            
            debtCategory.subCategories.append(creditCard)
            debtCategory.subCategories.append(loanPayment)
            
            try! realm.write() {
                
                
                realm.add(incomeCategory)
                realm.add(housingCategory)
                realm.add(transportationCategory)
                realm.add(foodDrinkCategory)
                realm.add(clothingCategory)
                realm.add(utilitiesCategory)
                realm.add(insuranceCategory)
                realm.add(entertainmentCategory)
                realm.add(savingsCategory)
                realm.add(debtCategory)
            }
            
            categories = realm.objects(Category.self)
            
        }
    }
    
//    private func progressRingSetup() {
//
//        let center = view.center
//
//        let trackLayer = CAShapeLayer()
//
//        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 2, clockwise: true)
//
//        trackLayer.path = circularPath.cgPath
//
//        trackLayer.strokeColor = UIColor.lightGray.cgColor
//
//        trackLayer.lineWidth = 10
//
//        trackLayer.lineCap = .round
//
//        view.layer.addSublayer(trackLayer)
//
//        shapeLayer.path = circularPath.cgPath
//
//        shapeLayer.strokeColor = UIColor.red.cgColor
//
//        shapeLayer.lineWidth = 10
//
//        shapeLayer.lineCap = .round
//
//        shapeLayer.fillColor = UIColor.clear.cgColor
//
//        shapeLayer.strokeEnd = 0
//
//        view.layer.addSublayer(shapeLayer)
//
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
//
//    }
    
//    @objc private func handleTap() {
//        
//        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
//        
//        basicAnimation.toValue = 1
//        
//        basicAnimation.duration = 2
//        
//        basicAnimation.fillMode = .forwards
//        
//        basicAnimation.isRemovedOnCompletion = false
//        
//        shapeLayer.add(basicAnimation, forKey: "customKey")
//        
//    }
    
    
    
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            try! self.realm.write {
                
                let newCategory = Category()
                newCategory.categoryName = textField.text!
                newCategory.categoryColor = 0xd8d8d8
                
                self.realm.add(newCategory)
                
            }
            
            self.categories = self.realm.objects(Category.self)
            
            
            self.collectionView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCategoryCollectionView"), object: nil)
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (cancelAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { (field) in
            
            textField = field
            textField.placeholder = "Enter a category name"
            textField.autocapitalizationType = .words
            
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

//MARK: - Delegate Methods
extension BudgetVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(identifier: "SubVC") as? SubVC {
            
            vc.categorySelected = categories[indexPath.item]
            vc.subCategories = categories[indexPath.item].subCategories
            vc.viewTitle = categories[indexPath.item].categoryName
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

//MARK: - DataSource Methods
extension BudgetVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categories.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BudgetCell", for: indexPath) as! BudgetCell
        
        cell.nameLabel.text = categories[indexPath.item].categoryName
        
        let categoriesTotal: Double = categories[indexPath.item].subCategories.sum(ofProperty: "amountBudgeted")
        
        cell.amountBudgetedLabel.text = categoriesTotal.toCurrency()
        
        let transactionsTotal: Double = transactions.filter(NSPredicate(format: "transactionCategory CONTAINS %@ ", categories[indexPath.row].categoryName)).sum(ofProperty: "transactionAmount")
        
        cell.amountSpentLabel.text = transactionsTotal.toCurrency()
        
        //Progress Ring
        
        
        
    
        cell.progressRingView.progressLayerStrokeColor = UIColor(rgb: categories[indexPath.item].categoryColor)
        
        let plannedToSpentRatio = transactionsTotal / categoriesTotal
        
        print(plannedToSpentRatio)
        
        cell.progressRingView.progressLayerStrokeEnd = CGFloat(plannedToSpentRatio)
    
    //        let categoryTotal: Double = realm.objects(Category.self).filter("ANY subCategories == %@",categories[indexPath.item].subCategories).sum(ofProperty: "amountBudgeted")
    
    //        let categoryTotal2: Double = incomeCategory
    
    //        print(categoryTotal)
    
    //        cell.amountBudgetedLabel.text =
    //            String(format: "%.2f", categories[indexPath.item].subCategories[indexPath.item].amountBudgeted)
    
    //        let realmColor = UIColor(rgb: categories[indexPath.item].color)
    
    cell.backgroundColor = UIColor(rgb: categories[indexPath.item].categoryColor).withAlphaComponent(0.25)
    //        cell.backgroundColor = realmColor
    
    //        cell.progressRingView.foregroundCircleColor = UIColor(rgb: categories[indexPath.item].categoryColor).cgColor
    cell.progressRingView.backgroundColor = UIColor.clear
    
    
    cell.layer.shadowColor = UIColor.darkGray.cgColor
    
    return cell
}




}
