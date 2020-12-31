//
//  PasscodeVC.swift
//  Divvi
//
//  Created by Bo LeGrand on 12/6/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import LocalAuthentication

enum PasscodeView {
    case newPasscode
    case existingPasscode
}

enum NewPasscodeEntry {
    case first
    case second
}

class PasscodeVC: UIViewController {
    
    static let identifier = "PasscodeVC"
    
    private let tryAgainLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 21)
        label.textAlignment = .center
        label.text = "Try again"
        label.alpha = 0.0
        return label
    }()
    
    private let enterPasscodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        label.textAlignment = .center
        label.text = "Enter New Passcode"
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    private let retryFaceIDButton: UIButton = {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 30))

        button.setTitle("Retry Face ID", for: .normal)
        button.setTitleColor(UIColor(rgb: SystemColors.shared.blue), for: .normal)
        button.addTarget(self, action: #selector(retryFaceIDButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let passcode = Passcode()
    let userDefaults = UserDefaults()
    
    var passcodeView = PasscodeView.existingPasscode
    var newPasscodeEntry = NewPasscodeEntry.first
    
    var passcodeEntered = ""
        
    private func setupBiometricRetryButton() {
        
        let laContext = LAContext()
        
        switch laContext.biometryType {
        case .faceID:

            retryFaceIDButton.setTitle("Retry Face ID", for: .normal)
            print("Face")

        case .touchID:
            retryFaceIDButton.setTitle("Retry Touch ID", for: .normal)
            print("Touch")

        case .none:
            print("None")
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupBiometricRetryButton()
        
    }
    
    private func fadeTryAgainLabel() {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: { [self] in
            tryAgainLabel.alpha = 1.0
        }) { (finished) in
            if finished {
                UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseIn, animations: { [self] in
                    tryAgainLabel.alpha = 0.0
                }, completion: nil)
            }
        }
    }
    
    private func setupRetryFaceIDButton() {
        
        view.addSubview(retryFaceIDButton)

        retryFaceIDButton.center.x = view.center.x
        retryFaceIDButton.center.y = view.center.y + 60
    }
    
    private func setupTryAgainLabel() {
        

//        if laContext.biometryType == LABiometryType.faceID {
//            print("FaceID")
//        }
        
        view.addSubview(tryAgainLabel)
        tryAgainLabel.center.x = view.center.x
        tryAgainLabel.center.y = view.center.y - 100
        
    }
    
    private func setupEnterPasscodeLabel() {
        view.addSubview(enterPasscodeLabel)
        enterPasscodeLabel.center.x = view.center.x
        enterPasscodeLabel.center.y = view.center.y - 200
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
                        enterPasscodeLabel.text = "Enter Passcode or Retry"
                        setupEnterPasscodeLabel()
                    }
                }
            }
            
        } else {
            retryFaceIDButton.isHidden = true
        }
        
    }
    
    private func login() {
        //
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: TabBarController.identifier) as? TabBarController {
            
            UIApplication.shared.windows.first?.rootViewController = viewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        
        
    }
    
    private func handlePasscode(_ code: String) {
        
        if passcodeView == .newPasscode {
            
            if newPasscodeEntry == .first {
                
                passcodeEntered = code
                passcode.updateStack(by: "")
                passcode.code = ""
                newPasscodeEntry = .second
                enterPasscodeLabel.text = "Re-enter New Passcode"
            } else if newPasscodeEntry == .second {
                if code == passcodeEntered {
                    userDefaults.setValue(true, forKey: "passcodeEnabled")
                    userDefaults.setValue(code, forKey: "passcode")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "passcodeCreated"), object: nil)
                    dismiss(animated: true, completion: nil)
                } else {
                    newPasscodeEntry = .first
                    passcode.code = ""
                    passcode.updateStack(by: "")
                    enterPasscodeLabel.text = "Enter New Passcode"
                    tryAgainLabel.text = "Passcodes did not match"
                    
                    fadeTryAgainLabel()
                }
            }
        } else if passcodeView == .existingPasscode {
            
            if code == userDefaults.value(forKey: "passcode") as! String {
                login()
            } else {
                passcode.shake()
                fadeTryAgainLabel()
                passcode.updateStack(by: "")
                passcode.code = ""
            }
        }
    }
    
    private func setupUI() {
        
        setupTryAgainLabel()
        
        switch passcodeView {
        case .newPasscode:
            setupEnterPasscodeLabel()
        case .existingPasscode:
            
            setupRetryFaceIDButton()
            
            faceIDAuthentication()

        }
        
        passcode.frame = CGRect(x: 0, y: 0, width: view.frame.size.width / 1.5, height: 44)
        passcode.becomeFirstResponder()
        passcode.didFinishedEnterCode = { [self] code in
            
            handlePasscode(code)
            
        }
        view.addSubview(passcode)
        passcode.center.x = view.center.x
        passcode.center.y = view.center.y
        
    }
    
    @objc private func retryFaceIDButtonTapped() {
        faceIDAuthentication()

    }
    
}
