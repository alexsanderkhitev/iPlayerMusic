//
//  SongTableViewController.swift
//  Music
//
//  Created by Александр Хитёв on 7/17/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import AVFoundation
import CoreSpotlight
import MobileCoreServices


class SongTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, NSFileManagerDelegate, AVAudioPlayerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating  {
    
    // MARK: - var and lets
    var appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
    var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var fileManager = NSFileManager.defaultManager()
    let userDefault = NSUserDefaults.standardUserDefaults()
    
    
    // MARK: - vars for spotlight check for opens need files
    var boolCheckSpot: Bool!
    var identifierCheckSpot: String!
    
    // MARK: - spotlight var and let
    var spotlightMainArray = [CSSearchableItem]() // it is main array for spotlight search in which I saved Search item
    var spotlightKeyword = [String]()

    var spotlightDictionary = [String : String]()
    var arrayForCheckSpot = [String]()
    
    // MARK: - override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFilesFromFolder()
        self.tabBarController!.tabBar.hidden = false
        self.definesPresentationContext = true
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        searchController = ({
            let controllerSearch = UISearchController(searchResultsController: nil)
            controllerSearch.delegate = self
            controllerSearch.searchBar.delegate = self
            controllerSearch.hidesNavigationBarDuringPresentation = false
            controllerSearch.definesPresentationContext = true //
            controllerSearch.searchResultsUpdater = self
            controllerSearch.searchBar.sizeToFit()
            controllerSearch.dimsBackgroundDuringPresentation = false
            self.tableView.tableHeaderView = controllerSearch.searchBar
            return controllerSearch
        })()
        
        var first = 0
        for item in listOfMP3Files {
            var spotlightTitle: String!
            var spotlightArtist: String!
            let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
            let url = directory.URLByAppendingPathComponent(item)
            let playerItem = AVPlayerItem(URL: url)
            let commonMetadata = playerItem.asset.commonMetadata
            for dataSong in commonMetadata {
                if dataSong.commonKey == "title" {
                    spotlightTitle = dataSong.stringValue
                }
                if dataSong.commonKey == "artist" {
                    spotlightArtist = dataSong.stringValue
                }
                // this end loop for metadata
            }
            
            // dictionary use like arrays
            spotlightDictionary[spotlightTitle] = spotlightArtist
            arrayForCheckSpot.append(spotlightTitle)
       }
        
        for titleItemSpot in spotlightDictionary.keys {
            first++ // need don't remove
            let artistArray = Array(spotlightDictionary.values) as [String]
            let descriptionSpot = artistArray[first-1]
            // add keyword
            let newKeywordOne = titleItemSpot.componentsSeparatedByString(" ")
            let newKeywordTwo = descriptionSpot.componentsSeparatedByString(" ")
//            print(newKeywordOne, newKeywordOne.count)
            spotlightKeyword = newKeywordOne + newKeywordTwo
            
            let spotSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            spotSet.title = titleItemSpot
            spotSet.contentDescription = descriptionSpot
            
            spotSet.keywords = spotlightKeyword
            
            let searchItemSpot = CSSearchableItem(uniqueIdentifier: titleItemSpot, domainIdentifier: "com.alexsander.iplayer.search", attributeSet: spotSet)
            spotlightMainArray.append(searchItemSpot)
        }
        
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(spotlightMainArray) { (error) -> Void in
            if error == nil {
                print("Spotlight main array works")
            } else {
                print(error?.localizedDescription)
            }
        }
        
//        print(spotlightMainArray.count)
        // this end of spotlight
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        self.tabBarController!.tabBar.hidden = false
        fetchFilesFromFolder()
        //
        checkSpotlightResult()
    }
    
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UISearchController and its functions
    
    var searchController: UISearchController!
    var searchPredicate: NSPredicate!
    var arraySearchResults = [String]()
    var arraySearchNames = [String]()
    //
    var nameSongFromSearchC: String!
    var nameAlbumFromSearchC: String!
    var nameArtistFromSearchC: String!
    var imageDataFromSearchC: NSData!
    //
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        arraySearchNames.removeAll(keepCapacity: false)
        for dataFromMP3 in listOfMP3Files {
            let directoryFolder = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
            var megaURL: NSURL!
            let url = directoryFolder.first!
            megaURL = url.URLByAppendingPathComponent(dataFromMP3)
          
            let playerItem = AVPlayerItem(URL: megaURL)
            let commonMetaData = playerItem.asset.commonMetadata 
            for item in commonMetaData {
                if item.commonKey == "title" {
                    nameSongFromSearchC = item.stringValue
                    arraySearchNames.append(nameSongFromSearchC)
                }
                if item.commonKey == "artist" {
                    nameArtistFromSearchC = item.stringValue
                }
                if item.commonKey == "album" {
                    nameAlbumFromSearchC = item.stringValue
                }
                if item.commonKey == "artwork" {
                    imageDataFromSearchC = item.dataValue
                }
            }
        }
        
        let arrayForPredicate = arraySearchNames as NSArray
        if searchText != nil {
            searchPredicate = NSPredicate(format: "self contains [c] %@", searchText!)
            arraySearchResults = arrayForPredicate.filteredArrayUsingPredicate(searchPredicate) as! [String]
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
    
    // MARK: - spotlight function which opens need file
    
    func checkSpotlightResult() {
        print("checkSpotlightResult")
        boolCheckSpot = userDefault.boolForKey("spotlightBool")
        if boolCheckSpot != nil {
            if boolCheckSpot == true {
            identifierCheckSpot = userDefault.valueForKey("spotlightIdentifier") as! String
            if arrayForCheckSpot.contains(identifierCheckSpot) {
//                print("Array title contains \(identifierCheckSpot)")
                let index = arrayForCheckSpot.indexOf(identifierCheckSpot)!
                let myIndexPath = NSIndexPath(forRow: index, inSection: 0)
                print(myIndexPath)
                self.tableView.selectRowAtIndexPath(myIndexPath, animated: true, scrollPosition: .None)
                self.performSegueWithIdentifier("listenMusic", sender: self)
                userDefault.setBool(false, forKey: "spotlightBool")
                }
            }
        }
    }
    

    
    // MARK: - NSFetchedResultsController and its functions
    
  

    @IBAction func unwindSongTVC(segue: UIStoryboardSegue) {
        
    }
  
    // MARK: - Files from shared folder
    var listOfMP3Files = [String]() // for Cell data //Array<String!>?
    
    func fetchFilesFromFolder() {
        let fileManager = NSFileManager.defaultManager()
        let folderPathURL = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)[0]
        if let directoryURLs = try? fileManager.contentsOfDirectoryAtURL(folderPathURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles) {
            listOfMP3Files = directoryURLs.filter(){ $0.pathExtension! == "mp3" }.map(){ $0.lastPathComponent! }
        }
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
            return listOfMP3Files.count ?? 0
        } else {
            return arraySearchResults.count ?? 0
        }
    }
    
    // MARK: - export name
    var nameForTitle: String?
    var artistForTitle: String?
    var albumForTitle: String?
    
