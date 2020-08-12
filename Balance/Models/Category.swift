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
