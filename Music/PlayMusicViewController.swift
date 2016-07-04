//
//  PlayMusicViewController.swift
//  Music
//
//  Created by Александр Хитёв on 7/19/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import CoreAudio
import MediaPlayer
import AVKit
import iAd


class PlayMusicViewController: UIViewController, AVAudioPlayerDelegate, UITabBarControllerDelegate, ADBannerViewDelegate {
    
    // MARK: - override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        playPauseButton.setImage(UIImage(named: "Pause32.png"), forState: UIControlState.Normal)
        volumeSlider()
        playMusic()
        timerForLabel = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timeForLabels"), userInfo: nil, repeats: true)
        self.tabBarController?.tabBar.hidden = true
        // 
        bannerAd.delegate = self
        bannerAd.hidden = true
        
        // notification for hide controller 
        
    
    }
   
    
    func volumeSlider() {
        let volumeViewChanger = MPVolumeView(frame: CGRectMake(8, 15, generakView.bounds.width-16, generakView.bounds.height))
        volumeViewChanger.showsVolumeSlider = true // default true
        volumeView.addSubview(volumeViewChanger)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        controlCenter()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
   
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            switch event!.subtype {
            case UIEventSubtype.RemoteControlPlay:
                playMusic()
                break
            case UIEventSubtype.RemoteControlPause:
                pause()
                break
            case UIEventSubtype.RemoteControlNextTrack:
                nextSound()
                break
            case UIEventSubtype.RemoteControlPreviousTrack:
                previous()
            default: break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: swipe IBAction
    
    @IBAction func rightSwipe(sender: UISwipeGestureRecognizer) {
        sender.direction = UISwipeGestureRecognizerDirection.Right
        previous()
    }
    @IBAction func leftSwipe(sender: UISwipeGestureRecognizer) {
        sender.direction = UISwipeGestureRecognizerDirection.Left
        nextSound()
    }
    // MARK: - var and let
    var tapButtonPlay = true // true
    var currentPause: NSTimeInterval!
    var timerForLabel: NSTimer!
    var fileManager = NSFileManager.defaultManager()
    var boolPause = false
    var superTimer: NSTimer!
    
    // MARK: - control center
    var nameOfSong: String!
    var nameOfArtist: String!
    var nameOfAlbum: String!
    var imageDataOfArtWork: NSData!

    func controlCenter() {
        let audioCenter = MPNowPlayingInfoCenter.defaultCenter()
        if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer != nil {
            audioCenter.nowPlayingInfo = [ MPMediaItemPropertyTitle: nameOfSong, MPMediaItemPropertyArtist: nameOfArtist, MPMediaItemPropertyPlaybackDuration: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration]
        }
    }
    
    
    // MARK: - IBOutlet and IBAction func
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var volumeView: UIView!
    // general view
    @IBOutlet weak var generakView: UIView!
    
    
    // MARK: - ADBannerView Outlet
    @IBOutlet weak var bannerAd: ADBannerView!

    // MARK: - IBAction func

    @IBAction func play(sender: UIButton) {
        if tapButtonPlay == true {
            tapButtonPlay = false
            pause()
          //  println(tapButtonPlay)
        } else {
            tapButtonPlay = true
            playMusic()
        }
    }
    
    var arrayOfMP3 = [String]() // I changed it
    var currentRow = Int()
    var timeForTimerNext: NSTimeInterval!
    
    func playMusic() {
        imageDataOfArtWork = nil
        let directory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        let currentSong = arrayOfMP3[currentRow]
        if currentRow == arrayOfMP3.endIndex-1 {
            maximumBool = true
        }
//        println("current song \(currentSong)")
        // export name for label
        var megaURL: NSURL!
        let url = directory.first!
            megaURL = url.URLByAppendingPathComponent(currentSong)
//        println("mega url \(megaURL)")
        let audioPlayerItem = AVPlayerItem(URL: megaURL)
        let commonMetaData = audioPlayerItem.asset.commonMetadata 

        for item in commonMetaData {
            if item.commonKey == "title" {
                nameOfSong = item.stringValue
            }
            if item.commonKey == "artist" {
                nameOfArtist = item.stringValue
            }
            if item.commonKey == "album" {
                nameOfAlbum = item.stringValue
            }
            if item.commonKey == "artwork" {
                imageDataOfArtWork = item.dataValue
            }
        }
        
        nameLabel.text = "\(nameOfArtist) \(nameOfSong)"
        if imageDataOfArtWork != nil {
            imageView.image = UIImage(data: imageDataOfArtWork)
        } else {
            imageView.image = UIImage(named: "Notes100.png")
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        } // == true
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        do {
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer = try AVAudioPlayer(contentsOfURL: megaURL)
        } catch _ as NSError {
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer = nil
        }
        if currentPause == nil {
        } else {
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = currentPause
        }
        playPauseButton.setImage(UIImage(named: "Pause32.png"), forState: UIControlState.Normal)
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.prepareToPlay()
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
        //
        controlCenter()
    }

    func pause() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.prepareToPlay()
        print((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime.description)
        currentPause = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
        playPauseButton.setImage(UIImage(named: "Play32.png"), forState: .Normal)
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.pause()
        controlCenter()
        boolPause = true
    }

    var newURL: NSURL!
    @IBAction func nextTrack(sender: UIButton) {
        nextSound()
    }
    
    var maximumBool = false
    
    func nextSound() {
        var nowRow: Int = self.currentRow
        let maxCount = self.arrayOfMP3.count-1 // -1
        if nowRow < maxCount {
                nowRow = self.currentRow++ + 1
            print("plus")
        } else if nowRow == arrayOfMP3.endIndex-1 {
            nowRow = maxCount
        }
        // for play/pause button setting
        currentPause = nil
       

        let nextTrack = arrayOfMP3[nowRow]

        let nextDirectory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        
        let nextURL: NSURL = nextDirectory.first!
        newURL = nextURL.URLByAppendingPathComponent(nextTrack)
//        println("new url \(newURL)")
  
//        var imageString: NSData!
        
        let itemPlayer = AVPlayerItem(URL: newURL)
        
        let listMetaData = itemPlayer.asset.commonMetadata 
        for item in listMetaData {
            if item.commonKey == "title" {
                nameOfSong = item.stringValue
            }
            if item.commonKey == "artist" {
                nameOfArtist = item.stringValue
            }
            if item.commonKey == "album" {
                nameOfAlbum = item.stringValue
            }
            if item.commonKey == "artwork" {
                imageDataOfArtWork = item.dataValue
            }
        }
//        println("name artist \(nameArtist) \(nameSong)")
        nameLabel.text = "\(nameOfArtist) \(nameOfSong)"
        if imageDataOfArtWork != nil {
            imageView?.image = UIImage(data: imageDataOfArtWork)
//            println("There is an image")
        } else {
            imageView?.image = UIImage(named: "Notes100.png")
//            println("There is not an image")
        }
        tapButtonPlay = true // false
        playMusic()
        controlCenter()
    }
    
    @IBAction func previousTrack(sender: UIButton) {
        previous()
    }
    
    func previous() {
        maximumBool = false
        var previousTrack: Int = self.currentRow
        if previousTrack > 0 {
            previousTrack = self.currentRow-- - 1
        } else if previousTrack == 0 {
            previousTrack = 0
        }

        currentPause = nil
        tapButtonPlay = true // false
        playMusic()
        controlCenter()
    }
    
    // MARK: - current time in soung and labels show time
    
    @IBOutlet weak var leftLabelTime: UILabel!
    @IBOutlet weak var rightLabelTime: UILabel!
    @IBOutlet weak var sliderTime: UISlider!
    
    @IBAction func sliderTime(sender: UISlider) {
        sender.maximumValue = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration)
        sender.minimumValue = 0.0
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = NSTimeInterval(sender.value)
        sender.value = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime)
    }
    
    func timeForLabels() {
        let commponentFormatter = NSDateComponentsFormatter()
        commponentFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Positional
        commponentFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehavior.Pad // default
        commponentFormatter.allowedUnits = [NSCalendarUnit.Minute, NSCalendarUnit.Second]
        
        let timeForLeft = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
        let timeForLeftLabel = commponentFormatter.stringFromTimeInterval(timeForLeft)
        
        let remainingTime = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration - (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
        let digitForRight = commponentFormatter.stringFromTimeInterval(NSTimeInterval(remainingTime))!
        rightLabelTime?.text = "-\(digitForRight)"
        leftLabelTime?.text = timeForLeftLabel
        
        sliderTime.minimumValue = 0.0
        sliderTime.value = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime)
        sliderTime.maximumValue = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration)
        
        if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.playing == false {
            playPauseButton.setImage(UIImage(named: "Play32.png"), forState: UIControlState.Normal)
            tapButtonPlay = false // true
        }
        
        if rightLabelTime.text == "-0:00" && maximumBool == false  {
            nextSound()
        }
    }
    
    // MARK: - ADBannerView function
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("Banner error is %@", error)
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        NSLog("Banner view is loaded")
        bannerAd.hidden = false
    }
    
    // MARK: - function for notification


    
    


}
