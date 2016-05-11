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
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let mainBundle = NSBundle.mainBundle()
    let dateFormatter = NSDateFormatter()
    let request = NSMutableURLRequest(URL: NSURL(string: NSBundle.mainBundle().localizedStringForKey("file_url", value: nil, table: "Brand"))!)
    
    func newerFileAvailable(completion:((shouldDownload:Bool) -> ())? ){
        
        request.HTTPMethod = "HEAD"
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: { [weak self] data, response, error -> Void in
            if let strongSelf = self {
                var isModified = false
                if let httpResponse = response as? NSHTTPURLResponse {
                    let lastModifiedDate = httpResponse.allHeaderFields["Last-Modified"] as? String
                    if lastModifiedDate != nil {
                        let formattedLastModifiedDate = strongSelf.dateFormatter.dateFromString(lastModifiedDate!)
                        guard let path = self!.mainBundle.pathForResource("stations-ios", ofType: "json")else{
                            NSLog("Path creation failed")
                            return
                        }
                        
                        if NSFileManager.defaultManager().fileExistsAtPath(path){
                            do{
                                let attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
                                let localFileModifiedDate = attributes[NSFileModificationDate] as? NSDate
                                if localFileModifiedDate?.compare(formattedLastModifiedDate!) == NSComparisonResult.OrderedAscending {
                                    isModified = true
                                }
                            }catch{
                                NSLog("shitstorm")
                            }
                        }else{
                            isModified = true
                        }
                    }
                }
                if completion != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion!(shouldDownload: isModified)
                    })
                }
            }
        })
        task.resume()
    }
    
    func getNewRemoteFile() -> Void {

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Awesome! We got it!")
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    var path = self.mainBundle.resourcePath!
                    path.appendContentsOf("stations-ios.json")
                    let stream = NSOutputStream.init(toFileAtPath: path, append: false)
                    stream?.open()
                    var err : NSError?
                    _ = NSJSONSerialization.writeJSONObject(json, toStream: stream!, options: .PrettyPrinted, error: &err)
                    stream?.close()
                    if let iStations = json["stations"] as? [[String: AnyObject]] {
                        for station in iStations {
                            if let name = station["name"] as? String {
                                if let url = station["url"] as? String {
                                    print("Station: \(name) located at: \(url)")
                                    let entity =  NSEntityDescription.entityForName("Station", inManagedObjectContext:self.managedContext)
                                    let station = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedContext)
                                    station.setValue(name, forKey: "name")
                                    station.setValue(url, forKey: "url")
                                    do {
                                        try self.managedContext.save()
                                    } catch let error as NSError  {
                                        print("Could not save \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                    }
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
            } else {
                print("\(statusCode)")
            }
        }
        task.resume()
    }


    func deleteAllStations(entity: String) -> Bool {
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        var success = false
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.deleteObject(managedObjectData)
                success = true
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
        return success
    }

    func getStations(entity: String) -> [NSManagedObject]? {
        
        let fetchRequest = NSFetchRequest(entityName: entity)

        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
                return results as? [NSManagedObject]
        }catch let error as NSError {
            print("aww snap! \(error), \(error.userInfo)")
        }
        return nil
    }
    
}