//    func exportName() {
//        let indexPath = NSIndexPath()
//        //
//        let fileName = listOfMP3Files[indexPath.row]
//        print(listOfMP3Files)
//        
//        let fileManager = NSFileManager.defaultManager()
//        let urlOfFile = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
//        var mp3PathForPass: NSURL?
//        
//        let url: NSURL = urlOfFile.first!
//        let mp3Path = url.URLByAppendingPathComponent(fileName)
//        mp3PathForPass = mp3Path
//        
//        let fileFrom = AVPlayerItem(URL: mp3PathForPass!)
//        let commonMetadata = fileFrom.asset.commonMetadata 
//        
//        for item in commonMetadata {
//            if item.commonKey == "title" {
//                nameForTitle = item.stringValue
//               // println("name for title \(nameForTitle)")
//            }
//            if item.commonKey == "artist" {
//                artistForTitle = item.stringValue
//             //   println(artistForTitle)
//            }
//            if item.commonKey == "album" {
//                albumForTitle = item.stringValue
//            }
//        }
//    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songID", forIndexPath: indexPath) as! SongsCellTableView // UITableViewCell
        if searchPredicate == nil {
                let data = listOfMP3Files[indexPath.row]
                let itemFromFolder = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
                var urlMeta: NSURL!
                
                let urlFromFolder: NSURL = itemFromFolder.first!
                urlMeta = urlFromFolder.URLByAppendingPathComponent(data)
                
                var nameSong: String!
                var nameArtist: String!
                var nameAlbum: String!
                var imageData: NSData! // for imageView in uitableViewCell
                
                let metaItem = AVPlayerItem(URL: urlMeta)
                let arrayMetaData = metaItem.asset.commonMetadata 
               // println("array meta data \(arrayMetaData)")
                for item in arrayMetaData {
                    if item.commonKey == "title" {
                        nameSong = item.stringValue
                    }
                    if item.commonKey == "artist" {
                        nameArtist = item.stringValue
                    }
                    if item.commonKey == "album" {
                        nameAlbum = item.stringValue
                    }
                    if item.commonKey == "artwork" {
                        imageData = item.dataValue
                    }
                }
                
                var nameArtistForCell: String!
                var nameAlbumForCell: String!
                if nameArtist != nil {
                    nameArtistForCell = nameArtist
                } else {
                    nameArtistForCell = ""
                }
                if nameAlbum != nil {
                    nameAlbumForCell = nameAlbum
                }
                
                cell.nameSongLabel?.text = nameSong
                if nameAlbumForCell != nil {
                cell.nameArtistAlbumLabel?.text = "\(nameArtistForCell) - \(nameAlbumForCell)"
                } else {
                    cell.nameArtistAlbumLabel?.text = "\(nameArtistForCell)"
                }
                if imageData != nil {
                cell.imageViewArtwork?.image = UIImage(data: imageData)
                } else {
                    cell.imageViewArtwork.image = UIImage(named: "Notes100.png")
                }
        } else {
            let urlFolder = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
            let arrayContents = try! fileManager.contentsOfDirectoryAtURL(urlFolder, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            let arrayFilteredContens = arrayContents.filter(){ $0.pathExtension! == "mp3"}.map(){ $0.lastPathComponent! }
            // names and other data for cell
            var megaURL: NSURL!
            var nameTitleSong: String!
            var nameArtistSong: String!
            var nameAlbumSong: String!
            var dataImageSong: NSData!
            let dataFromArray = arraySearchResults[indexPath.row]
            //
            for itemArray in arrayFilteredContens {
//                let folder = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
                let url = urlFolder
                    megaURL = url.URLByAppendingPathComponent(itemArray)
                let playerItem = AVPlayerItem(URL: megaURL)
                let commonMetaData = playerItem.asset.commonMetadata 
                for itemMD in commonMetaData {
                    if itemMD.commonKey == "title" {
                        nameTitleSong = itemMD.stringValue
                    }
                    if itemMD.commonKey == "artist" {
                        nameArtistSong = itemMD.stringValue
                    }
                    if itemMD.commonKey == "album" {
                        nameAlbumSong = itemMD.stringValue
                    }
                    if nameTitleSong == dataFromArray {
                    if itemMD.commonKey == "artwork" {
                        dataImageSong = itemMD.dataValue
                    }
                    }
                }
                
                if nameTitleSong == dataFromArray {
                    cell.nameSongLabel.text = nameTitleSong
                    if nameAlbumSong != nil {
                        cell.nameArtistAlbumLabel.text = "\(nameArtistSong) - \(nameAlbumSong)"
                    } else {
                        cell.nameArtistAlbumLabel.text = nameArtistSong
                    }
                    if dataImageSong != nil  {
                        cell.imageViewArtwork.image = UIImage(data: dataImageSong)
                    } else {
                        cell.imageViewArtwork.image = UIImage(named: "Notes100.png")
                    }
                }
            }
        }
        return cell
    }
    
    // MARK: - editing table
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let currentSong = listOfMP3Files[indexPath.row]
            print(currentSong)
            var identifierSpot: String!
            let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
            let url = directory.URLByAppendingPathComponent(currentSong)
            // I receive metaData here 
            let playerItem = AVPlayerItem(URL: url)
            let commonMetadata = playerItem.asset.commonMetadata
            for item in commonMetadata {
                if item.commonKey == "title" {
                    identifierSpot = item.stringValue
                }
            }
            
            //
            do {
                //            println(url)
    //            println(indexPath)
                try fileManager.removeItemAtURL(url)
            } catch _ {
            }
