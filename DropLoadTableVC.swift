//
//  DropLoadTableVC.swift
//  iPlayer Music
//
//  Created by Alexsander  on 10/4/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import SwiftyDropbox

class DropLoadTableVC: UITableViewController {
    
    // MARK: - var and let
    var nameArray = [String]()
    let client = Dropbox.authorizedClient!
    let fileManager = NSFileManager.defaultManager()
    var mainIndex: NSIndexPath!
    var progressView: UIProgressView!
    let x = UIWebView()
    
    // MARK: - IBOutlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        activityIndicator.startAnimating()
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        getSoundObject()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellLoad", forIndexPath: indexPath)
        let fileData = nameArray[indexPath.row]
        
        cell.textLabel?.text = fileData
        
        return cell
    }
    
    // MARK: - func
    
    func getSoundObject() {
//        print(client)
        client.filesListFolder(path: "").response { (listFolder, listError) -> Void in
            for entry in listFolder!.entries {
                if entry.name.containsString(".mp3") {
//                    print(entry)
                    self.nameArray.append(entry.name)
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.tableView.tableHeaderView = nil
//                    print(self.nameArray, self.nameArray.count)
                }
            }
        }
        let digit = 15 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(digit))
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            if self.nameArray.count == 0 {
            self.activityIndicator.stopAnimating()
            self.tableView.tableHeaderView = nil
                
            let alertController = UIAlertController(title: "There are not any songs", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                
            self.navigationController?.popViewControllerAnimated(true)
//                self.navigationController?.popToRootViewControllerAnimated(true)
                
//                let story = UIStoryboard(name: "Setting", bundle: NSBundle.mainBundle())
//                let dropController = story.instantiateViewControllerWithIdentifier("dropTable") as! UITableViewController
//                self.presentViewController(dropController, animated: true, completion: nil)
            }))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

    
    func downLoad() {
        print("download")
        let alertController = UIAlertController(title: "Download", message: "This song will be downloaded. Please, don't turn off the Internet.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        let digit = 5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(digit))
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        let selectSound = self.nameArray[self.mainIndex.row]
        let directory = self.fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!.path!
        
//        print(selectSound)
        self.client.filesDownload(path: "/\(selectSound)").response { (fileMeta, error) -> Void in
            print("Start downloading")
        self.client.filesDownload(path: "/\(selectSound)").progress()
            ///         a callback taking three arguments (`bytesRead`, `totalBytesRead`, `totalBytesExpectedToRead`)
            
            let (_, fileData) = fileMeta!
            
            fileData.writeToFile(directory.stringByAppendingString("/\(selectSound)"), atomically: true)
            self.mainIndex = nil
            self.tableView.tableHeaderView = nil 
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
    
    
    // MARK: - Select cell 

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        mainIndex = indexPath
        let currentSound = nameArray[indexPath.row]
        let alertController = UIAlertController(title: "Download", message: "Do you want to download \(currentSound)", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Download", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.downLoad()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        presentViewController(alertController, animated: true, completion: nil)
        
//        print(nameArray[indexPath.row])
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
