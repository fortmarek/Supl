//
//  AppDelegate.swift
//  Supl
//
//  Created by Marek Fořt on 11.08.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NotificationsDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "askedPermission") {
            registerForPushNotifications()
        }
        
        if defaults.string(forKey: "userId") == nil {
            guard let userId = UIDevice.current.identifierForVendor else {return true}
            let id = userId.uuidString
            defaults.setValue(id, forKey: "userId")
            let _ = Alamofire.request("http://139.59.144.155/users/\(id)", method: .post)
        }
        
        //Fix for notifications - 2.1.3
        if defaults.bool(forKey: "doesNotNeedFix") == false && UIApplication.shared.isRegisteredForRemoteNotifications {
            registerForPushNotifications()
            defaults.set(true, forKey: "doesNotNeedFix")
        }
        
        //Fix for duplicating properties in dataabse - 2.1.4
        if defaults.bool(forKey: "updateValuesNeeded") == false {
            let dataController = DataController()
            if let clas = defaults.string(forKey: "class"),
                let school = defaults.string(forKey: "schoolUrl") {
            dataController.postSchool(school, completion: {
                result in
                if result == "Povedlo se" {
                    defaults.set(true, forKey: "isUrlRight")
                    dataController.postProperty(clas, school: school)
                }
                else {
                    defaults.set(false, forKey: "isUrlRight")
                }
                })
            }
            
            defaults.set(true, forKey: "updateValuesNeeded")
        }
        
        // TODO: Delete properties (in case of reinstalling)
        //MARK: Walkthrough
        
        if defaults.bool(forKey: "wasOpened") == false {
        
            if defaults.value(forKey: "schoolUrl") == nil && defaults.value(forKey: "class") == nil {
                
                let storyboard = UIStoryboard(name: "Walkthrough", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ContainerVC")
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate

                appDelegate.window?.rootViewController = vc
            }
            defaults.set(true, forKey: "wasOpened")
            //defaults.setBool(false, forKey: "wasOpened")
        }
        
        
        
        return true
    }
    

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Convert token data to string
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        self.postToken(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "marekfort.Supl" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Supl", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

