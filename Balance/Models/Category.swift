//
//  Budget.swift
//  Balance
//
//  Created by Bo on 8/4/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var categoryName = ""
    @objc dynamic var categoryColor = 0xa55eea
    var subCategories = List<SubCategory>()
    
}

class SubCategory: Object {
    
    @objc dynamic var subCategoryName = ""
    @objc dynamic var amountBudgeted = 0.0
    
}

//struct Category {
//
//    var name: String
//    var color: UIColor
//   var amountBudgeted: Double
//    var subCategories: [SubCategory]
//
//}
//
//struct SubCategory {
//    var name: String
//    var amountBudgeted: Double
//}
//
//let categories = [
//    Category(
//        name: "Income",
//        color: UIColor(rgb: Constants.green),
//        amountBudgeted: 0.00,
//        subCategories: [
//            SubCategory(name: "Paycheck", amountBudgeted: 0.00),
//            SubCategory(name: "Bonus", amountBudgeted: 0.00),
//            SubCategory(name: "Dividend", amountBudgeted: 0.00),
//            SubCategory(name: "Rental Income", amountBudgeted: 0.00),
//    ]),
//    Category(
//        name: "Housing",
//        color: UIColor(rgb: Constants.grey),
//        amountBudgeted: 0.00,
//        subCategories: [
//            SubCategory(name: "Mortgage", amountBudgeted: 0.00),
//            SubCategory(name: "Property Tax", amountBudgeted: 0.00),
//            SubCategory(name: "HOA Fees", amountBudgeted: 0.00),
//            SubCategory(name: "Household Repairs", amountBudgeted: 0.00),
//    ]),
//    Category(
//        name: "Transportation",
//        color: UIColor(rgb: Constants.red),
//        amountBudgeted: 0.00,
//        subCategories: [
//            SubCategory(name: "Car Payment", amountBudgeted: 0.00),
//            SubCategory(name: "Gas", amountBudgeted: 0.00),
//            SubCategory(name: "Car Repairs", amountBudgeted: 0.00),
//            SubCategory(name: "Registration", amountBudgeted: 0.00),
//    ]),
//    Category(
//        name: "Food",
//        color: UIColor(rgb: Constants.yellow),
//        amountBudgeted: 0.00,
//        subCategories: [
//            SubCategory(name: "Groceries", amountBudgeted: 0.00),
//            SubCategory(name: "Restaurants", amountBudgeted: 0.00),
//    ]),
//    Category(
//        name: "Utilities",
//        color: UIColor(rgb: Constants.blue),
//        amountBudgeted: 0.00,
//        subCategories: [
//            SubCategory(name: "Water", amountBudgeted: 0.00),
//            SubCategory(name: "Electricity", amountBudgeted: 0.00),
//    ]),
//    Category(
//        name: "Clothing",
//        color: UIColor(rgb: Constants.orange),
//        amountBudgeted: 0.00,
//        subCategories: [
//            SubCategory(name: "Essential Clothing", amountBudgeted: 0.00),
//            SubCategory(name: "Shoes", amountBudgeted: 0.00),
//    ]),
//    Category(
//        name: "Entertainment",
//        color: UIColor(rgb: Constants.purple),
//        amountBudgeted: 0.00,
//        subCategories: [
//            SubCategory(name: "Movies", amountBudgeted: 0.00),
//            SubCategory(name: "Shopping", amountBudgeted: 0.00),
//    ]),
//    Category(
//        name: "Insurance",
//        color: UIColor(rgb: Constants.pink),
//        amountBudgeted: 0.00,
//        subCategories: [
//            SubCategory(name: "Essential Clothing", amountBudgeted: 0.00),
//            SubCategory(name: "Shoes", amountBudgeted: 0.00),
//    ]),
//    Category(
//        name: "Savings",
//        color: UIColor(rgb: Constants.green),
//        amountBudgeted: 0.00,
//        subCategories: [
//            SubCategory(name: "Emergency Fund", amountBudgeted: 0.00),
//            SubCategory(name: "Car Fund", amountBudgeted: 0.00),
//    ]),
//    Category(
//        name: "Debt",
//        color: UIColor(rgb: Constants.red),
//        amountBudgeted: 0.00,
//        subCategories: [
//            SubCategory(name: "Credit Card Payment", amountBudgeted: 0.00),
//            SubCategory(name: "Loan Payment", amountBudgeted: 0.00),
//    ]),
//]






//
//let incomeCategory = Category(
//    name: "Income",
//    color: UIColor(rgb: Constants.green),
//    amount: 2500.00,
//    subCategories: [
//    SubCategory(name: "Paycheck", amount: 2000.0),
//    SubCategory(name: "Bonus", amount: 500.0)
//    ])
//
//let housingCategory = Category(
//name: "Housing",
//color: UIColor(rgb: Constants.grey),
//amount: 2500.00,
//subCategories: [
//SubCategory(name: "Mortgage", amount: 2000.0),
//SubCategory(name: "Property Tax", amount: 500.0)
//])




//let subCategories = [SubCategory(name: "Paycheck", amount: 2500.00)]


//enum Categ {
//    case income, housing, transportation, food, utilities, clothing, entertainment
//}
//
//enum IncomeSubCategory {
//    case paycheck, bonus, dividend
//}
//
//enum HousingSubCategory {
//    case mortgage, rent, propertyTax
//}
//
//    let mainCategories: [String] = [
//
//        "Income",
//        "Housing",
//        "Transport",
//        "Food",
//        "Utilities",
//        "Clothing",
//        "Entertainment",
//        "Insurance",
//        "Savings",
//        "Debt",
//        "Miscellaneous",
//        "Medical",
//        "Household",
//        "Giving",
//        "Travel",
//    ]
//
//    let incomeSubCategory: [String] = [
//
//        "Salary",
//        "Bonus",
//        "Rental Income"
//
//    ]
//
//    let housingSubCategory: [String] = [
//
//        "Mortgage/Rent",
//        "Property Tax",
//        "Homeowner's Insurance",
//
//    ]
//}
