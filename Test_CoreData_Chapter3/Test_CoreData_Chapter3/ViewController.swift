//
//  ViewController.swift
//  Test_CoreData_Chapter3
//
//  Created by lidongbo on 15/12/8.
//  Copyright © 2015年 lidongbo. All rights reserved.
//

import UIKit

import CoreData

class ViewController: UIViewController, UITableViewDataSource {
    
    var managedContext:NSManagedObjectContext!
    
    var currentDog: Dog?
    
    @IBOutlet weak var tableView: UITableView!
    
    let identifier = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: identifier)
        

        
        let dogEntity = NSEntityDescription.entityForName("Dog", inManagedObjectContext: managedContext)
        
        let dog = Dog(entity: dogEntity!, insertIntoManagedObjectContext: managedContext)
        
        let dogName = "Fido"
        let dogFetch = NSFetchRequest(entityName: "Dog")
        dogFetch.predicate = NSPredicate(format: "name == %@", dogName)
        
        var results:[Dog]?
        do {
            results = try managedContext.executeFetchRequest(dogFetch) as? [Dog]
        } catch let error as NSError{
            print("查询失败: \(error.userInfo)")
        }
        
        if let dogs = results {
            if dogs.count == 0 {
                currentDog = Dog(entity: dogEntity!, insertIntoManagedObjectContext: managedContext)
                currentDog!.name = dogName
                
                do {
                    try managedContext.save()
                } catch {
                    print("保存失败")
                }
                
            } else {
                currentDog = dogs[0]
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:  tableView dataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        if let dog = currentDog {
            numRows = dog.walks!.count
        }
        return numRows
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .MediumStyle
        
        let walk = currentDog?.walks![indexPath.row] as! Walk
        cell.textLabel!.text = dateFormatter.stringFromDate(walk.date!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List of Walks"
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            //1 获取要删除的walk的引用
            let walkToRemove = currentDog?.walks![indexPath.row] as! Walk
            
            //2 删除一个CoreData 对象和添加一个一样复杂. 首先,你创建一个 NSOrderedSet的 mutableCopy ,移除拷贝后的 walk. 然后将这个新的copy赋值给当前选择的dog
            let walks = currentDog?.walks?.mutableCopy() as! NSMutableOrderedSet
            walks.removeObjectAtIndex(indexPath.row)
            currentDog?.walks = walks.copy() as? NSOrderedSet
            
            //3 你已经从walks列表中移除the walk,但是the walk还在徘徊. 所以调用deleteObject方法.
            managedContext.deleteObject(walkToRemove)
            
            //4 注意: delete 并不能删除,只是标记. 真正做保存操作的还是save()
            do {
                try managedContext.save()
            } catch {
                print("删除失败")
            }
            
            //5 添加删除动画.
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        }
    }
    

    //MARK: action
    @IBAction func add(sender: UIBarButtonItem) {
        
        //Insert new Walk entity into Core Data
        let walkEntity = NSEntityDescription.entityForName("Walk", inManagedObjectContext: managedContext)
        
        
        let walk = Walk(entity: walkEntity!, insertIntoManagedObjectContext: managedContext)
        
        walk.date = NSDate()
        //Insert the new walk into the dog's walk set
        var walks = currentDog?.walks?.mutableCopy() as! NSMutableOrderedSet
        
        walks.addObject(walk)
        
        currentDog!.walks = walks.copy() as! NSOrderedSet
        
        do {
            try  managedContext.save()
        } catch {
            print("保存失败.....")
        }
        
        
        tableView.reloadData()
        
        
        
    }
}

