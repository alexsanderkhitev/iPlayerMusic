//
//  WebVC.swift
//  iPlayer Music
//
//  Created by Alexsander  on 9/20/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation


class WebVC: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UIWebViewDelegate, AVAssetResourceLoaderDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        webView.delegate = self
        webView.allowsLinkPreview = true
        webView.allowsInlineMediaPlayback = true //
        activityIndicatorView.hidden = true
        searchController = ({
            let controllerSearch = UISearchController(searchResultsController: nil)
            controllerSearch.delegate = self
            controllerSearch.searchBar.delegate = self
            controllerSearch.searchBar.searchBarStyle = UISearchBarStyle.Prominent
            controllerSearch.dimsBackgroundDuringPresentation = false
            controllerSearch.hidesNavigationBarDuringPresentation = false // false
            controllerSearch.searchBar.searchBarStyle = UISearchBarStyle.Default
            controllerSearch.searchResultsUpdater = self
            // text search
            controllerSearch.searchBar.placeholder = "Write address of site"
            // placing
            controllerSearch.searchBar.sizeToFit()
            navigationItemSearch.titleView = controllerSearch.searchBar
            //
            controllerSearch.searchBar.spellCheckingType = UITextSpellCheckingType.Yes
            controllerSearch.searchBar.autocapitalizationType = UITextAutocapitalizationType.None
            controllerSearch.searchBar.keyboardType = UIKeyboardType.WebSearch
            return controllerSearch
        })()
        let googleURL = NSURL(string: "http://www.google.com")!
        let requestGoogle = NSURLRequest(URL: googleURL)
        webView.loadRequest(requestGoogle)
        
//        print(searchController.searchBar.frame)
        let locale = NSLocale.preferredLanguages().first!
        let localeArray = locale.componentsSeparatedByString("-")
        languageString = localeArray.first!
//        NSLog("%@", languageString.lowercaseString)
        
        buttonHideTabBar.image = UIImage(named: "Down30.png")
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - var and let
    var languageString = String()
    var startLink = NSURL()
    var pageURLBool = false
    let fileManager = NSFileManager.defaultManager()
    var boolFirstPage = false
    
    // MARK: - IBOutlet 
   
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var navigationItemSearch: UINavigationItem!
    @IBOutlet weak var buttonHideTabBar: UIBarItem!
    @IBOutlet weak var toolBarWeb: UIToolbar!
    
    // MARK: - IBAction func for control web view
    @IBAction func previousWeb(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func nextWeb(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func reloadData(sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @IBAction func actioView(sender: UIBarButtonItem) {
        if boolFirstPage == true {
            let currentLink = webView.request!.mainDocumentURL!
            let actionController = UIActivityViewController.init(activityItems: [currentLink], applicationActivities: nil)
            presentViewController(actionController, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonHome(sender: UIBarButtonItem) {
        let url = NSURL(string: "http://www.google.com")!
        let requestNSURL = NSURLRequest(URL: url)
        webView.loadRequest(requestNSURL)
    }
    
    var hiddenTabBar = false
    
    var standartToolBarFrame: CGRect!
    var standartWebViewFrame: CGRect!
    
    @IBAction func hideTabBar(sender: UIBarButtonItem) {
        if hiddenTabBar == false {
            self.tabBarController?.tabBar.hidden = true
            standartToolBarFrame = toolBarWeb.frame
            standartWebViewFrame = webView.frame
            toolBarWeb.frame = CGRectMake(0, self.toolBarWeb.frame.origin.y+49, self.view.frame.size.width, 44)
            webView.frame = CGRectMake(0, self.webView.frame.origin.y+49, self.webView.frame.size.width, self.webView.frame.size.height)
            buttonHideTabBar.image = UIImage(named: "Up30.png")
            hiddenTabBar = true
        } else {
            self.tabBarController?.tabBar.hidden = false
            toolBarWeb.frame = standartToolBarFrame
            webView.frame = standartWebViewFrame
            buttonHideTabBar.image = UIImage(named: "Down30.png")
            hiddenTabBar = false
        }
    }
    
    // MARK: - WebView
    @IBOutlet weak var webView: UIWebView!
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        
    }
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicatorView.stopAnimating()
        boolFirstPage = true
    }

    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if error!.code == -1009 {
            let alertController = UIAlertController(title: "Your iPhone doesn't connect to Internet", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
            activityIndicatorView.stopAnimating()
        }
    }

    // title for song and artist 
    var songTitleSave: String!
    var artistTitleSave: String!
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        songTitleSave = nil
        artistTitleSave = nil
        if request.mainDocumentURL!.pathExtension == "mp3" {
            let urlItem = AVPlayerItem(URL: request.mainDocumentURL!)
            let commonMetaData = urlItem.asset.commonMetadata
            for item in commonMetaData {
                if item.commonKey == "title" {
                    print(item.stringValue)
                    songTitleSave = item.stringValue
                }
                if item.commonKey == "artist" {
                    print(item.stringValue)
                    artistTitleSave = item.stringValue
                }
            }
            let dataToSave = NSData(contentsOfURL: request.mainDocumentURL!)!
            let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last!.path!
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                dataToSave.writeToFile(directory.stringByAppendingString("/\(self.artistTitleSave)-\(self.songTitleSave).mp3"), atomically: true)
            })
            let alertController = UIAlertController(title: "Song is downloading", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alertController, animated: true, completion: nil)
            let digit = 1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(digit))
            dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            
            return false
        } else {
            return true
        }
    }
    
   
    
    // MARK: - UISearchController
    var searchController: UISearchController!

    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        let text = searchController.searchBar.text!
