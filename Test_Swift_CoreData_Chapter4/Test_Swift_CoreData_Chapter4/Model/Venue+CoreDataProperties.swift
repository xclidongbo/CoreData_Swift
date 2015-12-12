//
//  Venue+CoreDataProperties.swift
//  Test_Swift_CoreData_Chapter4
//
//  Created by lidongbo on 15/12/10.
//  Copyright © 2015年 lidongbo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Venue {

    @NSManaged var favorite: NSNumber?
    @NSManaged var name: String?
    @NSManaged var phone: String?
    @NSManaged var specialCount: NSNumber?
    @NSManaged var category: NSManagedObject?
    @NSManaged var location: Location?
    @NSManaged var priceInfo: PriceInfo?
    @NSManaged var stats: NSManagedObject?

}
