//
//  SummaryVC.swift
//  Balance
//
//  Created by Bo on 6/22/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift

class SummaryVC: UIViewController {
    
    static let identifier = "SummaryVC"
    
    //MARK: - IBOutlets
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var prevMonthButton: UIButton!
    
    //MARK: - Properties
    
    private let realm = try! Realm()
    private lazy var transaction: Results<Transaction> = { self.realm.objects(Transaction.self) }()
    private lazy var filteredTransactions: Results<Transaction> = { self.realm.objects(Transaction.self).filter(dateRangePredicate) }()
    private lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    private lazy var unclearedTransactionsToDate: Results<Transaction> = { transaction.filter("transactionDate <= %@", Date()).filter("isCleared == %@", false).sorted(byKeyPath: "transactionDate", ascending: true) }()
    
    private var dateRangePredicate = NSPredicate()
    
    private var currentPage: Date?

    private lazy var today: Date = {
        return Date()
    }()
    
    private var calendarHeightAnchor: NSLayoutConstraint?
    
    private let userDefaults = UserDefaults()
        
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true

        if userDefaults.value(forKey: "startingBalanceSet") == nil {
            userDefaults.setValue(false, forKey: "startingBalanceSet")
        }
        
        print(userDefaults.value(forKey: "startingBalanceSet"))
        
        configureDelegates()
        setupCategoriesOnFirstLoad()
        customizeTabBarAppearance()
        showBadgeForUnclearedTransactions()
        configureObservers()
        configureCollectionViewLayout()
        
        todayButton.backgroundColor = UIColor(rgb: SystemColors.shared.blue)
//        prevMonthButton.tintColor = UIColor(rgb: SystemColors.blue)
//        nextMonthButton.tintColor = UIColor(rgb: SystemColors.blue)
        todayButton.roundCorners()
//        prevMonthButton.roundCorners()
//        nextMonthButton.roundCorners()
        
        //        calendar.scrollDirection = .vertical
                print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        
        //        navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        
        calendar.select(calendar.today)
        //        calendar.setCurrentPage(Date(), animated: true)
        
        
        
        
        
        
        //Hide Nav Bar Line
        //        navigationBar.setValue(true, forKey: "hidesShadow")
        
        //        let todayItem = UIBarButtonItem(title: "TODAY", style: .plain, target: self, action: #selector(self.todayItemClicked(sender:)))
        //        self.navigationItem.rightBarButtonItem = todayItem
        
        getBalanceAtDate(Date())
        
        
        
        dateRangePredicate = predicateForDayFromDate(date: Date())
        