//        
//        if text.containsString("www.") {
//            let url = NSURL(string: "http://\(text)")!
//            let request = NSURLRequest(URL: url)
//            webView.loadRequest(request)
//        } else {
//            let url = NSURL(string: "https://www.google.com/?gfe_rd=cr&ei=EQMAVrWWAe7nwAON867QAw#newwindow=1&q=\(text)")!
//            let request = NSURLRequest(URL: url)
//            webView.loadRequest(request)
//        }

    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(searchController)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let text = searchController.searchBar.text!
        if text.containsString("www.") {
            let url = NSURL(string: "http://\(text)")!
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        } /*else {
           if text.containsString(" ") == false {
            if languageString == "en" {
                languageString = "com"
            }
            NSLog("This test %@", text)
            let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(text)")!
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
            } else if text.containsString(" ") == true {
            if languageString == "en" {
                languageString = "com"
            }
            print(languageString)
                let arW = text.componentsSeparatedByString(" ")
                let digit = arW.count
                switch digit {
                case 2:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 3:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 4:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])+\(arW[3])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 5:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])+\(arW[3])+\(arW[4])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 6:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])+\(arW[3])+\(arW[4])+\(arW[5])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 7:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])+\(arW[3])+\(arW[4])+\(arW[5])+\(arW[6])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 8:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])+\(arW[3])+\(arW[4])+\(arW[5])+\(arW[6])+\(arW[7])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 9:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])+\(arW[3])+\(arW[4])+\(arW[5])+\(arW[6])+\(arW[7])+\(arW[8])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 10:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])+\(arW[3])+\(arW[4])+\(arW[5])+\(arW[6])+\(arW[7])+\(arW[8])+\(arW[9])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 11:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])+\(arW[3])+\(arW[4])+\(arW[5])+\(arW[6])+\(arW[7])+\(arW[8])+\(arW[9])+\(arW[10])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 12:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])+\(arW[3])+\(arW[4])+\(arW[5])+\(arW[6])+\(arW[7])+\(arW[8])+\(arW[9])+\(arW[10])+\(arW[11])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                case 13:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])+\(arW[2])+\(arW[3])+\(arW[4])+\(arW[5])+\(arW[6])+\(arW[7])+\(arW[8])+\(arW[9])+\(arW[10])+\(arW[11])+\(arW[12])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                default:
                    let url = NSURL(string: "https://www.google.\(languageString)/#newwindow=1&q=\(arW[0])+\(arW[1])")!
                    let request = NSURLRequest(URL: url)
                    webView.loadRequest(request)
                }
            }
        } */
    }
    
    
    // MARK: - downloading functions
    
  

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
