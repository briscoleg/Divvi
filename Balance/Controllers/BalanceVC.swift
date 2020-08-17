//
//  ViewController.swift
//  Balance
//
//  Created by Bo on 6/22/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift

class BalanceVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transactionsLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    //MARK: - Properties
    let realm = try! Realm()
    lazy var transaction: Results<Transaction> = { self.realm.objects(Transaction.self) }()
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()

//    let addItemVC = AddVC()
    var selectedCalendarDate = Date()
    var dateTappedOnCalendar = Date()
    let todaysDate = Date()
    var startDate: Date?
    var endDate: Date?
    var dateRangePredicate = NSPredicate()
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        calendar.delegate = self
        calendar.dataSource = self
//        calendar.appearance.
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        todayButton.makeCircular()
        
        calendar.select(calendar.today)
        calendar.setCurrentPage(Date(), animated: true)

        
        setupCategories()
                
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
        
        //Hide Nav Bar Line
        navigationBar.setValue(true, forKey: "hidesShadow")
        
        let todayItem = UIBarButtonItem(title: "TODAY", style: .plain, target: self, action: #selector(self.todayItemClicked(sender:)))
        self.navigationItem.rightBarButtonItem = todayItem
        //        DataManager.shared.summaryVC = self
        
        tableView.rowHeight = 40
        
        getTotalAtDate(Date())
        
        dateRangePredicate = predicateForDayFromDate(date: todaysDate)
        
        calendar.collectionView.reloadData()
        
        tableView.reloadData()
        
        tableView.register(UINib(nibName: "SummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "SummaryTableViewCell")
        
//        stepCalendarView(index: 1)
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        
    }
    //MARK: - Methods
    
    //Refresh page when Transaction/Category/Subcategory added or deleted
    @objc private func refresh() {
        tableView.reloadData()
        calendar.reloadData()
        getTotalAtDate(Date() + 61199)
        displaySelectedDate(Date())
    }
    
    private func stepCalendarView(index: Int) {
        let previousMonth = Calendar.current.date(byAdding: self.calendar.scope.asCalendarComponent(), value: index, to: calendar.currentPage)
        calendar.setCurrentPage(previousMonth!, animated: true)
    }
    
    func createAddButton() {
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

        let image = UIImage(systemName: "plus")!

        UIGraphicsBeginImageContextWithOptions(button.frame.size, false, image.scale)
        let rect  = CGRect(x: 0, y: 0, width: button.frame.size.width, height: button.frame.size.height)
        UIBezierPath(roundedRect: rect, cornerRadius: rect.width/2).addClip()
        image.draw(in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()


        let color = UIColor(rgb: Constants.blue)
        button.backgroundColor = color
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        let barButton = UIBarButtonItem()
        barButton.customView = button
        self.navigationItem.rightBarButtonItem = barButton
            
//            [addRightBarButtonWithImage(UIImage(named: "menu")!), UIBarButtonItem(customView: addButton)]
        
    }
    
    @objc func todayItemClicked(sender: AnyObject) {
        self.calendar.setCurrentPage(Date(), animated: false)
    }
    
    func getTotalAtDate(_ date: Date) {
        
        let transactionsTotalAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", date).sum(ofProperty: "transactionAmount")
        
        let formattedLabel = transactionsTotalAtDate.toCurrency()
        
        let mutableAttributedString = NSMutableAttributedString(string: formattedLabel)
        if let range = mutableAttributedString.string.range(of: #"(?<=.)(\d{2})$"#, options: .regularExpression) {
            mutableAttributedString.setAttributes([.font: UIFont.systemFont(ofSize: 40, weight: .ultraLight), .baselineOffset: 25],
                                                  range: NSRange(range, in: mutableAttributedString.string))
        }
        
        amountLabel.attributedText = mutableAttributedString
        
    }
    
    func formatDoubleToCurrencyString(from number: Double) -> String {
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        
        let formattedNumber = formatter.string(from: NSNumber(value: number))
        
        return formattedNumber!
        
    }
    
    func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM d, yyyy"
        
        let dateString = formatter.string(from: date)
        
        if dateString == formatter.string(from: Date()) {
            dateLabel.text = "Today"
        } else {
            dateLabel.text = dateString
        }
        
    }
    
    func predicateForDayFromDate(date: Date) -> NSPredicate {
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
    
    func negativeTransactionPredicate(date: Date) -> NSPredicate {
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
    
    func positiveTransactionPredicate(date: Date) -> NSPredicate {
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
    
    func positiveAndNegativeTransactionPredicate(date: Date) -> NSPredicate {
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
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@ && transactionAmount > 0 && transactionAmount < 0", argumentArray: [startDate!, endDate!])
    }
    
    func setupCategories() {
    
    if categories.count == 0 {
        
        //Show Badge
        tabBarController!.tabBar.items![2].badgeValue = "1"
        
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
        
        let foodCategory = Category()
        foodCategory.categoryName = "Food"
        foodCategory.categoryColor = 0xfed330
        
        foodCategory.subCategories.append(groceries)
        foodCategory.subCategories.append(restaurants)
        foodCategory.subCategories.append(bars)
        
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
        
        getTotalAtDate(Date() + 61199)
        
        dateRangePredicate = predicateForDayFromDate(date: Date())
        
        tableView.reloadData()
    }
    
    //MARK: - Calendar Methods
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        getTotalAtDate(date + 61199)
        
        displaySelectedDate(date)
        
        dateRangePredicate = predicateForDayFromDate(date: date)
        
        tableView.reloadData()
        
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
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        let incomeTransaction = realm.objects(Transaction.self).filter(positiveTransactionPredicate(date: date))
        
        let expenseTransaction = realm.objects(Transaction.self).filter(negativeTransactionPredicate(date: date))
        
        for _ in incomeTransaction {
            return [UIColor(rgb: Constants.green)]
        }
        for _ in expenseTransaction {
            return [UIColor(rgb: Constants.red)]
        }
        
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        cell.appearance.eventDefaultColor = UIColor(rgb: Constants.green)
        
        calendar.appearance.todayColor = UIColor(rgb: Constants.yellow)
        
        calendar.appearance.selectionColor = UIColor(rgb: Constants.blue)
        
    }
    
    
    
    //MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let transactionCount = transaction.filter(dateRangePredicate).count
        
        if transactionCount == 0 {
            transactionsLabel.text = "No transactions for this date."
        } else {
            transactionsLabel.text = "Transactions:"
        }
        return transactionCount
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryTableViewCell", for: indexPath) as! SummaryTableViewCell
        
        let transactions = realm.objects(Transaction.self).filter(dateRangePredicate)
        
        cell.descLabel.text = transactions[indexPath.row].transactionCategory?.categoryName
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        let amount = currencyFormatter.string(from: NSNumber(value: transactions[indexPath.row].transactionAmount))
        
        cell.amountLabel.text = amount
        
        if transactions[indexPath.row].transactionAmount > 0 {
            
            cell.amountLabel.textColor = UIColor(rgb: Constants.green)
        } else {
            cell.amountLabel.textColor = UIColor(rgb: Constants.red)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        
        let transactions = realm.objects(Transaction.self).filter(dateRangePredicate)[indexPath.row]
        
        vc.transaction = transactions
        
        present(vc, animated: true, completion: nil)
    }
    
    
}

extension FSCalendarScope {
    func asCalendarComponent() -> Calendar.Component {
        switch (self) {
        case .month: return .month
        case .week: return .weekOfYear
        }
     }
}
