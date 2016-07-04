//
//  FromSearchTableViewController.swift
//  Music
//
//  Created by Alexsander  on 9/8/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import AVFoundation

class FromSearchTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    
    // need return UISearchResultsUpdating
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.tabBarController?.tabBar.hidden = true

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        arraySong = fetchedResultsController.fetchedObjects as! [Song]
        
        searchController = ({
            let controllerSearch = UISearchController(searchResultsController: nil)
            controllerSearch.delegate = self
            controllerSearch.searchBar.delegate = self
            controllerSearch.searchResultsUpdater = self
            controllerSearch.dimsBackgroundDuringPresentation = false
            controllerSearch.hidesNavigationBarDuringPresentation = false
            controllerSearch.definesPresentationContext = true
            controllerSearch.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controllerSearch.searchBar
            return controllerSearch
        })()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
//        NSLog("Exam array %@", examArray.count)
//        NSLog("Second exam array %@", examSecondArray.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - var and let
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    let fileManager = NSFileManager.defaultManager()
    var arraySong: [Song]!
    
    // MARK: - NSFetchedResultsController and its functions
    var fetchedResultsController: NSFetchedResultsController!
    var datePlaylist: NSDate!
    func fetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Song")
        let sortDescriptor = NSSortDescriptor(key: "songTitle", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "playlistRelationship.playlistCreatedDate contains[c] %@", datePlaylist)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 100
        return fetchRequest
    }
    
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
            return arraySong.count ?? 0
        } else {
            return searchArray?.count ?? 0
        }
    }
    
    // var for media
    var songTitle: String!
    var songArtist: String!
    var songAlbum: String!
    var songArtwork: UIImage!

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! FSTableViewCell
        if searchPredicate == nil {
            let data = arraySong[indexPath.row]
            cell.titleLabel.text = data.songTitle
            if data.songAlbum != "" {
                cell.artistAlbumLabel.text = "\(data.songArtist) - \(data.songAlbum)"
            } else {
                cell.artistAlbumLabel.text = data.songArtist
            }
            cell.artworkImageView.image = UIImage(data: data.songArtwork)
        
        } else {
            let data = searchArray[indexPath.row]
            cell.titleLabel.text = data.songTitle
            if data.songAlbum != "" {
                cell.artistAlbumLabel.text = "\(data.songArtist) - \(data.songAlbum)"
            } else {
                cell.artistAlbumLabel.text = data.songArtist
            }
            cell.artworkImageView.image = UIImage(data: data.songArtwork)
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }

    // MARK: - Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        if searchPredicate == nil {
            performSegueWithIdentifier("fromList", sender: self)
        } else {
            performSegueWithIdentifier("fromSearch", sender: self)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromList" {
            let playerAll = segue.destinationViewController as! PlayerSFPVC
            let indexRowPass = tableView.indexPathForSelectedRow!.row
            playerAll.currentIndex = indexRowPass
            playerAll.currentSongArray = arraySong
        } else if segue.identifier == "fromSearch" {
            let playerSearch = segue.destinationViewController as! PlayerSearchPlaylistViewController
            let indexRow = tableView.indexPathForSelectedRow!.row
            let currentSongPass = searchArray[indexRow]
            playerSearch.currentSong = currentSongPass
        }
    }


}
