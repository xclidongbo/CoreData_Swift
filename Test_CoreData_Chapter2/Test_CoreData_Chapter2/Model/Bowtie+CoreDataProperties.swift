//
//  Bowtie+CoreDataProperties.swift
//  Test_CoreData_Chapter2
//
//  Created by lidongbo on 15/12/7.
//  Copyright © 2015年 lidongbo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Bowtie {

    @NSManaged var name: String?
    @NSManaged var isFavorite: NSNumber?
    @NSManaged var lastWorn: NSDate?
    @NSManaged var rating: NSNumber?
    @NSManaged var searchKey: String?
    @NSManaged var timesWorn: NSNumber?
    @NSManaged var photoData: NSData?
    @NSManaged var tintColor: NSObject?

}
