//
//  FilterViewController.swift
//  Test_Swift_CoreData_Chapter4
//
//  Created by lidongbo on 15/12/10.
//  Copyright © 2015年 lidongbo. All rights reserved.
//

import  UIKit
import CoreData

//MARK: protocol
//建立代理
protocol FilterViewControllelerDelegate: class {
    func filterViewController(filter: FilterViewControlelr , didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
}


class FilterViewControlelr: UITableViewController {
    
    @IBOutlet weak var firstPriceCategoryLabel: UILabel!
    
    @IBOutlet weak var secondPriceCategoryLabel: UILabel!
    
    @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
    
    @IBOutlet weak var numDealsLabel: UILabel!
    
    
    //Price section
    @IBOutlet weak var cheapVenueCell: UITableViewCell!
    
    @IBOutlet weak var moderateVenueCell: UITableViewCell!
    
    @IBOutlet weak var expensiveVenueCell: UITableViewCell!
    
    //Most popular section
    @IBOutlet weak var offeringDealCell: UITableViewCell!
    
    @IBOutlet weak var walkingDistanceCell: UITableViewCell!
    
    @IBOutlet weak var userTipsCell: UITableViewCell!
    
    //Sort section
    
    @IBOutlet weak var nameAZSortCell: UITableViewCell!
    
    @IBOutlet weak var nameZASortCell: UITableViewCell!
    
    @IBOutlet weak var distanceSortCell: UITableViewCell!
    
    @IBOutlet weak var priceSortCell: UITableViewCell!
    
    var coreDataStack: CoreDataStack!
    
    //定义代理,并设置排序,谓词
    weak var delegate: FilterViewControllelerDelegate?
    var selectedSortDescriptor: NSSortDescriptor?
    var selectedPredicate: NSPredicate?
    
    
    lazy var cheapVenuePredicate: NSPredicate = {
        //predicate支持keypath
        var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$")
        return predicate
    }()
    
    lazy var moderateVenuePredicate: NSPredicate = {
        var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$$")
        return predicate
    }()
    
    lazy var expensiveVenuePredicate: NSPredicate = {
       var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$$$")
        return predicate
    }()
    
    lazy var offeringDealPredicate: NSPredicate = {
        var pr = NSPredicate(format: "specialCount > 0")
        return pr
    }()
    lazy var walkingDistancePredicate: NSPredicate = {
        var pr = NSPredicate(format: "location.distance < 500")
        return pr
    }()
    
    lazy var hasUserTipsPredicate: NSPredicate = {
        var pr = NSPredicate(format: "stats.tipCount > 0")
        return pr
    }()
    
    
    lazy var nameSortDescriptor: NSSortDescriptor = {
        var sd = NSSortDescriptor(key: "name", ascending: true, selector: "localizedStandardCompare:")
        return sd
    }()
    
    lazy var distanceSortDescriptor: NSSortDescriptor = {
       var sd = NSSortDescriptor(key: "location.distance", ascending: true)
        return sd
    }()
    
    lazy var priceSortDescriptor: NSSortDescriptor = {
       var sd = NSSortDescriptor(key: "priceInfo.priceCategory", ascending: true)
        return sd
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateCheapVenueCountLabel()
        populateModerateVenueCountLabel()
        populateExpensiveVenueCountLabel()
        populateDealsCountLabel()
        
    }
    
    
    
    //MARK: different 
    
    //价格便宜的奶茶数量
    func populateCheapVenueCountLabel() {
        // $ fetch request
        let fetchRequest = NSFetchRequest(entityName: "Venue")
        fetchRequest.resultType = .CountResultType
        fetchRequest.predicate = cheapVenuePredicate
        
        var result: [NSNumber]?
        do {
            result = try coreDataStack.context.executeFetchRequest(fetchRequest) as? [NSNumber]
        } catch  {
            print("未查到数量")
        }
        
        if let countArray = result {
            let count = countArray[0].integerValue
            firstPriceCategoryLabel.text = "\(count) bubble tea places"
        } else {
            print("Could not fetch ")
        }
        
    }
    
