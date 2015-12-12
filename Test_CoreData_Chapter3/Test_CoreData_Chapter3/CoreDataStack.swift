//
//  CoreDataStack.swift
//  Test_CoreData_Chapter3
//
//  Created by lidongbo on 15/12/8.
//  Copyright © 2015年 lidongbo. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var context: NSManagedObjectContext
    var psc: NSPersistentStoreCoordinator
    var model: NSManagedObjectModel
    var store:NSPersistentStore?
//    
//    initWithConcurrencyType:() {
//    
//    }
    
    init(){
        //1 载入被管理的对象model从磁盘 到NSManagedObjectModel 对象,做了这些,就获得一个URL momd目录,其中包含编译后版本的.xcdatamodeld文件
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("Dog Walk", withExtension: "momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        //2 一旦初始化了NSManagedObjectModel,下一步就是创建NSPersistentStoreCoordinator.记住persistent store coordinator在持久化存储和NSManagedObjectModel的中间,初始化一个NSManagedObjectModel.
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        //3 创建context
//        context = NSManagedObjectContext()
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        
        //4 这种方式创建持久存储器是一个单核的,你不能直接创建它,相反the persistent store coordinator 交给你一个NSPersistentStore对象作为持久存储器,只需指定存储类型(NSSQLitStoreType),URL存储文件的位置和一些配置选项.
        let documentsURL = CoreDataStack.applicationDocumentsDirectory()
        let storeURL = documentsURL.URLByAppendingPathComponent("Dog Walk")
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            store = try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options) as NSPersistentStore
            if store == nil {
                abort()
            }
        } catch {
            print("获取持久存储错误")
        }

        
    }
    
    //用户沙盒的默认目录
    class func applicationDocumentsDirectory() ->NSURL {
        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
        
        return urls[0]
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("error: \(error)")
            }
        }
    }
        
        
        


    
}

