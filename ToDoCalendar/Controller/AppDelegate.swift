//
//  AppDelegate.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/01/21.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
//        sleep(1)
        
        
        let storyboard:UIStoryboard = self.grabStoryboard()
//        var rootVC: UIViewController
        if let window = window{
                  window.rootViewController = storyboard.instantiateInitialViewController() as UIViewController?
               }
//        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()
        if Auth.auth().currentUser == nil{
            print("ユーザーなし")
        }
        // Override point for customization after application launch.
        
        return true
    }

    
    func grabStoryboard() -> UIStoryboard{
            
            var storyboard = UIStoryboard()
            let height = UIScreen.main.bounds.size.height
//            print("スクリーンサイズ: \(height)")
            if height == 568{
                storyboard = UIStoryboard(name: "iPhone8", bundle: nil)
                //iPhoneSE
            } else if height == 667 {
                storyboard = UIStoryboard(name: "iPhone8", bundle: nil)
                //iPhone8
            }else if height == 736 {
                storyboard = UIStoryboard(name: "iPhone6sPlus", bundle: nil)
                //iPhone8Plus
            }else if height == 812{
                storyboard = UIStoryboard(name: "Main", bundle: nil)
                //iPhoneX,XS,11Pro
            }else if height == 896{
                storyboard = UIStoryboard(name: "iPhone11", bundle: nil)
            }else{
                
                switch UIDevice.current.model {
                case "iPnone" :
                storyboard = UIStoryboard(name: "iPhone8", bundle: nil)
                    break
                case "iPad" :
                storyboard = UIStoryboard(name: "iPhone8", bundle: nil)
                print("iPad")
                    break
                default:
                    break
                }
            }
            return storyboard
    }
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
