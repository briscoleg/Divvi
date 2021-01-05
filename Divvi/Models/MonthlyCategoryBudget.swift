//
//  MonthlyCategoryBudget.swift
//  Divvi
//
//  Created by Bo LeGrand on 12/31/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import Foundation
import RealmSwift

class MonthlyCategoryBudget: Object {
    
    @objc dynamic var budgetCategory = ""
    @objc dynamic var budgetMonth = 12
    @objc dynamic var budgetYear = 2000
    @objc dynamic var monthlyBudgetAmount = 0.0
    
}
