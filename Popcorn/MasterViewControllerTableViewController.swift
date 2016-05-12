//
//  MasterViewControllerTableViewController.swift
//  Popcorn
//
//  Created by Timothy Goodson on 5/9/16.
//  Copyright © 2016 TK-Squared, LLC. All rights reserved.
//

import UIKit
import CoreData

protocol StationViewDelegate: class{
    func stationSelected(name: String, urlstring: String)
}


class MasterViewControllerTableViewController: UITableViewController, TkkDataRecipient {
    
    var stations = [NSManagedObject]()
    let helper = TkkDataHelper()
    weak var delegate: StationViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //Load the stations list
        self.stations = helper.getStations("Station")!
        
        //Check for newer file on server and download if available
        helper.newerFileAvailable({ (shouldDownload) -> () in
            if shouldDownload {
                self.helper.deleteAllStations("Station")
                self.helper.getNewRemoteFile()
            }
        })
        
        NSLog("Initial Stations size: \(self.stations.count)")


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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedStation = self.stations[indexPath.row]
        self.delegate?.stationSelected((selectedStation.valueForKey("name") as? String)!, urlstring: (selectedStation.valueForKey("url") as? String)!)
        if let detailViewController = self.delegate as? DetailViewController {
            splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
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
    
    //MARK: -TkkDataRecipient protocol implementation
    
    func newDataReceived(newList: [NSManagedObject]){
        self.stations = newList
        self.tableView.reloadData()
    }

}
