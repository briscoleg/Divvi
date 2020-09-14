//
//  Data.swift
//  Balance
//
//  Created by Bo on 6/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import Foundation
import RealmSwift

class Transaction: Object {
    
//    @objc dynamic var transactionName = ""
    @objc dynamic var transactionDescription: String? = nil
    @objc dynamic var transactionAmount = 0.0
    @objc dynamic var transactionDate = Date()
    @objc dynamic var transactionCategory: Category? = nil
    @objc dynamic var repeatInterval = ""
    @objc dynamic var isCleared = false
    @objc dynamic var subCategoryName = ""
    @objc dynamic var transactionID = UUID().uuidString
    
    convenience init(theDate: Date) {
        self.init()
        self.transactionDate = theDate
    }
    
    override static func primaryKey() -> String? {
        return "transactionID"
    }
        
}


