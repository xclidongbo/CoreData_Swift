//
//  Dog+CoreDataProperties.swift
//  Test_CoreData_Chapter3
//
//  Created by lidongbo on 15/12/8.
//  Copyright © 2015年 lidongbo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Dog {

    @NSManaged var name: String?
    @NSManaged var walks: NSOrderedSet?

}
