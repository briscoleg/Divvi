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
    
    @objc dynamic var transactionName: String = ""
    @objc dynamic var transactionDescription: String?
    @objc dynamic var transactionAmount: Double = 0.0
    @objc dynamic var transactionDate: Date = Date()
    
}

