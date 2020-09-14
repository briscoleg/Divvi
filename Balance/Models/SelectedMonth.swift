//
//  CurrentMonth.swift
//  Balance
//
//  Created by Bo on 9/10/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import Foundation

class MonthToAdjust {
    
    static var date = Date()
    
    init(date: Date) {
        MonthToAdjust.self.date = date
    }
    
    static func increaseDateByAMonth() {
        MonthToAdjust.date = Calendar.current.date(byAdding: .month, value: 1, to: MonthToAdjust.date)!
        print(MonthToAdjust.date)
    }
    static func decreaseDateByAMonth() {
        MonthToAdjust.date = Calendar.current.date(byAdding: .month, value: -1, to: MonthToAdjust.date)!
        print(MonthToAdjust.date)
    }
    
}
