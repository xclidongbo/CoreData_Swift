//
//  ViewController.swift
//  Test_CoreData_Chapter2
//
//  Created by lidongbo on 15/12/7.
//  Copyright © 2015年 lidongbo. All rights reserved.
//

import UIKit

import CoreData

class ViewController: UIViewController {

    var managedContext: NSManagedObjectContext!
    
    var currentBowtie: Bowtie!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var timesWornLabel: UILabel!
    
    @IBOutlet weak var lastWornLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //1 插入plist文件中的相同数据
        insertSampleData()
        
        //2 创建一个 fetch 请求,目的是请求新插入的数据. segmented Control 需要配置颜色, 所以谓词添加状态根据所选颜色来找到蝴蝶结.特定的谓词是查找蝴蝶结,根据searchKey 查找.
        let request = NSFetchRequest(entityName: "Bowtie")
        let firstTitle = segmentedControl.titleForSegmentAtIndex(0)
        
        request.predicate = NSPredicate(format: "searchKey == %@", firstTitle!)
        
        //3 通常, 管理上下文精巧的执行操作,并会结果数组
        var results: [Bowtie]?
        do {
            results = try managedContext.executeFetchRequest(request) as? [Bowtie]
        } catch let error as NSError {
            print(error)
        }
        
        //4 在结果数组中,使用第一个玲姐,填充用户界面.
        if let bowties = results {
            currentBowtie = bowties[0]
            populate(currentBowtie)

        } else {
            print("Could not fetch")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Custom method
    /**
    展示数据
    
    - parameter bowtie:
    */
    func populate(bowtie:Bowtie) {
        imageView.image = UIImage(data: bowtie.photoData!)
        nameLabel.text = bowtie.name
        ratingLabel.text = "Rating: \(bowtie.rating!.doubleValue)/5"
        timesWornLabel.text = "# times worn: \(bowtie.timesWorn!.integerValue)"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        lastWornLabel.text = "Last worn : " + dateFormatter.stringFromDate(bowtie.lastWorn!)
        
        
    }
    
    
    //MARK: - Core Data
    func insertSampleData(){
        let fetchRequest = NSFetchRequest(entityName: "Bowtie")
        fetchRequest.predicate = NSPredicate(format: "searchKey != nil")
        let count = managedContext.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 { return }
        
        let  path = NSBundle.mainBundle().pathForResource("SampleData", ofType: "plist")
        
        let dataArray = NSArray(contentsOfFile: path!)
        
        for dict: AnyObject in dataArray! {
            let entity = NSEntityDescription.entityForName("Bowtie", inManagedObjectContext: managedContext)
            
            let bowtie = Bowtie(entity: entity!, insertIntoManagedObjectContext: managedContext)
            let btDict = dict as! NSDictionary
            
            bowtie.name = btDict["name"] as? String
            bowtie.searchKey = btDict["searchKey"]  as? String
            bowtie.rating = btDict["rating"] as? NSNumber
            let tintColorDict = btDict["tintColor"] as! NSDictionary
            bowtie.tintColor = colorFromDict(tintColorDict)
            
            let imageName = btDict["imageName"] as! NSString
            let image = UIImage(named: imageName as String)
            let photoData = UIImagePNGRepresentation(image!)
            bowtie.photoData = photoData
            
            bowtie.lastWorn = btDict["lastWorn"] as? NSDate
            bowtie.timesWorn = btDict["timesWorn"] as? NSNumber
            bowtie.isFavorite = btDict["isFavorite"] as? NSNumber
            
            
            
        }
        
        do {
            try managedContext.save()
        } catch {
            print("插入出错")
        }
    }
    
    
    func colorFromDict(dict: NSDictionary) -> UIColor {
        let red = dict["red"] as! NSNumber
        let green = dict["green"] as! NSNumber
        let blue = dict["blue"] as! NSNumber
        let color = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1)
        return color
    }
    
    func updateRating(numbericString: String){
        currentBowtie.rating = (numbericString as NSString).doubleValue
        do {
            try managedContext.save()
        } catch let error as NSError {
            //如果rating的数值超过5,那么就显示保存失败
            print("保存失败:\(error)\n errorinfo: \(error.userInfo)")
        }
        populate(currentBowtie)
    }

    
    //MARK: - Action
    
    @IBAction func segmentedControl(sender: UISegmentedControl) {
        let selectedValue = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        
        let fetchRquest = NSFetchRequest(entityName: "Bowtie")
        
        fetchRquest.predicate = NSPredicate(format: "searchKey == %@", selectedValue!)
        
        var results: [Bowtie]?
        do {
            results = try managedContext.executeFetchRequest(fetchRquest) as? [Bowtie]
        } catch let error as NSError {
            print(error.userInfo)
        }
        if let bowties = results {
            currentBowtie = bowties.last!
            populate(currentBowtie)
        } else {
            print("不能查询")
        }
        
        
        
    }
    // 增加穿戴次数.
    @IBAction func wear(sender: AnyObject) {
        if let times = currentBowtie.timesWorn?.integerValue {
            currentBowtie.timesWorn = NSNumber(integer: (times + 1))
            currentBowtie.lastWorn = NSDate()
        
        do {
            try managedContext.save()
            } catch {
            print("保存失败")
        }
            populate(currentBowtie)
        
        }
        
        
        
        
    }
    
    @IBAction func rate(sender: AnyObject) {
        let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (UIAlertAction) -> Void in
        }
        
        let savieAction = UIAlertAction(title: "Save", style: .Default) { (UIAlertAction) -> Void in
            let textField = alert.textFields![0] as UITextField
            if let textStr = textField.text {
                self.updateRating(textStr)
            }
            }
        alert.addAction(cancelAction)
        alert.addAction(savieAction)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
        }
        self.presentViewController(alert, animated: true) { () -> Void in
        }
            
            
            
            
    }
    
    
    
    


}

