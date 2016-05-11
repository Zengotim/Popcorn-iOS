//
//  MasterViewControllerTableViewController.swift
//  Popcorn
//
//  Created by Timothy Goodson on 5/9/16.
//  Copyright © 2016 TK-Squared, LLC. All rights reserved.
//

import UIKit
import CoreData


class MasterViewControllerTableViewController: UITableViewController {
    
    var stations = [NSManagedObject]()
    let helper = TkkDataHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        

        helper.newerFileAvailable({ (shouldDownload) -> () in
            if shouldDownload {
                self.helper.deleteAllStations("Station")
                self.helper.getNewRemoteFile()
            }
        })
        
        self.stations = helper.getStations("Station")!
        NSLog("Initial Stations size: \(self.stations.count)")
        
        
        /*self.checkShouldDownloadFileAtLocation("http://urltolocation.com/of/file.jpg", completion: { (shouldDownload) -> () in
            if shouldDownload {
                // Go download the file now
                
            }
        })*/
        
        
        
        
        
        /*
        let fileFunction = {
            let requestURL: NSURL = NSURL(string: mainBundle.localizedStringForKey("file_url", value: nil, table: "Brand"))!
            let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(urlRequest) {
                (data, response, error) -> Void in
                
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 200) {
                    print("Awesome! We got it!")
                    do{
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                        var path = mainBundle.resourcePath!
                        path.appendContentsOf("stations-ios.json")
                        let stream = NSOutputStream.init(toFileAtPath: path, append: false)
                        var err : NSError?
                        _ = NSJSONSerialization.writeJSONObject(json, toStream: stream!, options: .PrettyPrinted, error: &err)
                        
                        if let iStations = json["stations"] as? [[String: AnyObject]] {
                            for station in iStations {
                                if let name = station["name"] as? String {
                                    if let url = station["url"] as? String {
                                        print("Station: \(name) located at: \(url)")
                                        let entity =  NSEntityDescription.entityForName("Station", inManagedObjectContext:managedContext)
                                        let station = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                                        station.setValue(name, forKey: "name")
                                        station.setValue(url, forKey: "url")
                                        do {
                                            try managedContext.save()
                                            //self.stations.append(station)
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
 */
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        NSLog("Stations list size: \(stations.count)")
        return stations.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.backgroundColor = UIColor.yellowColor()
        let station = stations[indexPath.row]
        cell.textLabel!.text = station.valueForKey("name") as? String
        cell.detailTextLabel!.text = station.valueForKey("url") as? String

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
