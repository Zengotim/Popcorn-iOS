//
//  TkkAboutViewController.swift
//  Popcorn
//
//  Created by Timothy Goodson on 5/24/16.
//  Copyright © 2016 TK-Squared, LLC. All rights reserved.
//

import UIKit

class TkkAboutViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var urlTextView: UITextField!
    @IBOutlet weak var compileLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameLabel.text = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as? String
        versionLabel.text = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String
        urlTextView.text = NSBundle.mainBundle().localizedStringForKey("app_url", value: nil, table: "Brand")
        compileLabel.text = "Compiled on \(compileDate()) at \(compileTime())"
        companyLabel.text = NSBundle.mainBundle().localizedStringForKey("company", value: nil, table: "Brand")
        
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