    //价格中等的奶茶数量
    func populateModerateVenueCountLabel() {
        
        let fetchRequest = NSFetchRequest(entityName: "Venue")
        fetchRequest.resultType = .CountResultType
        fetchRequest.predicate = moderateVenuePredicate
        
//        var result:[NSNumber]?
//        do {
//            result = try coreDataStack.context.executeFetchRequest(fetchRequest) as? [NSNumber]
//        } catch let error as NSError {
//            print("Could not fetch : \(error.userInfo)")
//        }
//        
//        if let countArray = result {
//            let count = countArray[0].integerValue
//            secondPriceCategoryLabel.text = "\(count) bubble tea places"
//        }
        
        //也可以使用以下做法.
        var result:Int?
        var error: NSError?
        result = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        if let count = result {
            secondPriceCategoryLabel.text = "\(count) bubble tea places"
        } else {
            print("Could not fetch : \(error?.userInfo)")
        }
    
    }
    
    func populateExpensiveVenueCountLabel() {
        
        let fetchRequest = NSFetchRequest(entityName: "Venue")
        fetchRequest.resultType = .CountResultType
        fetchRequest.predicate = expensiveVenuePredicate
        

        var error: NSError?
        let result: Int? = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        if let count = result {
            thirdPriceCategoryLabel.text = "\(count) bubble tea places"
        } else {
            print("Could not fetch : \(error?.userInfo)")
        }
    }
    
    func populateDealsCountLabel() {
        
        //1
        //开始为了检索Venue对象,创建一个特有的getchrequest.下一步,指定resulttype为DictionaryResultType
        let fetchRequest = NSFetchRequest(entityName: "Venue")
        fetchRequest.resultType = .DictionaryResultType
        
        
        //2
        // 创建了一个 NSExpressionDescription 去请求总数. 并给这个类起个名字叫做sumDeals.你可以读取这个结果.从请求回来的结果字典中.
        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumDeals"
        
        //3
        //给这个表达/词组 描述 一个 NSExpression, 你想求和的函数.然后给这个表达/词组,另外一个NSExpression 列举你想求和的属性. -这种情况下是specialCount. 最后,你必须设置你的表达/词组描述的返回数据的类型,所以设置Integer32AttributeType
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "specialCount")])
        sumExpressionDesc.expressionResultType = .Integer32AttributeType
        
        
        //4
        //你告诉你的组织获取请求. 依靠设置propertiesToFetch属性去表达描述你刚才创建的.
        fetchRequest.propertiesToFetch = [sumExpressionDesc]
        
        //5
        //最后,你执行这个查询请求. 你获得一个可选的字典请求的值. 使用表达描述的名字来获取表达的结果.
        var result:[NSDictionary]?
        do {
            result = try coreDataStack.context.executeFetchRequest(fetchRequest) as? [NSDictionary]
        } catch let error as NSError {
            print("Could not fetch : \(error.userInfo)")
        }
        
        if let resultArray = result {
            let resultDict = resultArray[0]
            let numDeals: AnyObject? = resultDict["sumDeals"]
            numDealsLabel.text = "\(numDeals!) total deals"
        } else {
            print("结果为空")
        }
        
        
    }
    
    //MARK: Action
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        delegate!.filterViewController(self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    //MARK: tableView dataSource
    
    
    
    
    //MARK: tableView delegate
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            switch cell {
            case cheapVenueCell:
                selectedPredicate = cheapVenuePredicate
            case moderateVenueCell:
                selectedPredicate = moderateVenuePredicate
            case expensiveVenueCell:
                selectedPredicate = expensiveVenuePredicate
                //Most Popular section
            case offeringDealCell:
                selectedPredicate = offeringDealPredicate
            case walkingDistanceCell:
                selectedPredicate = walkingDistancePredicate
            case userTipsCell:
                selectedPredicate = hasUserTipsPredicate
                
                //Sort by section
            case nameAZSortCell:
                selectedSortDescriptor = nameSortDescriptor
            case nameZASortCell:
                selectedSortDescriptor = nameSortDescriptor.reversedSortDescriptor as? NSSortDescriptor
            case distanceSortCell:
                selectedSortDescriptor = distanceSortDescriptor
            case priceSortCell:
                selectedSortDescriptor = priceSortDescriptor
            default:
                print("default case")
            }
            
            cell.accessoryType = .Checkmark
        }
        
    }
    
    
}