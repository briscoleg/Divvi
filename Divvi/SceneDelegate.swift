//
//  SceneDelegate.swift
//  Balance
//
//  Created by Bo on 6/22/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let userDefaults = UserDefaults()



    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        
        if userDefaults.value(forKey: "faceIDEnabled") == nil {
            userDefaults.setValue(false, forKey: "faceIDEnabled")
        }
        
        if userDefaults.value(forKey: "passcodeEnabled") == nil {
            userDefaults.setValue(false, forKey: "passcodeEnabled")
        }
        
//        if userDefaults.value(forKey: "passcode") == nil {
//            userDefaults.setValue("1233", forKey: "passcode")
//        }
                
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
        if userDefaults.value(forKey: "faceIDEnabled") as! Bool || userDefaults.value(forKey: "passcodeEnabled") as! Bool {
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let passcodeVC : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: PasscodeVC.identifier)
            window?.rootViewController = passcodeVC
            window?.makeKeyAndVisible()
        }
        
//        if window?.rootViewController is PasscodeVC {
//        } else {
//
//
//        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }

}

