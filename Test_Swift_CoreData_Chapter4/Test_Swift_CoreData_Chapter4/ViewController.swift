//
//  ViewController.swift
//  Test_Swift_CoreData_Chapter4
//
//  Created by lidongbo on 15/12/10.
//  Copyright © 2015年 lidongbo. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, FilterViewControllelerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var coreDataStack: CoreDataStack!
    
    var fetchRequest: NSFetchRequest!
    //当组织获取请求是异步的. 在tableView初始化中,它将要完成,但并未完成.tableView就会获取一个nil.app will crash.所以先将它初始化一个空数组.
    var venues: [Venue]! = []
    
    //iOS8 以后才出现的api
    var asyncFetchRequest: NSAsynchronousFetchRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let batchUpdate = NSBatchUpdateRequest(entityName: "Venue")
        batchUpdate.propertiesToUpdate = ["favorite" : NSNumber(bool: true)]
        batchUpdate.affectedStores = coreDataStack.psc.persistentStores
        batchUpdate.resultType = .UpdatedObjectsCountResultType
        
//        var batchResult: NSBatchUpdateResult?
        do {
            let batchResult = try coreDataStack.context.executeRequest(batchUpdate) as! NSBatchUpdateResult
            print("Records updated \(batchResult.result)")

        } catch let error as NSError {
            print("error: \(error.userInfo)")
        }
        

        
        
        
        
        
        
        
        
        
        
        
//        fetchRequest = coreDataStack.model.fetchRequestTemplateForName("FetchRequest")
//        fetchAndReload()
        //1 注意到一个异步的获取请求,不能替代正式的fetch request.你可以吧一个异步的获取请求当做一个已拥有请求的包装器
        fetchRequest = NSFetchRequest(entityName: "Venue")
        

        //2 创建一个异步请求,2步走. 一个是NSFetchRequest,另一个是完成后的处理.你获取的venue包含在NSAsynchronousFetchResult的finalFesult 属性中.在这个完成处理里.你可以更新venues属性,刷新tableView.
        asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest, completionBlock: { (result: NSAsynchronousFetchResult!) -> Void in
            self.venues = result.finalResult as! [Venue]
            self.tableView.reloadData()
        })
        
        //3 列举完成处理是不够的.你依然需要执行 asynchronous fetch request.再一次的 CoreDataStack的context属性为你处理繁重的工作. 然而, 值得注意,方法是不一样的. 原来的executeFetchRquest() 替换成 executeRequest()
        //executeRequest() 立即返回.你不需要做任何事情. 返回的类型是NSAsynchronousFetchRequest.
        var results: NSPersistentStoreResult?
        do {
            results = try coreDataStack.context.executeRequest(asyncFetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error.userInfo)")
        }
        
        if let persistentStoreResult = results {
            print(persistentStoreResult)
            
            //立即返回,如果你想取消.也在这里设置.
        }
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: tableView dataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VenueCell")! as UITableViewCell
        
        let venue = venues[indexPath.row]
        cell.textLabel!.text = venue.name;
        cell.detailTextLabel!.text = venue.priceInfo!.priceCategory
        return cell
    }
    
    
    
    //MARK: - helper methods
    
    //获取并载入数据
    func fetchAndReload() {
        var results: [Venue]?
        do {
            results = try coreDataStack.context.executeFetchRequest(fetchRequest) as? [Venue]
        } catch {
            print("获取数据并载入错误")
        }
        
        if let fetchedResults = results {
            venues = fetchedResults
        }
        
        tableView.reloadData()
        
    }
    
    
    //跳转
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toFilterViewController" {
            let navController = segue.destinationViewController as? UINavigationController
        if let filterVC = navController?.topViewController as? FilterViewControlelr {
            
            //add the line below
            filterVC.coreDataStack = coreDataStack
            filterVC.delegate = self
        }
        
        
        }
    }
    
    
    //MARK: - filter delegate
    
    func filterViewController(filter: FilterViewControlelr, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
        
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = nil
        
        if let fetchPredicate = predicate {
            fetchRequest.predicate = fetchPredicate
        }
        
        if let sr = sortDescriptor {
            fetchRequest.sortDescriptors = [sr]
        }
        
        fetchAndReload()
        
    }

}

