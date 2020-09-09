//
//  TabBarController.swift
//  Balance
//
//  Created by Bo on 9/2/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var summaryVC: SummaryVC!
    var budgetVC: Budget2VC!
    var addTransactionVC: AddTransactionVC!
    var taskVC: TaskVC!
    var menuVC: MenuVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        summaryVC = SummaryVC()
        budgetVC = Budget2VC()
        addTransactionVC = AddTransactionVC()
        taskVC = TaskVC()
        menuVC = MenuVC()
        //
        //        summaryVC.tabBarItem.image = UIImage(named: "Calendar")
        //
        //        budgetVC.tabBarItem.image = UIImage(named: "planning")
        //
        //        addTransactionVC.tabBarItem.image = UIImage(systemName: "plus")
        //
        //        taskVC.tabBarItem.image = UIImage(named: "check")
        //
        //        menuVC.tabBarItem.image = UIImage(named: "menu")
        //
        //        viewControllers = [summaryVC, budgetVC, addTransactionVC, taskVC, menuVC]
        //
        //        for tabBarItem in tabBar.items! {
        //          tabBarItem.title = ""
        //            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        //        }
        
        
        
        //        let button = UIButton()
        //        button.setImage(UIImage(systemName: "plus"), for: .normal)
        //        button.sizeToFit()
        //        button.translatesAutoresizingMaskIntoConstraints = false
        //        button.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
        //        button.backgroundColor = UIColor(rgb: Constants.blue)
        //
        //        tabBar.addSubview(button)
        //        tabBar.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        //        tabBar.topAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        //        button.addTarget(self, action: #selector(addButtonTapped), for: UIControl.Event.touchUpInside)
        
        //        button.widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: 0.5).isActive = true
        //        button.heightAnchor.constraint(equalTo: parentView.heightAnchor, multiplier: 0.5).isActive = true
        //        button.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        //        button.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = true
        
        //        let widthContraints =  NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
        //        let heightContraints = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
        //        let xContraints = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        //        let yContraints = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        //        NSLayoutConstraint.activate([heightContraints,widthContraints,xContraints,yContraints])
    }
    
    @objc func addButtonTapped() {
        
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
