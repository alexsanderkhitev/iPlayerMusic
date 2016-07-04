//
//  SongsFromArtistTVC.swift
//  Music
//
//  Created by Александр Хитёв on 7/27/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

class SongsFromArtistTVC: UITableViewController, UINavigationControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    // MARK: - override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        exportFiles()
        arrayNeedFles()
        self.navigationItem.title = currentArtist
        self.tabBarController?.tabBar.hidden = true
        searchController = ({
            let controllerSearch = UISearchController(searchResultsController: nil)
            controllerSearch.delegate = self
            controllerSearch.searchBar.delegate = self
            controllerSearch.dimsBackgroundDuringPresentation = false
            controllerSearch.hidesNavigationBarDuringPresentation = false // default is true
            controllerSearch.searchResultsUpdater = self
            controllerSearch.definesPresentationContext = true
            controllerSearch.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controllerSearch.searchBar
            return controllerSearch
        })()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchPredicate = nil
        searchController.dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: - UISearchController and its functions
    var searchController: UISearchController!
    var searchPredicate: NSPredicate!
//    var filterArray = [String]()
    // this array contains names of mp3 files
    var arrayOfNames = [String]()
    var arrayFilterOfNames = [String]()
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // i get name for search
        var nameForSearch: String!
        for useName in arrayItem {
//            println("use name \(useName)")
            let folder = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
            var superURL: NSURL!
            let url: NSURL = folder.first!
            superURL = url.URLByAppendingPathComponent(useName)
            let playerItem = AVPlayerItem(URL: superURL)
            let comMetaData = playerItem.asset.commonMetadata 
            for item in comMetaData {
                if item.commonKey == "title" {
                    nameForSearch = item.stringValue
                    arrayOfNames.append(nameForSearch)
                }
            }
        }

