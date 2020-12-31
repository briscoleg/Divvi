//
//  SettingsVC.swift
//  Balance
//
//  Created by Bo LeGrand on 10/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift
import LocalAuthentication

class SettingsVC: UIViewController {
    
    static let identifier = "SettingsVC"
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    private var settingsItems = [SettingsItem]()
    
    private let userDefaults = UserDefaults()
    
    private var scrollDirection: String {
        userDefaults.value(forKey: "calendarScrollDirection") as! String
    }
    
    var faceIDString = ""
    var securityType = ""
        
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegates()
        configureSettingsItems()
        configureCollectionViewLayout()
//        determineSecurityType()
        


    }
    
    //MARK: - Methods
    private func setDelegates() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc private func refresh() {
        configureSettingsItems()
    }
    
    private func configureCollectionViewLayout() {
        
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        
    }
    
    private func presentPasscodeVC() {
        if let vc = storyboard?.instantiateViewController(identifier: PasscodeVC.identifier) as? PasscodeVC {
            vc.passcodeView = .newPasscode
            vc.modalPresentationStyle = .currentContext
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func determineSecurityType() {
        
        let currentType = LAContext().biometricType
        
        switch currentType {
        case .faceID:
            securityType = "Face ID / Password"
            print("FaceID")
        case .touchID:
            securityType = "Touch ID / Password"
            print("TouchID")
        case .none:
            securityType = "Password"
            print("Password")
        }
    }
    
    private func faceID() {
        
        let context = LAContext()
        var error : NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        userDefaults.setValue(true, forKey: "faceIDEnabled")
                        presentPasscodeVC()
                        configureSettingsItems()
                    } else {

                    }
                }
            }
        } else {
            presentPasscodeVC()
            NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "passcodeCreated"), object: nil)
//            configureSettingsItems()

        }
    }
    
    private func configureSettingsItems() {
        
        determineSecurityType()

        if userDefaults.value(forKey: "faceIDEnabled") as! Bool || userDefaults.value(forKey: "passcodeEnabled") as! Bool {
            faceIDString = "Disable \(securityType)"
        } else {
            faceIDString = "Set Up \(securityType)"
        }
        
        settingsItems.removeAll()

        let names = [
            "About",
            "Calendar Swipe: \(scrollDirection.capitalized)",
            "\(faceIDString)",
            "Reset Starting Balance",
            "Delete All Transactions",
        ]
        for name in names {
            
            settingsItems.append(SettingsItem(name: name))
        }
        collectionView.reloadData()
    }
    
}

//MARK: - CollectionView Delegate
extension SettingsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingsItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCell.identifier, for: indexPath) as? SettingsCell else { return UICollectionViewCell() }
        
//        cell.configure(with: indexPath)

        cell.nameLabel.text = settingsItems[indexPath.item].name
        
        cell.customView.backgroundColor = UIColor(rgb: SystemColors.shared.blue)
        cell.nameLabel.textColor = .white
        
        switch indexPath.item {
        case 4:
            cell.customView.backgroundColor = UIColor(rgb: SystemColors.shared.red)
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.item {
        case 0:
            if let vc = storyboard?.instantiateViewController(identifier: "AboutVC") {
                vc.modalPresentationStyle = .currentContext
                present(vc, animated: true, completion: nil)

            }

        case 1:
            
            var changeDirectionTo = ""
            
            if scrollDirection == "horizontal" {
                changeDirectionTo = "vertical"
            } else if scrollDirection == "vertical" {
                changeDirectionTo = "horizontal"
            }
            
            let alert = UIAlertController(title: "Change calendar swipe direction to \(changeDirectionTo)?", message: "", preferredStyle: .actionSheet)
            
            let action = UIAlertAction(title: "Change To: \(changeDirectionTo.capitalized)", style: .default) { [self] (action) in
                
                if userDefaults.value(forKey: "calendarScrollDirection") as! String == "horizontal" {
                    userDefaults.setValue("vertical", forKey: "calendarScrollDirection")
                } else if userDefaults.value(forKey: "calendarScrollDirection") as! String == "vertical" {
                    userDefaults.setValue("horizontal", forKey: "calendarScrollDirection")
                    }
                configureSettingsItems()
                collectionView.reloadData()
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "calendarScrollDirectionChanged")))
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            
        case 2:
            
            determineSecurityType()
            
            if userDefaults.value(forKey: "faceIDEnabled") as! Bool == false && userDefaults.value(forKey: "passcodeEnabled") as! Bool == false {
                
                let alert = UIAlertController(title: "Enable \(securityType)?", message: "", preferredStyle: .actionSheet)
                
                let action = UIAlertAction(title: "Enable", style: .default) { [self] (action) in
                    
                    faceID()
                    
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
                }
                
                alert.addAction(action)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertController(title: "Disable \(securityType)?", message: "", preferredStyle: .actionSheet)
                
                let action = UIAlertAction(title: "Disable", style: .default) { [self] (action) in

                    userDefaults.setValue(false, forKey: "faceIDEnabled")
                    userDefaults.setValue(false, forKey: "passcodeEnabled")

                    configureSettingsItems()
                    print(userDefaults.value(forKey: "passcodeEnabled"))
                    print(userDefaults.value(forKey: "faceIDEnabled"))
                    
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
                }
                
                alert.addAction(action)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
                
            }
            
        case 3:
            
            let alert = UIAlertController(title: "Are you sure you want to reset your starting balance?", message: "", preferredStyle: .actionSheet)
            
            let action = UIAlertAction(title: "Reset Starting Balance", style: .destructive) { [self] (action) in
                
                let realm = try! Realm()
                let startingBalance = realm.objects(StartingBalance.self)
                do {
                    try realm.write {
                        realm.delete(startingBalance)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
                    }
                } catch {
                    print("Error deleting starting balance: \(error)")
                }
                let userDefaults = UserDefaults()
                userDefaults.setValue(false, forKey: "startingBalanceSet")
                if let vc = storyboard?.instantiateViewController(identifier: StartingBalanceVC.identifier) {
                    present(vc, animated: true, completion: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
                print("Cancel Tapped")
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            
        case 4:
            let alert = UIAlertController(title: "Are you sure you want to delete all transactions?", message: "", preferredStyle: .actionSheet)
            
            let action = UIAlertAction(title: "Delete All Transactions", style: .destructive) { (action) in
                
                let realm = try! Realm()
                let allTransactions = realm.objects(Transaction.self)
                do {
                    try realm.write {
                        realm.delete(allTransactions)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
                    }
                } catch {
                    print("Error deleting all transactions: \(error)")
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
                print("Cancel Tapped")
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        default:
            break
            
        }
    }
}

extension SettingsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 1.2, height: UIScreen.main.bounds.width / 5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