//            fetchFilesFromFolder()
//            tableView.reloadData()
            tableView.beginUpdates()
            listOfMP3Files.removeAtIndex(indexPath.row) //Add this line
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.endUpdates()
            
//            print("Super url!!!!! \(url)")
          // MARK: - Spotlight delete object from search
            CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers([identifierSpot], completionHandler: { (error) -> Void in
                if error == nil {
                    print("This launch is successful")
                } else {
                    print(error?.localizedDescription)
                }
            })
            //
        } else if editingStyle == .Insert {
            
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
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        if searchPredicate == nil {
            performSegueWithIdentifier("listenMusic", sender: self)
        } else {
            performSegueWithIdentifier("oneSound", sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "listenMusic" {

        if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer != nil {
            if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.playing {
                (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
            }
        }
            let playerVC = segue.destinationViewController as! PlayMusicViewController

            // variant the second
            let curRow = tableView.indexPathForSelectedRow!.row
            playerVC.arrayOfMP3 = listOfMP3Files
            playerVC.currentRow = curRow
//            println(listOfMP3Files[curRow])
      } else if segue.identifier == "oneSound" {
        if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer != nil {
           if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.playing {
                (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
                }
            }
        let playerFromOne = segue.destinationViewController as! PlayerFromOneTable
        let currentIndex = tableView.indexPathForSelectedRow!.row
        let currentTrackPass = arraySearchResults[currentIndex]
//        var currentIndexPath = tableView.indexPathForSelectedRow()
        playerFromOne.currentTrack = currentTrackPass
//        NSLog("Current track passs %@", currentTrackPass)
        }
    }
    


}
