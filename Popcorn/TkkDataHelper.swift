//
//  TkkDataHelper.swift
//  Popcorn
//
//  Created by Timothy Goodson on 5/10/16.
//  Copyright © 2016 TK-Squared, LLC. All rights reserved.
//

import UIKit
import CoreData

class TkkDataHelper: NSObject {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext

    func getStations(EntityName: String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: EntityName)
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
                return results
        }catch let error as NSError {
            print("aww snap! \(error), \(error.userInfo)")
        }
    }

}
