//
//  StartingBalance.swift
//  Balance
//
//  Created by Bo LeGrand on 11/14/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import Foundation
import RealmSwift

class StartingBalance: Object {
    
    @objc dynamic var amount = 0.0
    @objc dynamic var name = "Starting Balance"
    @objc dynamic var date = Date()
    
}
