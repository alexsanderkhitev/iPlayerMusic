//
//  ArtistTableViewController.swift
//  Music
//
//  Created by Александр Хитёв on 7/27/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

class ArtistTableViewController: UITableViewController, UINavigationControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    // MARK: - override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        exportData()
        
        filter()
        self.tabBarController?.tabBar.hidden = false
        self.definesPresentationContext = true
        //
        searchController = ({
            let searchResultsController = UISearchController(searchResultsController: nil)
            searchResultsController.delegate = self
            searchResultsController.searchBar.delegate = self
            searchResultsController.definesPresentationContext = true
            searchResultsController.hidesNavigationBarDuringPresentation = false
            searchResultsController.dimsBackgroundDuringPresentation = false
            searchResultsController.searchBar.sizeToFit()
            searchResultsController.searchResultsUpdater = self
            self.tableView.tableHeaderView = searchResultsController.searchBar
            return searchResultsController
        })()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        exportData()
        //
    }
    
    
    // MARK: UISearch controller and its functions
    var searchController: UISearchController!
    var searchPredicate: NSPredicate!
    var arrayFromSearchController = [String]()
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText != nil {
            searchPredicate = NSPredicate(format: "self contains [c] %@", searchText!)
            let arrayForSearch = filterArray as NSArray
            arrayFromSearchController = arrayForSearch.filteredArrayUsingPredicate(searchPredicate) as! [String]
        }
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(searchController)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchPredicate = nil
        self.tableView.reloadData()
    }
    
    // MARK: - var and let
    
    var fileManager = NSFileManager.defaultManager()

    // MARK: - Export name 
    var mp3Files = [String]()
    func exportData() {
//        var generalURL: [AnyObject]?
//        var arrayFiles: Array<NSURL!>!
        let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        let urlFromDirectory = directory.first!
       
        let file = try! fileManager.contentsOfDirectoryAtURL(urlFromDirectory, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
//        println("file \(file)")
        
        mp3Files = file.filter(){ $0.pathExtension! == "mp3" }.map(){ $0.lastPathComponent! }
    }
    
    // MARK: - filter function
    var superArray = [String]()
    var filterArray = [String]()
    func filter() {
//        var proString: String!
        for proItem in mp3Files {
            let proFolder = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
            var americaURL: NSURL!
            let proURL: NSURL = proFolder.first!
            americaURL = proURL.URLByAppendingPathComponent(proItem)
            let proPlayerItem = AVPlayerItem(URL: americaURL)
            let proData = proPlayerItem.asset.commonMetadata 
            for proFiles in proData {
                if proFiles.commonKey == "artist" {
                    superArray.append(proFiles.stringValue!)
                }
            }
        }
        filterArray = Array(Set(superArray))
        filterArray.sortInPlace(){ $0 < $1 }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchPredicate == nil {
            return filterArray.count ?? 0
        } else {
            return arrayFromSearchController.count ?? 0
        }
    }

    var nameArtist: String!
    var nameArtistSearch: String!
    
    var cellStrings: String!
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        if searchPredicate == nil {
            nameArtist = filterArray[indexPath.row]
            cell.textLabel?.text = nameArtist
        } else {
            nameArtistSearch = arrayFromSearchController[indexPath.row]
            cell.textLabel?.text = nameArtistSearch
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        if searchPredicate == nil {
            performSegueWithIdentifier("goArtist", sender: self)
        } else {
            performSegueWithIdentifier("goFromSearchArtist", sender: self)
        }
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goArtist" {
            let sfatvc = segue.destinationViewController as! SongsFromArtistTVC
                let indexPath = tableView.indexPathForSelectedRow!.row
                let passCurrentNameArtist = filterArray[indexPath]
//                var index = tableView.indexPathForSelectedRow!
                sfatvc.indexCurrentSelect = indexPath
                sfatvc.currentArtist = passCurrentNameArtist
        } else if segue.identifier == "goFromSearchArtist" {
            let tv = segue.destinationViewController as! SongsFromArtistTVC
            let indexPath = tableView.indexPathForSelectedRow!.row
            let passCurrentNameArtist = arrayFromSearchController[indexPath]
            tv.indexCurrentSelect = indexPath
            tv.currentArtist = passCurrentNameArtist
        }
    }

}
