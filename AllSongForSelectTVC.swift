//
//  AllSongForSelectTVC.swift
//  Music
//
//  Created by Alexsander  on 8/18/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MediaPlayer
import AVFoundation

class AllSongForSelectTVC: UITableViewController, NSFetchedResultsControllerDelegate, NSFileManagerDelegate {

    // MARK: - override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        importFiles()
//        println(dateFromPlaylist)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        fetchedResultsController.delegate = self
        currentPlaylist = fetchedResultsController.fetchedObjects?.first
//        println(currentPlaylist)
//        println(originalSongArray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
    }
    
    // MARK: - var and let
    let fileManager = NSFileManager.defaultManager()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var dateFromPlaylist: NSDate!
    var currentPlaylist: AnyObject?
    var boolForSong = false
    
    // MARK: - @IBAction

    
    // MARK: - NSFetchedResultsController and its functions 
    var fetchedResultsController: NSFetchedResultsController!
    
    func fetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Playlist")
        let sortDescriptor = NSSortDescriptor(key: "playlistName", ascending: true)
//        let sortDescriptor = NSSortDescriptor(key: "playlistCreatedDate", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "playlistCreatedDate contains[c] %@", dateFromPlaylist)
        fetchRequest.fetchBatchSize = 10
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    // MARK: file manager functions and import files from store and var
    var mainSongArray = [String]()
    var originalSongArray = [String]()
    
    func importFiles() {
        let directoryURL = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first as NSURL!
        let arrayFromDirectory = try! fileManager.contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
    
        originalSongArray = arrayFromDirectory.filter(){ $0.pathExtension! == "mp3" }.map(){ $0.lastPathComponent! }
//        NSLog("array song meta is %@", originalSongArray)
        var song: String!
        
        var url: NSURL!
        for object in originalSongArray {
            let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
            let data: NSURL = directory.first!
            url = data.URLByAppendingPathComponent(object)
            
            let avPlayerItemURL = AVPlayerItem(URL: url)
            let commonMetaData = avPlayerItemURL.asset.commonMetadata 
            for item in commonMetaData {
                if item.commonKey == "title" {
                    song = item.stringValue
                    mainSongArray.append(song)
                }
            }
        }
//        NSLog("Super song array is %@", songArray)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainSongArray.count ?? 0
    }

    // var for metadata item 
    var songTitle: String!
    var songArtist: String!
    var songAlbum: String!
    var songArtworkData: NSData!
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songCell", forIndexPath: indexPath) as! SelectTableViewCell
        let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        var megaURL: NSURL!
        for itemString in originalSongArray {
            let url = directory.first!
            megaURL = url.URLByAppendingPathComponent(itemString)
            let avpItem = AVPlayerItem(URL: megaURL)
            let commonMetaData = avpItem.asset.commonMetadata 
            for item in commonMetaData {
                if item.commonKey == "title" {
                    songTitle = item.stringValue
//                    println(songTitle)
//                    NSLog("Song title is %@", songTitle)
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
                if songTitle == mainSongArray[indexPath.row] {
                    cell.titleLabel.text = songTitle
                    cell.artistLabel.text = songArtist
                    if songArtworkData != nil {
                        let image = UIImage(data: songArtworkData)
                        cell.artworkImageView.image = image
                    } else {
                        cell.artworkImageView.image = UIImage(named: "Notes100.png")
                    }
                    songArtworkData = nil
                }
            }
        }
        return cell
    }

    // MARK: - selected song functions 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        self.boolForSong = true 
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SelectTableViewCell
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        let currentSong = tableView.indexPathForSelectedRow!.row
        
        //
        let songObject = self.originalSongArray[currentSong]
//        NSLog("Song object is %@", songObject)
        let directory = self.fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
        var titleMeta: String!
        var artistMeta: String!
        var albumMeta: String!
        var artworkMeta: UIImage!
        
        let superURL = directory.URLByAppendingPathComponent(songObject)
        let playerItem = AVPlayerItem(URL: superURL)
        let commonMetaData = playerItem.asset.commonMetadata 
        for item in commonMetaData {
            if item.commonKey == "title" {
                titleMeta = item.stringValue
            }
            if item.commonKey == "artist" {
                artistMeta = item.stringValue
            }
            if item.commonKey == "album" {
                albumMeta = item.stringValue
            }
            if item.commonKey == "artwork" {
                artworkMeta = UIImage(data: item.dataValue!)
            }
        }
        
        // hello
        let urlOnFileInDirectory = directory.URLByAppendingPathComponent(songObject) // done
        let songFileSave = NSData(contentsOfURL: urlOnFileInDirectory)! // done
        let songPathExtensionSave = urlOnFileInDirectory.pathExtension!
        let songDateSave = NSDate() // need to add
        var titleSongSave: String!
        var artistSongSave: String!
        var albumSongSave: String!
        var artworkSongSave: UIImage!
        
        if titleMeta != nil {
            titleSongSave = titleMeta
        } else {
            titleSongSave = ""
        }
        if artistMeta != nil {
            artistSongSave = artistMeta
        } else {
            artistSongSave = ""
        }
        if albumMeta != nil {
            albumSongSave = albumMeta
        } else {
            albumSongSave = ""
        }
        if artworkMeta != nil {
            artworkSongSave = artworkMeta
        } else {
            artworkSongSave = UIImage(named: "Notes100.png")
        }
        
        let songEntity = NSEntityDescription.insertNewObjectForEntityForName("Song", inManagedObjectContext: self.managedObjectContext) as! Song
        
        songEntity.songTitle = titleSongSave
        songEntity.songArtist = artistSongSave
        songEntity.songAlbum = albumSongSave
        songEntity.songArtwork = UIImageJPEGRepresentation(artworkSongSave, 1.0)!
        songEntity.songDate = songDateSave
        songEntity.songData = songFileSave
        songEntity.songPathExtension = songPathExtensionSave
        songEntity.playlistRelationship = self.currentPlaylist as! Playlist
        
        do {
            try self.managedObjectContext.save()
        } catch _ {
        }
        }
//        NSLog("Song entity is %@", songEntity)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    @IBAction func thirdPlaylist(sender: UIButton) {
        if boolForSong == true {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let passToTaBBarController = storyboard.instantiateViewControllerWithIdentifier("mainTabBarController") as! UITabBarController
            passToTaBBarController.selectedIndex = 2
            presentViewController(passToTaBBarController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "You didn't select any song.", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alertController, animated: true, completion: nil)
            let digit = 1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(digit))
            dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
    }

}