        //        calendar.collectionView.reloadData()
        
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        
    }
    //MARK: - Methods
    
    private func configureDelegates() {
        calendar.delegate = self
        calendar.dataSource = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionEdited"), object: nil)
    }
    
    private func showBadgeForUnclearedTransactions() {
        
        if unclearedTransactionsToDate.count > 0 {
            tabBarController!.tabBar.items![1].badgeValue = "1"
        } else {
            tabBarController!.tabBar.items![1].badgeValue = nil
        }
        
    }
    
    private func customizeTabBarAppearance() {
        let appearance = tabBarController?.tabBar.standardAppearance
        
        appearance?.backgroundColor = .systemBackground
        appearance?.shadowImage = nil
        appearance?.shadowColor = nil
//        tabBarController?.tabBar.isTranslucent = true
        tabBarController?.tabBar.standardAppearance = appearance!
    }
    
    private func configureCollectionViewLayout() {
        
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        
    }
    
    @objc private func refresh() {
        collectionView.reloadData()
        calendar.reloadData()
        getBalanceAtDate(Date() + 61199)
        displaySelectedDate(Date())
        showBadgeForUnclearedTransactions()
        
    }
    
    private func getBalanceAtDate(_ date: Date) {
        
        let transactionsTotalAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", date).sum(ofProperty: "transactionAmount")
        
        let startingBalance: Double = realm.objects(StartingBalance.self).filter("date <= %@", date).sum(ofProperty: "amount")
        
        let totalBalance: Double = transactionsTotalAtDate + startingBalance
        
        amountLabel.attributedText = totalBalance.toAttributedString(size: 45, offset: 10, weight: .ultraLight)
//        amountLabel.text = transactionsTotalAtDate.toCurrency()
        
    }
    
    private func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        
        let dateString = formatter.string(from: date)
        if dateString == formatter.string(from: Date()) {
            dateLabel.text = "Today"
        } else {
            dateLabel.text = dateString
        }
        
    }
    
    private func predicateForDayFromDate(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
    }
    
    private func negativeTransactionPredicate(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@ && transactionAmount < 0", argumentArray: [startDate!, endDate!])
    }
    
    private func positiveTransactionPredicate(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@ && transactionAmount > 0", argumentArray: [startDate!, endDate!])
    }
    
    
    //    private func positiveAndNegativeTransactionPredicate(date: Date) -> NSPredicate {
    //        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    //        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    //
    //        components.hour = 00
    //        components.minute = 00
    //        components.second = 00
    //
    //        let startDate = calendar.date(from: components)
    //
    //        components.hour = 23
    //        components.minute = 59
    //        components.second = 59
    //
    //        let endDate = calendar.date(from: components)
    //
    //        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@ && transactionAmount > 0 || transactionAmount < 0", argumentArray: [startDate!, endDate!])
    //    }
    
    //MARK: - Setup Categories
    
    private func setupCategoriesOnFirstLoad() {
        
        if categories.count == 0 {
            
            //Income Category
            let paycheck = SubCategory()
            paycheck.subCategoryName = "Paycheck"
            paycheck.subCategoryAmountBudgeted = 0.0
            
            let bonus = SubCategory()
            bonus.subCategoryName = "Bonus"
            bonus.subCategoryAmountBudgeted = 0.0
            
            let rentalIncome = SubCategory()
            rentalIncome.subCategoryName = "Rental Income"
            rentalIncome.subCategoryAmountBudgeted = 0.0
            
            let dividendIncome = SubCategory()
            dividendIncome.subCategoryName = "Dividend"
            dividendIncome.subCategoryAmountBudgeted = 0.0
            
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
            mortgageRent.subCategoryAmountBudgeted = 0.0
            
            let propertyTaxes = SubCategory()
            propertyTaxes.subCategoryName = "Property Taxes"
            propertyTaxes.subCategoryAmountBudgeted = 0.0
            
            let hoaFees = SubCategory()
            hoaFees.subCategoryName = "HOA Fees"
            hoaFees.subCategoryAmountBudgeted = 0.0
            
            let householdRepairs = SubCategory()
            householdRepairs.subCategoryName = "Household Repairs"
            householdRepairs.subCategoryAmountBudgeted = 0.0
            
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
            carPayment.subCategoryAmountBudgeted = 0.0
            
            let gasFuel = SubCategory()
            gasFuel.subCategoryName = "Gas/Fuel"
            gasFuel.subCategoryAmountBudgeted = 0.0
            
            let carRepairs = SubCategory()
            carRepairs.subCategoryName = "Car Repairs"
            carRepairs.subCategoryAmountBudgeted = 0.0
            
            let carRegistration = SubCategory()
            carRegistration.subCategoryName = "Registration"
            carRegistration.subCategoryAmountBudgeted = 0.0
            
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
            groceries.subCategoryAmountBudgeted = 0.0
            
            let restaurants = SubCategory()
            restaurants.subCategoryName = "Restaurants"
            restaurants.subCategoryAmountBudgeted = 0.0
            
            let bars = SubCategory()
            bars.subCategoryName = "Bars"
            bars.subCategoryAmountBudgeted = 0.0
            
            let foodCategory = Category()
            foodCategory.categoryName = "Food"
            foodCategory.categoryColor = 0xfed330
            
            foodCategory.subCategories.append(groceries)
            foodCategory.subCategories.append(restaurants)
            foodCategory.subCategories.append(bars)
            
            //Clothing Category
            let essentialClothing = SubCategory()
            essentialClothing.subCategoryName = "Essential Clothing"
            essentialClothing.subCategoryAmountBudgeted = 0.0
            
            let shoes = SubCategory()
            shoes.subCategoryName = "Shoes"
            shoes.subCategoryAmountBudgeted = 0.0
            
            let clothingCategory = Category()
            clothingCategory.categoryName = "Clothing"
            clothingCategory.categoryColor = 0xfa8231
            
            clothingCategory.subCategories.append(essentialClothing)
            clothingCategory.subCategories.append(shoes)
            
            //Utilities Category
            let electricity = SubCategory()
            electricity.subCategoryName = "Electricity"
            electricity.subCategoryAmountBudgeted = 0.0
            
            let water = SubCategory()
            water.subCategoryName = "Water"
            water.subCategoryAmountBudgeted = 0.0
            
            let trashSewer = SubCategory()
            trashSewer.subCategoryName = "Trash/Sewer"
            trashSewer.subCategoryAmountBudgeted = 0.0
            
            let internet = SubCategory()
            internet.subCategoryName = "Internet"
            internet.subCategoryAmountBudgeted = 0.0
            
            let cable = SubCategory()
            cable.subCategoryName = "Cable"
            cable.subCategoryAmountBudgeted = 0.0
            
            let cellPhone = SubCategory()
            cellPhone.subCategoryName = "Cell Phone"
            cellPhone.subCategoryAmountBudgeted = 0.0
            
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
            carInsurance.subCategoryAmountBudgeted = 0.0
            
            let healthInsurance = SubCategory()
            healthInsurance.subCategoryName = "Health"
            healthInsurance.subCategoryAmountBudgeted = 0.0
            
            let dentalInsurance = SubCategory()
            dentalInsurance.subCategoryName = "Dental"
            dentalInsurance.subCategoryAmountBudgeted = 0.0
            
            let homeOwnersInsurance = SubCategory()
            homeOwnersInsurance.subCategoryName = "Homeowner's"
            homeOwnersInsurance.subCategoryAmountBudgeted = 0.0
            
            let rentersInsurance = SubCategory()
            rentersInsurance.subCategoryName = "Renter's"
            rentersInsurance.subCategoryAmountBudgeted = 0.0
            
            
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
            movies.subCategoryAmountBudgeted = 0.0
            
            let shopping = SubCategory()
            shopping.subCategoryName = "Shopping"
            shopping.subCategoryAmountBudgeted = 0.0
            
            let entertainmentCategory = Category()
            entertainmentCategory.categoryName = "Lifestyle"
            entertainmentCategory.categoryColor = 0xa55eea
            entertainmentCategory.subCategories.append(movies)
            entertainmentCategory.subCategories.append(shopping)
            
            //Savings Category
            let emergencyFund = SubCategory()
            emergencyFund.subCategoryName = "Emergency Fund"
            emergencyFund.subCategoryAmountBudgeted = 0.0
            
            let carFund = SubCategory()
            carFund.subCategoryName = "Car Fund"
            carFund.subCategoryAmountBudgeted = 0.0
            
            let savingsCategory = Category()
            savingsCategory.categoryName = "Savings"
            savingsCategory.categoryColor = 0x20bf6b
            
            savingsCategory.subCategories.append(emergencyFund)
            savingsCategory.subCategories.append(carFund)
            
            //Debt Category
            let creditCard = SubCategory()
            creditCard.subCategoryName = "Credit Card Payment"
            creditCard.subCategoryAmountBudgeted = 0.0
            
            let loanPayment = SubCategory()
            loanPayment.subCategoryName = "Loan Payment"
            loanPayment.subCategoryAmountBudgeted = 0.0
            
            let debtCategory = Category()
            debtCategory.categoryName = "Debt"
            debtCategory.categoryColor = 0xeb3b5a
            
            debtCategory.subCategories.append(creditCard)
            debtCategory.subCategories.append(loanPayment)
            
            try! realm.write() {
                
                
                realm.add(incomeCategory)
                realm.add(housingCategory)
                realm.add(transportationCategory)
                realm.add(foodCategory)
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
    
    //MARK: - IBActions
    @IBAction func todayButtonPressed(_ sender: UIButton) {
        
        calendar.setCurrentPage(Date(), animated: true)
        
        calendar.select(calendar.today)
        
        displaySelectedDate(Date())
        
        getBalanceAtDate(Date())
        
        dateRangePredicate = predicateForDayFromDate(date: Date())
        
        collectionView.reloadData()
        
    }
    
    @IBAction func nextMonthButtonPressed(_ sender: UIButton) {
        
        
    }
    
    @IBAction func prevMonthButtonPressed(_ sender: UIButton) {
        
    }
}

//MARK: - Calendar Delegate, DataSource, & Appearance
extension SummaryVC: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        getBalanceAtDate(date + 61199)
        
        displaySelectedDate(date)
        
        dateRangePredicate = predicateForDayFromDate(date: date)
        
        collectionView.reloadData()
        
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let incomeTransaction = realm.objects(Transaction.self).filter(positiveTransactionPredicate(date: date))
        
        let expenseTransaction = realm.objects(Transaction.self).filter(negativeTransactionPredicate(date: date))
        
        for _ in incomeTransaction {
            return 1
        }
        for _ in expenseTransaction {
            return 1
        }
        
        return 0
        
    }
    

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return .label
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        let incomeTransaction = realm.objects(Transaction.self).filter(positiveTransactionPredicate(date: date))
        
        let expenseTransaction = realm.objects(Transaction.self).filter(negativeTransactionPredicate(date: date))

        for _ in incomeTransaction {
            return [UIColor(rgb: SystemColors.shared.green)]
        }
        for _ in expenseTransaction {
            return [UIColor(rgb: SystemColors.shared.red)]
        }
        
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
                
        calendar.appearance.todayColor = UIColor(rgb: SystemColors.shared.yellow)
        
        calendar.appearance.selectionColor = UIColor(rgb: SystemColors.shared.blue)
        
    }
    
    
}


