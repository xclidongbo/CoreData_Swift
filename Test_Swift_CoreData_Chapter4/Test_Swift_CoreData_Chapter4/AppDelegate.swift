//
//  AppDelegate.swift
//  Test_Swift_CoreData_Chapter4
//
//  Created by lidongbo on 15/12/10.
//  Copyright © 2015年 lidongbo. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        importJSONSeedDataIfNeeded()
        
        let navController = window!.rootViewController as! UINavigationController
        let viewController = navController.topViewController as! ViewController
        viewController.coreDataStack = coreDataStack
        
        
        
        return true
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
        coreDataStack.saveContext()
    }
    
    //引入json数据
    func importJSONSeedDataIfNeeded() {
        let fetchRequest = NSFetchRequest(entityName: "Venue")
        var error: NSError?

        let resultCount = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        
        if (resultCount == 0) {
            var fetchError: NSError
            var results:[Venue]?
            do {
                results = try coreDataStack.context.executeFetchRequest(fetchRequest) as? [Venue]
            } catch let error as NSError {
                print("\(error.userInfo)")
            }
            
            for object in results! {
                let team = object as Venue
                coreDataStack.context.deleteObject(team)
            }
            
            coreDataStack.saveContext()
            
            importJSONSeedData()
            
        }

        
    }
    
    //引入seed.json文件
    func importJSONSeedData() {
        let  jsonURL = NSBundle.mainBundle().URLForResource("seed", withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL!)
        
        var jsonDict: NSDictionary?
        do {
            jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: .MutableContainers) as? NSDictionary
        } catch let error as NSError {
            print("\(error.userInfo)")
        }
        
        let venueEntity = NSEntityDescription.entityForName("Venue", inManagedObjectContext: coreDataStack.context)
        let locationEntity = NSEntityDescription.entityForName("Location", inManagedObjectContext: coreDataStack.context)
        let categoryEntity = NSEntityDescription.entityForName("Category", inManagedObjectContext: coreDataStack.context)
        let priceEntity = NSEntityDescription.entityForName("PriceInfo", inManagedObjectContext: coreDataStack.context)
        let statsEntity = NSEntityDescription.entityForName("Stats", inManagedObjectContext: coreDataStack.context)
        
        let jsonArray = jsonDict!.valueForKeyPath("response.venues") as! NSArray
        
        for jsonDictionary in jsonArray {
            let venueName = jsonDictionary["name"] as? String
            let venuePhone = jsonDictionary.valueForKeyPath("contact.phone") as? String
            let specialCount = jsonDictionary.valueForKeyPath("specials.count") as? NSNumber
            
            
            let locationDict = jsonDictionary["location"] as? NSDictionary
            let priceDict = jsonDictionary["price"] as? NSDictionary
            let statsDict = jsonDictionary["stats"] as? NSDictionary
            
            let location = Location(entity: locationEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            location.address = locationDict!["address"] as? String
            location.city = locationDict!["city"] as? String
            location.state = locationDict!["state"] as? String
            location.zipcode = locationDict!["postalCode"] as? String
            location.distance = locationDict!["distance"] as? NSNumber
            
            let category = Category(entity: categoryEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            
            let priceInfo = PriceInfo(entity: priceEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            priceInfo.priceCategory = priceDict!["currency"] as? String
            
            let stats = Stats(entity: statsEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            stats.checkinsCount = statsDict!["checkinsCount"] as? NSNumber
            stats.usersCount = statsDict!["userCount"] as? NSNumber
            stats.tipCount = statsDict!["tipCount"] as? NSNumber
            
            let venue = Venue(entity: venueEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            venue.name = venueName
            venue.phone = venuePhone
            venue.specialCount = specialCount
            venue.location = location
            venue.category = category
            venue.priceInfo = priceInfo
            venue.stats = stats
            
            
        }
        coreDataStack.saveContext()
        
        
    }


}

