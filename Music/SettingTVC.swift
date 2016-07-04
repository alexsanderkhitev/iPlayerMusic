//
//  SettingTVC.swift
//  iPlayer Music
//
//  Created by Alexsander  on 9/24/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import MessageUI
import Foundation
import SystemConfiguration
import Alamofire


class SettingTVC: UITableViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    // MARK: - var and let
    var mailController = MFMailComposeViewController()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: - IBOutlet
    
    
    // MARK: - override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.tabBarController?.tabBar.hidden = false
        mailController.mailComposeDelegate = self
        
    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }

    // MARK: - IBAction
    @IBAction func feedbackGesture(sender: UIGestureRecognizer) {
        let myEmail = "alexsanderskywork@gmail.com"
        let subjectApp = "iPlayer Music"
        print("feedback gesture")
        mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        if MFMailComposeViewController.canSendMail() {
            mailController.setToRecipients([myEmail])
            mailController.setSubject(subjectApp)
            presentViewController(mailController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "E-Mail Not Enabled", message: "E-Mail is not supported on this device", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            print("Cannot to send email")
        }
    }
    

    
    // MARK: - mail controller
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultSent.rawValue:
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            print("sent")
            break
        case MFMailComposeResultSaved.rawValue:
            self.dismissViewControllerAnimated(true, completion: nil)
            print("saved")
            break
        case MFMailComposeResultFailed.rawValue:
            self.dismissViewControllerAnimated(true, completion: nil)
            print("failed ")
            break
        case MFMailComposeResultCancelled.rawValue:
            self.dismissViewControllerAnimated(true, completion: nil)
            print("Cancel")
            break
        default: break
        }
    }
    
    
    @IBAction func dropGesture(sender: UIGestureRecognizer) {
        if isAvailableInternet() == true {
            performSegueWithIdentifier("dropSegue", sender: self)
        } else {
            let alertController = UIAlertController(title: "The Internet connection appears to be offline", message: nil, preferredStyle: .Alert)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - function
    
    func isAvailableInternet() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
    // MARK: - Table view data source
//
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    
    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
