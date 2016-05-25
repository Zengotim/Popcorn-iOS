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
    func stationSelected(station: NSManagedObject)
}

@IBDesignable
class MasterViewControllerTableViewController: UITableViewController, TkkDataRecipient, UIPopoverPresentationControllerDelegate {
    
    var stations = [NSManagedObject]()
    let helper = TkkDataHelper()
    let indeterminant = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    //let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let aboutViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("aboutViewController")
    let popoverAboutViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("aboutViewController").popoverPresentationController
    weak var delegate: StationViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let dlButton = UIBarButtonItem(image: UIImage.init(named: "dl_arrow.png"), style: .Plain, target: self, action: #selector(MasterViewControllerTableViewController.getNewList))
        let spacerButton = UIBarButtonItem(title: "      ", style: .Plain, target: self, action: nil)
        let aboutButton = UIBarButtonItem(title: "About", style: .Plain, target: self, action: #selector(MasterViewControllerTableViewController.showAbout))
        self.navigationItem.leftBarButtonItems = [dlButton, spacerButton, aboutButton]
        
        self.indeterminant.center = self.view.center
        self.view.addSubview(indeterminant)
        self.indeterminant.hidden = true
        
        //Load the stations list
        self.stations = helper.getStations("Station")!
        
        //Check for newer file on server and download if available
        helper.newerFileAvailable({ (shouldDownload) -> () in
            if shouldDownload {
                self.indeterminant.hidden = false
                self.indeterminant.startAnimating()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TkkTableViewCell

        // Digital art, bitches!
        // Plank style with brushed aluminum & drop shadow!
        let topBullnose = CAGradientLayer()
        topBullnose.frame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y , cell.bounds.width, cell.bounds.height/8)
        topBullnose.colors = NSArray(objects: [UIColor(red: 0.62109, green: 0.54296, blue: 0.01172, alpha: 1.0).CGColor, UIColor(red: 0.95294, green: 0.83137, blue: 0.01961, alpha: 1.0).CGColor], count: 2) as [AnyObject]
        
        let bottomBullnose = CAGradientLayer()
        bottomBullnose.frame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y + cell.bounds.height*6/8, cell.bounds.width, cell.bounds.height/8)
        bottomBullnose.colors = NSArray(objects: [UIColor(red: 0.95294, green: 0.83137, blue: 0.01961, alpha: 1.0).CGColor, UIColor(red: 0.62109, green: 0.54296, blue: 0.01172, alpha: 1.0).CGColor], count: 2) as [AnyObject]
        
        let flatSurface = CAGradientLayer()
        flatSurface.frame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y + cell.bounds.height/8, cell.bounds.width, cell.bounds.height*5/8)
        flatSurface.backgroundColor = UIColor(red: 0.95294, green: 0.83137, blue: 0.01961, alpha: 1.0).CGColor
        
        let dropShadow = CAGradientLayer()
        dropShadow.frame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y + cell.bounds.height*7/8, cell.bounds.width, cell.bounds.height/8)
        dropShadow.colors = NSArray(objects: [UIColor(red: 0.6353, green: 0.6353, blue: 0.6353, alpha: 1.0).CGColor, UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).CGColor], count: 2) as [AnyObject]

        // Add the color layers in order
        cell.layer.insertSublayer(dropShadow, below: cell.contentView.layer)
        cell.layer.insertSublayer(topBullnose, below: cell.contentView.layer)
        cell.layer.insertSublayer(bottomBullnose, below: cell.contentView.layer)
        cell.layer.insertSublayer(flatSurface, below: cell.contentView.layer)
        
        // Generate random streaks for the brushed look
        for line in 0...Int(flatSurface.frame.size.height){
            let streak = CAGradientLayer()
            if drand48() > 0.10 {
                streak.frame = CGRectMake(CGFloat(drand48())*cell.bounds.width - cell.bounds.width/4, CGFloat(line) + cell.bounds.height/8, CGFloat(drand48())*cell.bounds.width, 1.0)
                streak.backgroundColor = UIColor(red: 0.95294 + CGFloat(drand48()*0.05), green: 0.83137 + CGFloat(drand48()*0.05), blue: 0.01961, alpha: 1.0).CGColor
                cell.layer.insertSublayer(streak, below: cell.contentView.layer)
            }
        }
        
        let station = stations[indexPath.row]

        cell.titleLabel?.backgroundColor = UIColor.clearColor()
        cell.titleLabel!.text = station.valueForKey("name") as? String
        cell.subtitleLabel?.backgroundColor = UIColor.clearColor()
        cell.subtitleLabel!.text = station.valueForKey("url") as? String
        let stationIcon = station.valueForKey("icon") as? UIImage
        if (stationIcon != nil){
            cell.iconView.image = stationIcon
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedStation = self.stations[indexPath.row]
        //self.delegate?.stationSelected((selectedStation.valueForKey("name") as? String)!, urlstring: (selectedStation.valueForKey("url") as? String)!)
        self.delegate?.stationSelected(selectedStation)
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

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            helper.deleteStation(self.stations[indexPath.row])
            self.stations = helper.getStations("Station")!
            for i in indexPath.row + 1..<self.stations.count {
                self.stations[i].setValue(i-1, forKey: "position")
            }
            self.stations = helper.getStations("Station")!
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

        } else if editingStyle == .Insert {
            //Not happening, Jethro
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        
        if fromIndexPath.row > toIndexPath.row
        {
            for i in toIndexPath.row..<fromIndexPath.row
                
            {
                self.stations[i].setValue(i+1, forKey: "position")
                
                
            }
            
            self.stations[fromIndexPath.row].setValue(toIndexPath.row, forKey: "position")
        }
        if fromIndexPath.row < toIndexPath.row
        {
            
            for i in fromIndexPath.row + 1...toIndexPath.row
                
            {
                self.stations[i].setValue(i-1, forKey: "position")
                
                
            }
            
            self.stations[fromIndexPath.row].setValue(toIndexPath.row, forKey: "position")
        }
        self.stations = helper.getStations("Station")!
        
    }
    
    // MARK: - Click Handlers
    
    //About button
    func showAbout() -> Void {

        aboutViewController.modalPresentationStyle = .Popover
        //aboutViewController.preferredContentSize = CGSizeMake(300, 450)

        popoverAboutViewController?.permittedArrowDirections = .Any
        popoverAboutViewController?.delegate = self
        popoverAboutViewController?.sourceView = self.view
        popoverAboutViewController?.sourceRect = CGRect(
            x: UIScreen.mainScreen().bounds.width/2 - 150,
            y: UIScreen.mainScreen().bounds.height/2 - 225,
            width: 50,
            height: 75)
        presentViewController(aboutViewController, animated: true, completion: nil)
        
        _ = NSTimer.scheduledTimerWithTimeInterval(9, target: self, selector: #selector(MasterViewControllerTableViewController.dismissAbout), userInfo: nil, repeats: false)
        
    }
    
    func dismissAbout() -> Void {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Get new list button
    func getNewList() -> Void {
        
        let reloadConfirm = UIAlertController(title: "Download List?", message: "Reset list to server version?", preferredStyle: .Alert)
        reloadConfirm.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            self.indeterminant.hidden = false
            self.indeterminant.startAnimating()
            self.helper.deleteAllStations("Station")
            self.helper.getNewRemoteFile()
        }))
        reloadConfirm.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        presentViewController(reloadConfirm, animated: true, completion: nil)

    }
    

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
        self.indeterminant.stopAnimating()
        self.indeterminant.hidden = true
    }

}
