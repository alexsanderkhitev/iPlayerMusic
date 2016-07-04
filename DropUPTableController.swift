//
//  DropUPTableController.swift
//  iPlayer Music
//
//  Created by Alexsander  on 10/5/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import SwiftyDropbox

class DropUPTableController: UITableViewController {

    // MARK: - var and let
    var generalNames = [String]()
    var filterNameArray = [String]()
    var filterArtistArray = [String]()
    let fileManager = NSFileManager.defaultManager()
    var songTitle: String!
    var songArtist: String!
    var songAlbum: String!
    var songArtworkData: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
//        filterNameArray.sortInPlace(){ $0 < $1 }
        getAllSong()
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
        return generalNames.count ?? 0
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("upCell", forIndexPath: indexPath) as! DropUpCell
        
//        let data = filterNameArray[indexPath.row]
        let generalData = generalNames[indexPath.row]
        let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
        let url = directory.URLByAppendingPathComponent(generalData)
        let playerItem = AVPlayerItem(URL: url)
        let commonMetadata = playerItem.asset.commonMetadata
        for item in commonMetadata {
            if item.commonKey == "title" {
                songTitle = item.stringValue
            }
            if item.commonKey == "artist" {
                songArtist = item.stringValue
            }
            if item.commonKey == "album" {
                songAlbum = item.stringValue
            }
            if item.commonKey == "artwork" {
                songArtworkData = item.dataValue
            }
            
            cell.songTitle.text = songTitle
            if songAlbum != nil {
                cell.songArtistAlbum.text = "\(songArtist) - \(songAlbum)"
            } else {
                cell.songArtistAlbum.text = songArtist
            }
            if songArtworkData == nil {
                cell.songArtwork.image = UIImage(named: "Notes100.png")
            } else {
                cell.songArtwork.image = UIImage(data: songArtworkData)
//                songArtworkData = nil
            }
            songArtworkData = nil
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        uploadData()
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
    
    // MARK: - func 
    func getAllSong() {
        let urlDirectory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
        print(urlDirectory)
        var allFile = [NSURL]()
        
        do {
            allFile = try! fileManager.contentsOfDirectoryAtURL(urlDirectory, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        }
        
//        print(allFile)
        do {
            generalNames = allFile.filter(){ $0.pathExtension! == "mp3" }.map(){ $0.lastPathComponent! }
        }
//        for item in generalNames {
//            let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
//            let url = directory.URLByAppendingPathComponent(item)
//            let playerItem = AVPlayerItem(URL: url)
//            let commonMetadata = playerItem.asset.commonMetadata
//            for data in commonMetadata {
//                if data.commonKey == "title" {
//                    songTitle = data.stringValue
//                    filterNameArray.append(data.stringValue!)
//                    print(filterNameArray.count)
//                }
//                if data.commonKey == "artist" {
//                    songArtist = data.stringValue
//                }
////                importData()
//            }
//        }
//        filterNameArray.sortInPlace(){ $0 < $1 }
    }

    func uploadData() {
        let indexPath = tableView.indexPathForSelectedRow!
        var nameSong: String!
        let currentSong = generalNames[indexPath.row]
        let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
        let url = directory.URLByAppendingPathComponent(currentSong)
        let playerItem = AVPlayerItem(URL: url)
        let commonMetadata = playerItem.asset.commonMetadata
        for item in commonMetadata {
            if item.commonKey == "title" {
                nameSong = item.stringValue
            }
        }
        
        let alertController = UIAlertController(title: "Upload", message: "Do you want to upload \(nameSong)?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Upload", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            let client = Dropbox.authorizedClient!
            print("upload 2")
            let path = directory.URLByAppendingPathComponent(currentSong).path!
            let dataSong = self.fileManager.contentsAtPath(path)!
            client.filesUpload(path: "/\(nameSong).mp3", body: dataSong)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.showAlert()
            // 
        }))
       alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

       }))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func showAlert() {
        let alertNoteController = UIAlertController(title: "This file will be uploaded. Please don't turn off the Internet", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alertNoteController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alertNoteController, animated: true, completion: nil)
        let digit = 5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(digit))
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            alertNoteController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
   
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
