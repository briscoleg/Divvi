//
//  SettingsItem.swift
//  Balance
//
//  Created by Bo LeGrand on 11/7/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class SettingsItem {

    var name: String
    var image: UIImage?

    init(
        name: String,
        image: UIImage? = nil
    ) {
        self.name = name
        self.image = image
    }
}