//        println("array of names \(arrayOfNames) and count it \(arrayOfNames.count)")
        // Here was the arrayItem
        let searchText = searchController.searchBar.text
           if searchText != nil {
            searchPredicate = NSPredicate(format: "self contains[c] %@", searchText!)
//            println("search predicate \(searchPredicate)")
            let filteredArray = (arrayOfNames as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [String]
            arrayOfNames.removeAll(keepCapacity: false) // experiement
            arrayFilterOfNames = filteredArray
//            print("array filter of names \(arrayFilterOfNames) count \(arrayFilterOfNames.count)")
//            arrayFilterOfNames.removeAll(keepCapacity: false)
            self.tableView.reloadData()
        } else {
            self.tableView.reloadData()
        }
    }
    

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(searchController)
    }
    
  
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchController.active = false
        searchPredicate = nil
        arrayOfNames.removeAll(keepCapacity: false)
        arrayFilterOfNames.removeAll(keepCapacity: false)
        self.tableView.reloadData()
    }
    
    
    // MARK: - var and let
    var currentArtist = String() // it is general name
    var indexCurrentSelect = Int()
    //var arrayMP3 = [String]()
    var fileManager = NSFileManager.defaultManager()

    // name album
    var contentArray = [String]()
    var artistName: String!
    var nameArtist: String!
    var arrayContains = [String]()
    
    func exportFiles(){
        let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        var urlFromDirectory: NSURL!
        let urlForDirectory: NSURL = directory.first!
        urlFromDirectory = urlForDirectory
        let content = try! fileManager.contentsOfDirectoryAtURL(urlFromDirectory, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        contentArray = content.filter(){ $0.pathExtension! == "mp3" }.map(){ $0.lastPathComponent! } as [String]
        let stringFromContent = contentArray[indexCurrentSelect]
        var superURL: NSURL!
        let urlFromContent = directory.first!
        superURL = urlFromContent.URLByAppendingPathComponent(stringFromContent)
        let player = AVPlayerItem(URL: superURL)
        let metaData = player.asset.commonMetadata 
        for item in metaData {
            if item.commonKey == "artist" {
                nameArtist = item.stringValue
            }
        }
    }
    
    var nameSongForPass: String!
    var nameArtistForPass: String!
    var nameAlbumForPass: String!
    var imageSongForPass: NSData!
    var arrayItem = [String]()
    
    func arrayNeedFles(){
//        let stringFromArray = contentArray[indexCurrentSelect]
//        println("string string \(stringFromArray)")
//        let folder = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
//        var url: NSURL!
//        let urlFromFolder: NSURL = folder.first!
//        var url = urlFromFolder.URLByAppendingPathComponent(stringFromArray)

        var nameSpecificArtist: String!
//        var nameSpecificSound: String!
//        var nameSpecificAlbum: String!
//        var dataSpecificImage: NSData!
        //
        var passForMegaArray: String!
        for item in contentArray {
            passForMegaArray = item
            var urlForLoop: NSURL!
            let folder = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
            let urlInto: NSURL = folder.first!
            urlForLoop = urlInto.URLByAppendingPathComponent(item)
            let player = AVPlayerItem(URL: urlForLoop)
            let comData = player.asset.commonMetadata 
            for it in comData {
                if it.commonKey == "artist" {
                    nameSpecificArtist = it.stringValue
//                    println("name specific artist 1 \(nameSpecificArtist)")
                }
                if it.commonKey == "album" {
//                    nameSpecificAlbum = it.stringValue
                }
                if it.commonKey == "title" {
//                    nameSpecificSound = it.stringValue
                }
                if it.commonKey == "artwork" {
//                    dataSpecificImage = it.dataValue
                }
            }
            
            if nameSpecificArtist != currentArtist {
//               print("mac book pro")
            } else {
                arrayItem.append(passForMegaArray)
            }
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
            if searchPredicate == nil  {
                return arrayItem.count ?? 0
            } else {
                return arrayFilterOfNames.count ?? 0
            }
        }

        

    var filteredArray = [String]()
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("artistTwo", forIndexPath: indexPath) as! SongsCellArtist
        
        if searchPredicate == nil  {
        let currentString = arrayItem[indexPath.row]
        var urlULTRA: NSURL!
            let ultraDirectory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
            let ultraURL: NSURL = ultraDirectory.first!
            urlULTRA = ultraURL.URLByAppendingPathComponent(currentString)
            let ultraMediaPlayer = AVPlayerItem(URL: urlULTRA)
            let ultraCommonMetaData = ultraMediaPlayer.asset.commonMetadata 
            for ultraData in ultraCommonMetaData {
                if ultraData.commonKey == "title" {
//                    println("ultra data equals \(ultraData.stringValue)")
                    nameSongForPass = ultraData.stringValue
                }
                if ultraData.commonKey == "artist" {
                    nameArtistForPass = ultraData.stringValue
                }
                if ultraData.commonKey == "album" {
                    nameAlbumForPass = ultraData.stringValue
                }
                if ultraData.commonKey == "artwork" {
                    imageSongForPass = ultraData.dataValue
                }
            }

            cell.nameSong?.text = nameSongForPass
            if nameAlbumForPass != nil {
                cell.artistAlbumName?.text = "\(nameArtistForPass) - \(nameAlbumForPass)"
            } else {
                cell.artistAlbumName?.text = "\(nameArtistForPass)"
            }
        
            if imageSongForPass != nil {
                cell.imageSongs?.image = UIImage(data: imageSongForPass)
            } else {
                cell.imageSongs?.image = UIImage(named: "Notes100.png")
        }
        } else {
            let name: String! = arrayFilterOfNames[indexPath.row]
            cell.nameSong.text = name
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
    


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchPredicate == nil {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        performSegueWithIdentifier("playMusic", sender: nil)
        } else {
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            performSegueWithIdentifier("summer", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playMusic" {
            if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer != nil {
                if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.playing {
                    (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
                }
            }
            let playMVC = segue.destinationViewController as! PlayMusicVC
            let currentIndPass = tableView.indexPathForSelectedRow!.row
//            println("array item \(arrayItem)")
            playMVC.currentIndex = currentIndPass
            playMVC.arrayOfSongs = arrayItem
            searchController.active = false
        } else if segue.identifier == "summer" {
            if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer != nil {
                if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.playing {
                    (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
                }
            }
            let playVC = segue.destinationViewController as! PlayFromSearchVC
            let currentInt = tableView.indexPathForSelectedRow!.row
            playVC.currentSongString = arrayFilterOfNames[currentInt]
            searchController.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
    
   

