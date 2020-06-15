//
//  SceneDelegate.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/01/21.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let storyboard:UIStoryboard = self.grabStoryboard()
               
        if let window = window{
                  window.rootViewController = storyboard.instantiateInitialViewController() as UIViewController?
               }
          self.window?.makeKeyAndVisible()
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func grabStoryboard() -> UIStoryboard{
            
            var storyboard = UIStoryboard()
            let height = UIScreen.main.bounds.size.height
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
            }else if height == 896{
                storyboard = UIStoryboard(name: "iPhone11", bundle: nil)
            }else{
                
                switch UIDevice.current.model {
                case "iPnone" :
                storyboard = UIStoryboard(name: "se", bundle: nil)
                    break
                case "iPad" :
                storyboard = UIStoryboard(name: "iPad", bundle: nil)
                print("iPad")
                    break
                default:
                    break
                }
            }
            return storyboard
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

