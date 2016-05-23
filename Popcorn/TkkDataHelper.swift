//
//  TkkDataHelper.swift
//  Popcorn
//
//  Helper class for dealing with the stations list data
//
//  Created by Timothy Goodson on 5/10/16.
//  Copyright © 2016 TK-Squared, LLC. All rights reserved.
//

import UIKit
import CoreData

protocol TkkDataRecipient: class {
    func newDataReceived(newList: [NSManagedObject])
}


class TkkDataHelper: NSObject {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let mainBundle = NSBundle.mainBundle()
    let dateFormatter = NSDateFormatter()
    
    weak var recipient: TkkDataRecipient?
    
    //Check for newer file on server
    func newerFileAvailable(completion:((shouldDownload:Bool) -> ())? ){
        
        //Set up server connection for header only
        let request = NSMutableURLRequest(URL: NSURL(string: NSBundle.mainBundle().localizedStringForKey("file_url", value: nil, table: "Brand"))!)
        request.HTTPMethod = "HEAD"
        let session = NSURLSession.sharedSession()
        //Connect to server and get last modified date of file from header
        let task = session.dataTaskWithRequest(request, completionHandler: { [weak self] data, response, error -> Void in
            if let strongSelf = self {
                var isModified = false
                if let httpResponse = response as? NSHTTPURLResponse {
                    let lastModifiedDate = httpResponse.allHeaderFields["Last-Modified"] as? String
                    if lastModifiedDate != nil {
                        //set date format **this format is subject to change, which sucks!**
                        strongSelf.dateFormatter.dateFormat = "EEE, dd MMMM yyyy HH:mm:ss zzz"
                        //Convert to NSDate
                        let formattedLastModifiedDate = strongSelf.dateFormatter.dateFromString(lastModifiedDate!)
                        //Check local file last modified date and compare the two
                        let paths = NSSearchPathForDirectoriesInDomains(
                            NSSearchPathDirectory.DocumentDirectory,
                            NSSearchPathDomainMask.AllDomainsMask, true)
                        let documentsDirectory = paths.first! as NSString
                        let path = documentsDirectory.stringByAppendingPathComponent("stations-ios.json")
                            if NSFileManager.defaultManager().fileExistsAtPath(path){
                                do{
                                    let attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
                                    let localFileModifiedDate = attributes[NSFileModificationDate] as? NSDate
                                    //If server file is newer, need a download
                                    if localFileModifiedDate?.compare(formattedLastModifiedDate!) == NSComparisonResult.OrderedAscending {
                                        isModified = true
                                    }
                                }catch{
                                    //Really? File exists but I can't read attributes?
                                    NSLog("shitstorm")
                                }
                            }else{
                                NSLog("No friggin file at \(path)")
                                isModified = true
                            }
                        }
                    }
                //Cue the function
                if completion != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion!(shouldDownload: isModified)
                    })
                }
            }
        })
        //Yeah, async
        task.resume()
    }
    
    func getNewRemoteFile() -> Void {

        //Set up server connection to get file
        let request = NSMutableURLRequest(URL: NSURL(string: NSBundle.mainBundle().localizedStringForKey("file_url", value: nil, table: "Brand"))!)
        let session = NSURLSession.sharedSession()
        //Async task with closure
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                NSLog("Awesome! We got it!")
                do{
                    //Make a JSON object from the data received
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    //---get the path of the Documents folder---
                    let paths = NSSearchPathForDirectoriesInDomains(
                        NSSearchPathDirectory.DocumentDirectory,
                        NSSearchPathDomainMask.AllDomainsMask, true)
                    let documentsDirectory = paths.first! as NSString
                    
                    //---full path of file to save in---
                    let path = documentsDirectory.stringByAppendingPathComponent("stations-ios.json")

                    let stream = NSOutputStream.init(toFileAtPath: path, append: false)
                    stream?.open()
                    var err : NSError?
                    //Write new file to local
                    _ = NSJSONSerialization.writeJSONObject(json, toStream: stream!, options: .PrettyPrinted, error: &err)
                    stream?.close()
                    //iterate through the stations and add them to db
                    if let iStations = json["stations"] as? [[String: AnyObject]] {
                        var i = 0
                        for station in iStations {
                            if let name = station["name"] as? String {
                                if let url = station["url"] as? String {
                                    NSLog("Station: \(name) located at: \(url)")
                                    let entity =  NSEntityDescription.entityForName("Station", inManagedObjectContext:self.managedContext)
                                    let station = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedContext)
                                    station.setValue(name, forKey: "name")
                                    station.setValue(url, forKey: "url")
                                    station.setValue(UIImagePNGRepresentation(UIImage.init(named: "popcorn-icon.png")!), forKey: "icon")
                                    station.setValue(i, forKey: "position")
                                    i += 1
                                    do {
                                        try self.managedContext.save()
                                    } catch let error as NSError  {
                                        NSLog("Could not save \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        // Reload the list
                        if let masterController = self.recipient as? MasterViewControllerTableViewController{
                            masterController.newDataReceived(self.getStations("Station")!)
                        }
                    }
                    
                }catch {
                    NSLog("Error with Json: \(error) \(data)")
                }
                
            } else {
                NSLog("\(statusCode)")
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
            NSLog("Detele all data in \(entity) error : \(error) \(error.userInfo)")
            success = false
        }
        return success
    }

    func getStations(entity: String) -> [NSManagedObject]? {
        // Standard data request
        let fetchRequest = NSFetchRequest(entityName: entity)
        let sortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
                return results as? [NSManagedObject]
        }catch let error as NSError {
            NSLog("aww snap! \(error), \(error.userInfo)")
        }
        return nil
    }
    
    func deleteStation(station: NSManagedObject) -> Void {
        
        managedContext.deleteObject(station)
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            NSLog("Could not delete station \(station), error: \(error)")
        }
    }

    
}
