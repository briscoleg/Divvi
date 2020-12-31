//
//  TransactionDay.swift
//  Divvi
//
//  Created by Bo LeGrand on 12/8/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import Foundation
import RealmSwift

enum TransactionDayInterval: String {
    case yearly
    case monthly
    case everyTwoWeeks
    case weekly
    case daily
    case never
}


class TransactionDay: Object {
    
    @objc dynamic var date = Date().day
    @objc dynamic var month = Date().month
    @objc dynamic var amount = 0.0
    @objc dynamic var name = ""
    @objc dynamic var repeatInterval = TransactionDayInterval.never.rawValue
    
}
