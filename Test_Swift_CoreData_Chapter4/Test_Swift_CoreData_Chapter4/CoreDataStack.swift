//
//  CoreDataStack.swift
//  Test_Swift_CoreData_Chapter4
//
//  Created by lidongbo on 15/12/10.
//  Copyright © 2015年 lidongbo. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    //管理对象上下文
    var context: NSManagedObjectContext
    //持久化存储协调者
    var psc: NSPersistentStoreCoordinator
    //管理对象model
    var model: NSManagedObjectModel
    //持久化存储
    var store: NSPersistentStore?
    
    //初始化
    init(){
        
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("Model", withExtension: "momd")
        
        //根据modelURL 获得管理对象model
        model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        //根据管理对象model获得持久存储协调者
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        //创建一个上下文.注意: 这货在iOS9以后就过时了,iOS9以后采用下面的初始化.
//        context = NSManagedObjectContext()
        //如果想改异步,就要替换这一句.
        //一个管理对象上下文能拥有这些类型中的一个.如果你不指定并发,那么默认值是.ConfinementConcurrencyType.
        //异步获取并不能在限制并发类型中工作.所以你得指定为类型为.MainQueueConcurrencyType
        //第三个并发类型是.PrivateQueueConcurrencyType 你可以在第十章学习.
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        //指定上下文的协调者为psc
        context.persistentStoreCoordinator = psc
        
        //获取沙盒默认路径
        let documentsURL = CoreDataStack.applicationDocumentsDirectory()
        let storeURL = documentsURL.URLByAppendingPathComponent("Bubble_Tea_Finder")
        
        //支持版本自动迁移,这货是个字典组成的数组
        let options = [NSMigratePersistentStoresAutomaticallyOption:true]
        
        do {
            store = try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options) as NSPersistentStore
//            if store == nil {
//                abort()
//            }
        } catch let error as NSError {
            print("持久化存储错误: \(error.userInfo)")
            abort()
        }
        
    }
    
    
    //获取沙盒路径(类方法)
    class func applicationDocumentsDirectory() ->NSURL {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
        return urls[0]
    }
    
    
    //保存
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError{
                print("Could not save: \(error.userInfo)")
            }
        }
    }
    
    
}


