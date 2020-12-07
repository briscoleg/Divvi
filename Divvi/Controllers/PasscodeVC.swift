//
//  PasscodeVC.swift
//  Divvi
//
//  Created by Bo LeGrand on 12/6/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import LocalAuthentication


class PasscodeVC: UIViewController {
    
    static let identifier = "PasscodeVC"

    @IBOutlet weak var retryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        faceIDAuthentication()

    }
    
    private func faceIDAuthentication() {
        
        let context = LAContext()
        var error : NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [self
            ] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        login()
                    } else {
                        print("Could not authenticate")
                    }
                }
            }
            
        } else {
            print("No biometrics")
        }
        
    }
    
    private func login() {
//
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: TabBarController.identifier) as! TabBarController
        
            UIApplication.shared.windows.first?.rootViewController = viewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        
    }
    
    private func setupUI() {
        
        retryButton.center.x = view.center.x
        retryButton.center.y = view.center.y + 60
        retryButton.tintColor = UIColor(rgb: SystemColors.shared.blue)
        
        let passcode = Passcode()
        passcode.backgroundColor = .red
        passcode.frame = CGRect(x: 0, y: 0, width: view.frame.size.width / 1.5, height: 44)
        passcode.becomeFirstResponder()
        passcode.didFinishedEnterCode = { [self] code in
        
            login()
            
        }
        view.addSubview(passcode)
        passcode.center.x = view.center.x
        passcode.center.y = view.center.y

    }
    
    @IBAction func retryButtonPressed(_ sender: UIButton) {
        faceIDAuthentication()
    }
    
}
