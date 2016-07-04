//
//  AppDelegate.swift
//  Music
//
//  Created by Александр Хитёв on 7/17/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import SwiftyDropbox
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - var and let
    var mainAudioPlayer: AVAudioPlayer!
    let userDefault = NSUserDefaults.standardUserDefaults()
    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())

    
//    override func remoteControlReceivedWithEvent(event: UIEvent) {
//        if event.type == UIEventType.RemoteControl {
//            switch event.subtype {
//            case UIEventSubtype.RemoteControlPlay:
//                mainAudioPlayer.play()
//                break
//            case UIEventSubtype.RemoteControlPause:
//                mainAudioPlayer.pause()
//                break
//            default: break
//            }
//        }
//    }

//    func nextT() {
//        mainAudioPlayer.stop()
//        mainAudioPlayer.prepareToPlay()
//        mainAudioPlayer.play()
//    }
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let mainView = userDefault.valueForKey("mainView") as? String
//        print(mainView)
        var touchVC: UIViewController!
//        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        if mainView == nil {
            touchVC = storyboard.instantiateViewControllerWithIdentifier("mainTabBarController")
            
            // notification for spotlight first search

        } else {
            touchVC = storyboard.instantiateViewControllerWithIdentifier(mainView!)
        }
        
        Dropbox.setupWithAppKey("6945lo9r9ra71ys")
        
     
        self.window?.rootViewController = touchVC
        return true
    }
    
  
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .Success(let token):
                print("Success \(token)")
            case .Error(let authError, let descriptionError):
                print("Error \(authError), \(descriptionError)")
            }
        }
        return false
    }
    
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        print("continueUserActivity")
//        userDefault.setBool(true, forKey: "applicationDelegateOpen")
        if userActivity.activityType == CSSearchableItemActionType {
            print("CSSearchableItemActionType")
            if let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                userDefault.setValue(identifier, forKey: "spotlightIdentifier")
                userDefault.setBool(true, forKey: "spotlightBool")
                print(identifier)
                // it is for define whihc screnn will be loaded after spotlight search
                let mainView = userDefault.valueForKey("mainView") as? String
                
                if mainView == nil {
                let firstTable = storyboard.instantiateViewControllerWithIdentifier("mainTabBarController") as! UITabBarController
                firstTable.selectedIndex = 0
                self.window?.rootViewController = firstTable
                } else {
                    let firstTable = storyboard.instantiateViewControllerWithIdentifier(mainView!)
                    self.window?.rootViewController = firstTable
                }
                
                return true
            }
        }
        return false // false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Alexsander-Khitev.Music" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Music", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Music.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

}

