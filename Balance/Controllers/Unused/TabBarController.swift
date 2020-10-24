//
//  TabBarController.swift
//  Balance
//
//  Created by Bo on 9/2/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
//    var summaryVC: SummaryVC!
//    var budgetVC: Budget2VC!
    var addTransactionVC: AddTransactionVC!
//    var taskVC: TaskVC!
//    var menuVC: MenuVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
//        summaryVC = SummaryVC()
//        budgetVC = Budget2VC()
        addTransactionVC = AddTransactionVC()
//        taskVC = TaskVC()
//        menuVC = MenuVC()
        configureTabBar()
        
    }
    
    func configureTabBar() {
        let appearance = tabBarController?.tabBar.standardAppearance
        
        appearance?.backgroundColor = .white
        appearance?.shadowImage = nil
        appearance?.shadowColor = nil
        tabBarController?.tabBar.isTranslucent = true
        tabBarController?.tabBar.standardAppearance = appearance!
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: AddTransactionVC.self) {
            if let vc =  storyboard?.instantiateViewController(identifier: "AddTransactionVC") {
                vc.modalPresentationStyle = .formSheet
                self.present(vc, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
}
