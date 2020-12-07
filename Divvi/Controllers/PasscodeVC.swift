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
            let reason = "Identify yourself"
            
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
        let passcode = Passcode()
        passcode.backgroundColor = .red
        passcode.frame = CGRect(x: 100, y: 100, width: 300, height: 44)
        passcode.becomeFirstResponder()
        passcode.didFinishedEnterCode = { [self] code in
        
            login()
            
        }
        view.addSubview(passcode)

    }
    
    @IBAction func retryButtonPressed(_ sender: UIButton) {
        
        faceIDAuthentication()
    }
    
}
