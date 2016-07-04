//
//  SongFromPlaylistTVC.swift
//  Music
//
//  Created by Alexsander  on 9/7/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import AVFoundation

// need to return UISearchResultsUpdating
class SongFromPlaylistTVC: UITableViewController, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, NSFileManagerDelegate, UISearchResultsUpdating {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.tabBarController?.tabBar.hidden = true
        //
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: "songTitle", cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            
        }
        fileManager.delegate = self
        arrayMainSong = fetchedResultsController.fetchedObjects as! [Song]
//        arrayData = fetchedResultsController.fetchedObjects as! [Song]
//        requestData() // for searchController
        
        searchController = ({
            let controllerSearch = UISearchController(searchResultsController: nil)
            controllerSearch.delegate = self
            controllerSearch.searchBar.delegate = self
            controllerSearch.definesPresentationContext = true
            controllerSearch.dimsBackgroundDuringPresentation = false
            controllerSearch.hidesNavigationBarDuringPresentation = false
            controllerSearch.searchResultsUpdater = self
            controllerSearch.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controllerSearch.searchBar
            return controllerSearch
        })()
//        println(playlistData)
        
        print("I am here")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var arrayMainSong: [Song]!
    
    // MARK: - var and let
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    let fileManager = NSFileManager.defaultManager()
    
    // MARK: - var and let passing data
    var playlistData: Playlist!
    
    // MARK: - UISearchController
    var searchController: UISearchController!
    var searchPredicate: NSPredicate!
    var searchArray: [Song]!
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText != nil {
            searchPredicate = NSPredicate(format: "songTitle contains[c] %@", searchText!)
            searchArray = fetchedResultsController.fetchedObjects?.filter() {
                return self.searchPredicate.evaluateWithObject($0)
            } as! [Song]!
            tableView.reloadData()
        }
    }
    

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(searchController)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchPredicate = nil
        searchArray?.removeAll(keepCapacity: false)
        self.tableView.reloadData()
    }
    
    // MARK: - NSFetchedResultsController
    var fetchedResultsController: NSFetchedResultsController!
    var dateForPredicate: NSDate!
    
    func fetchRequest()-> NSFetchRequest {
        dateForPredicate = playlistData.playlistCreatedDate
        let fetchRequest = NSFetchRequest(entityName: "Song")
        let sortDescriptor = NSSortDescriptor(key: "songTitle", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "playlistRelationship.playlistCreatedDate contains[c] %@", dateForPredicate)
        fetchRequest.fetchBatchSize = 100
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }

    // MARK: request data
    
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchPredicate == nil {
            return 1 ?? 0
        } else {
            return 1 ?? 0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchPredicate == nil {
            return arrayMainSong.count ?? 0
        } else {
            return searchArray.count ?? 0
        }
    }
    

    /*
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameArtistAlbumLabel: UILabel!
    */

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SFPTableViewCell
        if searchPredicate == nil {
            let allData = arrayMainSong[indexPath.row]
            cell.nameLabel.text = allData.songTitle
            if allData.songAlbum != "" {
                cell.nameArtistAlbumLabel.text = "\(allData.songArtist) - \(allData.songAlbum)"
            } else {
                cell.nameArtistAlbumLabel.text = allData.songArtist
            }
            cell.coverImageView.image = UIImage(data: allData.songArtwork)
        } else {
            let data = searchArray[indexPath.row]
            
            cell.nameLabel.text = data.songTitle
            if data.songAlbum != "" {
                cell.nameArtistAlbumLabel.text = "\(data.songArtist) - \(data.songAlbum)"
            } else {
                cell.nameArtistAlbumLabel.text = data.songArtist
            }
            cell.coverImageView.image = UIImage(data: data.songArtwork)
        }
 
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    // MARK: - table view controller

//     Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            self.tableView.beginUpdates()
            managedObjectContext.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! Song)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            
            
            do {
                try managedObjectContext.save()
            } catch {
                print("fetched object error")
            }
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            managedObjectContext.insertObject(fetchedResultsController.objectAtIndexPath(indexPath) as! Song)
            do {
                try managedObjectContext.save()
            } catch _ {
            }
        }    
    }

    // MARK: - controller fetch
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Update:
            tableView.cellForRowAtIndexPath(indexPath!)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Move:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Update:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

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
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        if searchPredicate == nil {
            performSegueWithIdentifier("showAll", sender: self)
        } else {
            performSegueWithIdentifier("showFromSearch", sender: self)
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAll" {
            let playerSF = segue.destinationViewController as! PlayerSFPVC
            if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer != nil {
                (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
            }
            
            let indexPathPass = tableView.indexPathForSelectedRow!.row
            let arraySongPass = arrayMainSong
            playerSF.currentSongArray = arraySongPass
            playerSF.currentIndex = indexPathPass
        } else if segue.identifier == "showFromSearch" {
            if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer != nil {
                if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.playing {
                    (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
                }
            }
            let playerSearch = segue.destinationViewController as! PlayerSearchPlaylistViewController
            let indexRow = tableView.indexPathForSelectedRow!.row
            let currentSongPass = searchArray![indexRow]
//            NSLog("Current pass song %@", currentSongPass)
            playerSearch.currentSong = currentSongPass
        }
    }

}
