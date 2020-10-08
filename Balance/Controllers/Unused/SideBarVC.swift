//
//  SideBarVC.swift
//  Balance
//
//  Created by Bo on 8/20/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SideBarCell"

class SideBarVC: UICollectionViewController {
    
    let items = ["Overview", "Search", "Planning"]
    let images = [
        UIImage(systemName: "calendar"),
        UIImage(systemName: "magnifyingglass"),
        UIImage(named: "planning")
    
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide Navigation Bar
//        SideMenuManager.default.menuFadeStatusBar = false
        
        navigationController?.setNavigationBarHidden(true, animated: false)
//        navigationController?.navigationBar.barTintColor = UIColor.systemBackground
//        navigationController!.navigationBar.setValue(true, forKey: "hidesShadow")
//        navigationController?.navigationBar.isTranslucent = false

       let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)

        layout.itemSize = CGSize(width: 300, height: 60)

        layout.minimumInteritemSpacing = 0

        layout.minimumLineSpacing = 0

        collectionView.collectionViewLayout = layout
        
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController

        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }

        return topMostViewController
    }

    
//    @IBAction func eventsAction(_ sender: Any) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventsVC") as! SummaryVC
//        //let navigationController = UINavigationController(rootViewController: vc)
//        //self.present(navigationController, animated: true, completion: nil)
//        self.window?
//        self.sideMenuController?.hideLeftViewAnimated()
//        self.sideMenuController?.rootViewController?.show(vc, sender: self)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.item {
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryVC
            dismiss(animated: false, completion: nil)
            present(vc, animated: false)
        
            
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "TaskVC") as! TaskVC
            dismiss(animated: false, completion: nil)
//            presentingViewController = (presentingViewController as? UITabBarController)?.selectedViewController as? UINavigationController
            show(vc, sender: self)
//
            
            

        case 2:
//            let vc = storyboard?.instantiateViewController(withIdentifier: "BudgetVC") as! BudgetVC
            dismiss(animated: false, completion: nil)

//            show(vc, sender: self)

        default:
            print("Error presenting view controller")
        }
        
            
            
                    
    }
 

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SideBarCell
    
        cell.viewControllerLabel.text = items[indexPath.item]
        cell.viewControllerImage.image = images[indexPath.item]
    
        return cell
    }
    


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