//MARK: - CollectionView Delegate & DataSource
extension SummaryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: DetailVC.identifier) as? DetailVC {
            let transactions = realm.objects(Transaction.self).filter(dateRangePredicate)[indexPath.row]
            
            vc.transaction = transactions
            
            present(vc, animated: true, completion: nil)
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return transaction.filter(dateRangePredicate).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SummaryCell.cellId, for: indexPath) as! SummaryCell
        
        let filteredTransactions = realm.objects(Transaction.self).filter(dateRangePredicate)
        
        let amount = filteredTransactions[indexPath.row].transactionAmount

        if let image = UIImage(named: filteredTransactions[indexPath.item].transactionCategory!.categoryName) {
            cell.configure(with: image, and: amount)

        }
    
        cell.circleView.backgroundColor = UIColor(rgb: filteredTransactions[indexPath.item].transactionCategory!.categoryColor)
        
                
        cell.amountLabel.attributedText = amount.toAttributedString(size: 9, offset: 4, weight: .regular)
        
        if filteredTransactions[indexPath.row].transactionAmount > 0 {
            
            cell.amountLabel.textColor = UIColor(rgb: SystemColors.shared.green)
        } else {
            cell.amountLabel.textColor = UIColor(rgb: SystemColors.shared.red)
        }
        
        return cell
    }
    
}

extension SummaryVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.width / 5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//extension FSCalendarScope {
//    func asCalendarComponent() -> Calendar.Component {
//        switch (self) {
//        case .month: return .month
//        case .week: return .weekOfYear
//        }
//     }
//}
