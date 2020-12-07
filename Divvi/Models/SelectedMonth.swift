//
//  CurrentMonth.swift
//  Balance
//
//  Created by Bo on 9/10/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import Foundation

import Foundation

class SelectedMonth {
    
    static let shared = SelectedMonth()

    var date: Date
    
    init(_ date: Date = Date()) {
        self.date = date
    }
    
    func increaseDateByAMonth() {
        date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
    }
    func decreaseDateByAMonth() {
        date = Calendar.current.date(byAdding: .month, value: -1, to: self.date)!
    }
    func selectedMonthPredicate() -> NSPredicate {
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)

        let components = calendar.dateComponents([.year, .month], from: SelectedMonth.shared.date)
        
        let startOfMonth = calendar.date(from: components)
        
        var comps2 = DateComponents()
        
        comps2.month = 1
        comps2.day = -1
        
        let endOfMonth = calendar.date(byAdding: comps2, to: startOfMonth!)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startOfMonth!, endOfMonth!])
        
    }
}
