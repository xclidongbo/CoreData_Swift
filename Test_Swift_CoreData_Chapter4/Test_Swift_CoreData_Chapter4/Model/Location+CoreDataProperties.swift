//
//  Location+CoreDataProperties.swift
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

extension Location {

    @NSManaged var address: String?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var distance: NSNumber?
    @NSManaged var state: String?
    @NSManaged var zipcode: String?
    @NSManaged var venue: NSManagedObject?

}
