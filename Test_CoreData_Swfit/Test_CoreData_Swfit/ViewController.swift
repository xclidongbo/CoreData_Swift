//
//  ViewController.swift
//  Test_CoreData_Swfit
//
//  Created by lidongbo on 15/12/5.
//  Copyright © 2015年 lidongbo. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    //在tableView变量下创建一个数组
//    var names = [String]()
    //改用其他数据源
    var people = [NSManagedObject]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "\"The List\""
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        1
        /*
            获取管理对象上下文
        */
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //2
        /*
            和名字的提示一样. NSFetchRequest 是 一个从CoreData获取数据的类响应.
            获取请求和是灵活和强大的. 能使用请求去获取一个特定条件的集合.
        获取请求有一些限定词,可以定义返回结果的集合. 你将在第四章学到. 现在你应该知道NSEntityDescription是限定的一种.
        
        
        */
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        //3
        /*
            交出获取请求到管理对象上下文.做重要的提高.
            返回一个补丁的array
        */
        var fetchedResults:[NSManagedObject]?
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch let error as NSError {
            print("Error:\(error.localizedDescription)")
        }
        
        if let results = fetchedResults {
            people = results
        } else {
            print("Could not fetch result")
        }
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//MARK: - tableView dataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return names.count
        return people.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
//        cell.textLabel!.text = names[indexPath.row]
        let person = people[indexPath.row]
        cell.textLabel!.text = person.valueForKey("name") as! String?
        return cell
    }
    
//MARK: - barbutton action
    @IBAction func addName(sender: UIBarButtonItem) {
        var alert = UIAlertController(title: "New name", message: "Add a new name", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (UIAlertAction) -> Void in
            let textField = alert.textFields![0] as UITextField
//            self.names.append(textField.text!)
            self.saveName(textField.text!)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (UIAlertAction) -> Void in
            
        }
        alert.addTextFieldWithConfigurationHandler { (UITextField) -> Void in
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true) { () -> Void in
        }
        
        
    }
    
    func saveName(name: String) {
        //1
        /*
            在你保存和检索东西的时候,首先需要在NSManagedObjectContext实例上获得传递.你可以想象上下文在内存中作为一个中间结果管理器来管理对象.
            想象保存一个新的管理对象 需要2步: 1 插入一个新的被管理的对象在管理对象上下文中.
                                        2 确认无误后,需要提交改变,通过上下文保存到磁盘中.
            xcode 已经提供了一个管理对象上下文.在工程里.要使用它,你首先获取app的delegate
        */
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //2
        /*
            创建一个管理对象,并且插入到管理对象上下文中,你可以一步完成,采用NSManagedObject的直接初始化,init(entity:insertIntoManagedObjectContext:).
            一个实体描述是一块 连接数据model的实体定义和   在运行时 一个 nsmanagedObject的一个例子
        */
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        //3
        /*
            在一个 NSManagedObject 进行中,你可以使用kvc设置属性名字.必须有这个key.否则引起crash
        */
        person.setValue(name, forKey: "name")
        
        //4
//        var error: NSError?
//        if !managedContext.save(){
//            print("Could not save \(error), \(error?.userInfo)")
//        }
        //Swift2.0 的错误处理.
        /*
            commit 你的改变 并且通过访问管理对象上下文,保存到磁盘.
        */
        do {
            try managedContext.save()
        } catch {
            print("Save error")
        }
        
        //5 插入新的管理对象到people 数组.
        people.append(person)
        
        
    }
}

