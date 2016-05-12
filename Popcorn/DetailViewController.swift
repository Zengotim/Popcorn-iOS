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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

}

extension DetailViewController: StationViewDelegate{
    func stationSelected(name: String, urlstring: String) {
        let url = NSURL(string: urlstring)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
}