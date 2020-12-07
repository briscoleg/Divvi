//
//  TabBarController.swift
//  Balance
//
//  Created by Bo on 9/2/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    static let identifier = "TabBarController"
    
//    var summaryVC: SummaryVC!
//    var budgetVC: Budget2VC!
    var addTransactionVC: AddTransactionVC!
    var startingBalanceVC: StartingBalanceVC!
    
    let userDefaults = UserDefaults()
//    var taskVC: TaskVC!
//    var menuVC: MenuVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
//        summaryVC = SummaryVC()
//        budgetVC = Budget2VC()
        addTransactionVC = AddTransactionVC()
        startingBalanceVC = StartingBalanceVC()
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
        
        switch userDefaults.bool(forKey: "startingBalanceSet") {
        case false:
            if viewController.isKind(of: AddTransactionVC.self) {
                if let vc = storyboard?.instantiateViewController(identifier: StartingBalanceVC.identifier) {
                    vc.modalPresentationStyle = .formSheet
                    present(vc, animated: true, completion: nil)
                    print("StartingBalanceVC")

                    return false
                }
            }
        case true:
            if viewController.isKind(of: AddTransactionVC.self) {
                if let vc =  storyboard?.instantiateViewController(identifier: AddTransactionVC.identifier) {
                    vc.modalPresentationStyle = .formSheet
                    present(vc, animated: true, completion: nil)
                    navigationController?.navigationBar.barTintColor = UIColor.green
                    print("AddTransactionVC")
                    return false
                    
                }
            }
        }
        return true
    }
}
