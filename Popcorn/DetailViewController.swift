//
//  DetailViewController.swift
//  Popcorn
//
//  Created by Timothy Goodson on 5/9/16.
//  Copyright © 2016 TK-Squared, LLC. All rights reserved.
//

import UIKit
import iAd
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet var bannerAd: ADBannerView!
    var station: NSManagedObject?
    var shareObjects: [AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let shareButton = UIBarButtonItem(image: UIImage(named: "share_button.png"), style: .Plain, target: self, action: #selector(DetailViewController.showShare))
        self.navigationItem.rightBarButtonItem = shareButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func prepareShareObjects() -> Void {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)) {
            let icon = UIImage(named: "popcorn-icon.png")
            let msg1 = NSBundle.mainBundle().localizedStringForKey("share_title", value: nil, table: "Translatable")
            if let station_name = self.station?.valueForKey("name")!{
                let msg2 = NSBundle.mainBundle().localizedStringForKey("share_footer", value: nil, table: "Translatable")
                if let url = NSURL(string: NSBundle.mainBundle().localizedStringForKey("app_install_url", value: nil, table: "Brand")) {
                    self.shareObjects = [icon!, msg1, station_name, msg2, url] as [AnyObject]
                } else {
                    NSLog("URL assignment nogo")
                }
            } else {
                NSLog("station name nogo")
            }
        }
    }
    
    func showShare(sender: UIButton) -> Void {
        if self.shareObjects != nil {
            let activityVC = UIActivityViewController(activityItems: self.shareObjects!, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityVC, animated: true, completion: nil)
        } else {
            NSLog("shareObjects is nil")
        }
    }
}

extension DetailViewController: StationViewDelegate{
    func stationSelected(station: NSManagedObject) {
        self.station = station
        let url = NSURL(string: station.valueForKey("url") as! String)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
        prepareShareObjects()
    }
}