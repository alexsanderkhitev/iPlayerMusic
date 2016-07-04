////
////  SongTableViewController.swift
////  Music
////
////  Created by Александр Хитёв on 7/17/15.
////  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
////
//
//import UIKit
//import Foundation
//import CoreData
//import MediaPlayer
//import AVFoundation
//import CoreAudio
//
//class SongITWorks: UITableViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UINavigationControllerDelegate, NSFileManagerDelegate  {
//    // MARK: - var and lets
//    var appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
//    var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest(), managedObjectContext: context, sectionNameKeyPath: "nameSong", cacheName: "nameSong")
//        fetchedResultsController.delegate = self
//        fetchedResultsController.performFetch(nil)
//        
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()
//        
//        searchController = ({
//            var controllerSearch = UISearchController(searchResultsController: nil)
//            controllerSearch.delegate = self
//            controllerSearch.searchBar.delegate = self
//            controllerSearch.hidesNavigationBarDuringPresentation = true
//            controllerSearch.definesPresentationContext = false
//            controllerSearch.dimsBackgroundDuringPresentation = false
//            controllerSearch.searchBar.sizeToFit()
//            controllerSearch.searchResultsUpdater = self
//            self.tableView.tableHeaderView = controllerSearch.searchBar
//            return controllerSearch
//        })()
//        //
//        fetchFilesFromFolder()
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        searchPredicate = nil
//        filteredData = nil
//        self.tableView.reloadData()
//        // if need to delete and add file from application need fetchFilesFromFolder
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    // MARK: - NSFetchedResultsController and its functions
//    var fetchedResultsController: NSFetchedResultsController!
//    
//    func fetchRequest() -> NSFetchRequest {
//        var fetchRequest = NSFetchRequest(entityName: "Song")
//        var sort = NSSortDescriptor(key: "nameSong", ascending: false)
//        fetchRequest.fetchBatchSize = 50
//        fetchRequest.predicate = nil
//        fetchRequest.sortDescriptors = [sort]
//        return fetchRequest
//    }
//    
//    // MARK: - UISearchController and its functions
//    var searchController: UISearchController!
//    var searchPredicate: NSPredicate!
//    var filteredData: [Song]? = nil
//    
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        var searchText = searchController.searchBar.text
//        if searchText != nil {
//            searchPredicate = NSPredicate(format: "nameSong contains[c] %@", searchText)
//            filteredData = fetchedResultsController.fetchedObjects!.filter() {
//                return self.searchPredicate.evaluateWithObject($0)
//                } as? [Song]
//            self.tableView.reloadData()
//        }
//    }
//    
//    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        updateSearchResultsForSearchController(searchController)
//    }
//    
//    func didDismissSearchController(searchController: UISearchController) {
//        searchPredicate = nil
//        filteredData = nil
//        self.tableView.reloadData()
//    }
//    
//    // MARK: - Files from shared folder
//    
//    var listOfMP3Files: Array<String!>? // for Cell data
//    
//    func fetchFilesFromFolder() {
//        var fileManager = NSFileManager.defaultManager()
//        
//        var folderPathURL = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)[0] as! NSURL
//        
//        var documentsContent = fileManager.contentsOfDirectoryAtPath(folderPathURL.path!, error: nil)
//            println(documentsContent)
//        
//        if var directoryURLs = fileManager.contentsOfDirectoryAtURL(folderPathURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, error: nil) {
//            println(directoryURLs)
//            
//            var mp3Files = directoryURLs.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "mp3" }
//            //pathExtension "mp3"
//            listOfMP3Files = mp3Files
//            
//            println(mp3Files)
//        }
//    }
//    
//    // MARK: - Table view data source
//    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        if searchPredicate == nil {
//            //return fetchedResultsController?.sections?.count ?? 0
//            return 1 ?? 0
//        } else {
//            return 1 ?? 0
//        }
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if searchPredicate == nil {
//            //return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
//            return listOfMP3Files?.count ?? 0
//        } else {
//            return filteredData?.count ?? 0
//        }
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("songID", forIndexPath: indexPath) as! UITableViewCell
//        
//        if searchPredicate == nil {
//            if var data = listOfMP3Files?[indexPath.row] {
//                cell.textLabel?.text = data  // data
//            }
//        } else {
//            if var filteredSearch = filteredData?[indexPath.row] {
//                cell.textLabel?.text = filteredSearch.nameSong
//            }
//        }
//        return cell
//    }
//    
//    // Override to support conditional editing of the table view.
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return NO if you do not want the specified item to be editable.
//        return true
//    }
//    
//    // Override to support editing the table view.
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            context.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
//            context.save(nil)
//        } else if editingStyle == .Insert {
//            context.insertObject(fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
//            context.save(nil)
//        }
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        switch type {
//        case NSFetchedResultsChangeType.Insert:
//            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
//            break
//        case NSFetchedResultsChangeType.Delete:
//            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
//            break
//        case NSFetchedResultsChangeType.Move:
//            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
//            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
//            break
//        case NSFetchedResultsChangeType.Update:
//            break
//        default: break
//            
//        }
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        switch type {
//        case NSFetchedResultsChangeType.Insert:
//            tableView.insertRowsAtIndexPaths([AnyObject](), withRowAnimation: UITableViewRowAnimation.Fade)
//            break
//        case NSFetchedResultsChangeType.Delete:
//            tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
//            break
//        case NSFetchedResultsChangeType.Move:
//            tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
//            tableView.insertRowsAtIndexPaths(NSArray(object: indexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
//            break
//        case NSFetchedResultsChangeType.Update:
//            tableView.cellForRowAtIndexPath(indexPath!)
//            break
//        default: break
//        }
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        tableView.endUpdates()
//    }
//    
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        tableView.beginUpdates()
//    }
//    
//    /*
//    // Override to support rearranging the table view.
//    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
//    
//    }
//    */
//    
//    // Override to support conditional rearranging of the table view.
//    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return NO if you do not want the item to be re-orderable.
//        return true
//    }
//    
//    // MARK: - Navigation
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
//        performSegueWithIdentifier("listenMusic", sender: nil)
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        var playerVC = (segue.destinationViewController as! UINavigationController).topViewController as! PlayMusicViewController
//        var indexPath = tableView.indexPathForSelectedRow()
//        var objectForPass = listOfMP3Files![indexPath!.row] // default
//        //
//      /*  var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as? String
//        var getImage = path?.stringByAppendingPathComponent(objectForPass)
//        var image = UIImage(contentsOfFile: getImage!) */
//        //
//        var fileManager = NSFileManager.defaultManager()
//        
//        var wayToFile = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
//        var passMusicFileURL: NSURL? // for pass mp3
//        
//        if let documentPath: NSURL = wayToFile.first as? NSURL {
//            let musicFile = documentPath.URLByAppendingPathComponent(objectForPass)
//            println(musicFile)
//            passMusicFileURL = musicFile
//        }
//        if segue.identifier == "listenMusic" {
//           // playerVC.musicFile = objectForPass
//            playerVC.mp3URL = passMusicFileURL
//        }
//    }
//
//}
