//
//  PlaylistTVC.swift
//  Music
//
//  Created by Alexsander  on 8/18/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class PlaylistTVC: UITableViewController, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    
    // MARK: - override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.tabBarController?.tabBar.hidden = false
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: "playlistName", cacheName: "playlistName")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        searchController = ({
            let controllerSearch = UISearchController(searchResultsController: nil)
            controllerSearch.delegate = self
            controllerSearch.searchBar.delegate = self
            controllerSearch.definesPresentationContext = true
            controllerSearch.hidesNavigationBarDuringPresentation = false
            controllerSearch.dimsBackgroundDuringPresentation = false
            controllerSearch.searchResultsUpdater = self
            controllerSearch.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controllerSearch.searchBar
            return controllerSearch
        })()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.tableView.reloadData()
    }
    
    
    // MARK: - var and let
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    
    // MARK: - UISearchController and its functions 
    var searchController: UISearchController!
    var searchPredicate: NSPredicate!
    var searchArray: [Playlist]?
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText != nil {
            searchPredicate = NSPredicate(format: "playlistName contains[c] %@", searchText!)
            searchArray = fetchedResultsController.fetchedObjects?.filter() {
                return self.searchPredicate.evaluateWithObject($0)
            } as? [Playlist]
            self.tableView.reloadData()
        }
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(searchController)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchPredicate = nil
        searchArray?.removeAll(keepCapacity: false)
        tableView.reloadData()
    }
    
    // MARK: - IBAction
    @IBAction func moveToAddData(sender: UIBarButtonItem) {
        performSegueWithIdentifier("addSong", sender: self)
    }
    
    // MARK: - NSFetchedResultsController and its functions
    
    var fetchedResultsController: NSFetchedResultsController!
    
    func fetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Playlist")
        let sortDescriptor = NSSortDescriptor(key: "playlistName", ascending: true)
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 50
        return fetchRequest
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchPredicate == nil {
            return fetchedResultsController.sections?.count ?? 0
        } else {
            return 1 ?? 0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchPredicate == nil {

            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        } else {
            return searchArray?.count ?? 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellPlaylist", forIndexPath: indexPath) as! PlaylistTableViewCell
        if searchPredicate == nil {
        if let dataForCell = fetchedResultsController.objectAtIndexPath(indexPath) as? Playlist {
            let image = UIImage(data: dataForCell.playlistCoverImage)
            cell.namePlaylistLabel?.text = dataForCell.playlistName
            cell.numberOfSongPlaylistLabel?.text = nil
            cell.playlistImageView?.image = image
            }
        } else {
            let dataFromSearch = searchArray?[indexPath.row]
            let image = UIImage(data: dataFromSearch!.playlistCoverImage)
            cell.namePlaylistLabel?.text = dataFromSearch?.playlistName
            cell.playlistImageView?.image = image
            }
        return cell
    }
    
   // MARK: - controller functions
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
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
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Update:
            tableView.cellForRowAtIndexPath(indexPath!)
            break
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            managedObjectContext.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            do {
                try managedObjectContext.save()
            } catch _ {
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            managedObjectContext.insertObject(fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            do {
                try managedObjectContext.save()
            } catch _ {
            }
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        if searchPredicate == nil {
            print(fetchedResultsController.objectAtIndexPath(indexPath))
            performSegueWithIdentifier("showFromPlaylist", sender: self)
        } else {
            performSegueWithIdentifier("searchSegue", sender: self)
        }
    }
    
    @IBAction func unwindToPlaylistTVC(storyboard: UIStoryboardSegue) {
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFromPlaylist" {
            let sfptvc = segue.destinationViewController as! SongFromPlaylistTVC
            let index = tableView.indexPathForSelectedRow!
            let object = fetchedResultsController.objectAtIndexPath(index) as! Playlist
            
            sfptvc.playlistData = object
        } else if segue.identifier == "searchSegue" {
            let tvcFromSearch = segue.destinationViewController as! FromSearchTableViewController
            let indexRow = tableView.indexPathForSelectedRow!.row
            let currentPlaylist = searchArray![indexRow]
            tvcFromSearch.datePlaylist = currentPlaylist.playlistCreatedDate
//            NSLog("current playlist is %@", currentPlaylist)
        }
    }

}
