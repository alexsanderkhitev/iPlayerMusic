//
//  PlayMusicVC.swift
//  Music
//
//  Created by Александр Хитёв on 8/3/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
//import CoreData
import AVFoundation
import MediaPlayer
import iAd


class PlayMusicVC: UIViewController, AVAudioPlayerDelegate, ADBannerViewDelegate {

    
    // MARK: - override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
        mpVolumeView()
        play()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timeForLabels", userInfo: nil, repeats: true)
        bannerView.delegate = self
        bannerView.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        self.becomeFirstResponder()
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
//        timer.invalidate()
        self.resignFirstResponder()
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            switch event!.subtype {
            case UIEventSubtype.RemoteControlPlay:
                play()
            case UIEventSubtype.RemoteControlPause:
                pause()
            case UIEventSubtype.RemoteControlNextTrack:
                next()
            case UIEventSubtype.RemoteControlPreviousTrack:
                previous()
            default: break
            }
        }
    }
    
    // MARK: - var and let
    var timer: NSTimer!
    var fileManager = NSFileManager.defaultManager()
//    var (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer = AVAudioPlayer()
    var nameSongForLabel: String!
    var artistSongForLabel: String!
    var albumSongForLabel: String!
    var dataImageForImageView: NSData!
    
    // data from table
    var currentIndex = Int()
    var arrayOfSongs = [String]()
    
    // MARK: - IBOutlet weak
    @IBOutlet weak var nameSongLabel: UILabel!
    @IBOutlet weak var imageOfArtwork: UIImageView!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var switchView: UIView!
    @IBOutlet weak var volumeView: UIView!
    // button
    @IBOutlet weak var playPauseButton: UIButton!
    // left and right labels
    @IBOutlet weak var leftLabelTime: UILabel!
    @IBOutlet weak var rightLabelTime: UILabel!
    @IBOutlet weak var sliderDuration: UISlider!
    
    // MARK: - ADBanner 
    @IBOutlet weak var bannerView: ADBannerView!
    
    // MARK: - IBAction func and switch functions
    @IBAction func previousTrack(sender: UIBarButtonItem) {
        previous()
    }
    
    var playingSong = true
    @IBAction func playTrack(sender: UIBarButtonItem) {
        if playingSong == false /* true*/ {
            play()
            playingSong = true
            controlCenter()
        } else {
            pause()
            playingSong = false
            controlCenter()
        }
    }
    
    @IBAction func nextTrack(sender: UIBarButtonItem) {
        next()
    }
    
    @IBAction func sliderD(sender: UISlider) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = NSTimeInterval(sender.value)
        controlCenter()
    }
    
    
    func previous() {
        maximumCount = false 
//        var allDigit = arrayOfSongs.count-1
        if currentIndex > 0 {
            newIndex = currentIndex-- - 1
        }
        play()
        controlCenter()
    }
    
    // MARK: - data for control
    var titleSongForControl: String!
    var titleArtistForControl: String!
    
    var currentPause: NSTimeInterval!
    var imageForControlCenter: UIImage!
    var maximumCount = false
    
    func play() {
        playPauseButton.setImage(UIImage(named: "Pause32.png"), forState: UIControlState.Normal)
        var currentSong: String!
        if newIndex == nil {
            currentSong = arrayOfSongs[currentIndex]
            if currentIndex == arrayOfSongs.endIndex-1 {
                maximumCount = true
            }
        } else {
            currentSong = arrayOfSongs[newIndex]
            if newIndex == arrayOfSongs.endIndex-1 {
                maximumCount = true 
            }
            newIndex = nil 
        }
        
            let directoryFolder = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
            var superURL: NSURL!
            let url: NSURL = directoryFolder.first!
            superURL = url.URLByAppendingPathComponent(currentSong)
            let playerItem = AVPlayerItem(URL: superURL)
            let commonMetaData = playerItem.asset.commonMetadata 
            for item in commonMetaData {
                if item.commonKey == "title" {
                    nameSongForLabel = item.stringValue
                }
                if item.commonKey == "artist" {
                    artistSongForLabel = item.stringValue
                }
                if item.commonKey == "album" {
                    albumSongForLabel = item.stringValue
                }
                if item.commonKey == "artwork" {
                    dataImageForImageView = item.dataValue
                }
            }
            titleSongForControl = nameSongForLabel
            titleArtistForControl = artistSongForLabel
            nameSongLabel.text = "\(artistSongForLabel) - \(nameSongForLabel)"
        if dataImageForImageView != nil {
            imageOfArtwork.image = UIImage(data: dataImageForImageView)
            imageForControlCenter = UIImage(data: dataImageForImageView)
        } else {
            imageOfArtwork.image = UIImage(named: "Notes100.png")
        }
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer = try? AVAudioPlayer(contentsOfURL: superURL)
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch _ {
            }
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch _ {
            }
        if currentPause == nil {
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
            controlCenter()
        } else {
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = currentPause
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
            currentPause = nil
        }
    }
    
    func timeForLabels() {
        let timeForRightLabel: NSTimeInterval = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration - (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
        let timeForLeftLabel = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
      
        let calendar: NSCalendarUnit = [NSCalendarUnit.Minute, NSCalendarUnit.Second]
//        var time: NSTimeInterval = 0
        let dateFormatter = NSDateComponentsFormatter()
        dateFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Positional
        dateFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehavior.Pad
        dateFormatter.allowedUnits = calendar
        let timeRight = dateFormatter.stringFromTimeInterval(timeForRightLabel)!
        rightLabelTime.text = "-\(timeRight)"
        let timeLeft = dateFormatter.stringFromTimeInterval(timeForLeftLabel)!
        leftLabelTime.text = timeLeft
        
        sliderDuration.minimumValue = 0.0
        sliderDuration.value = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime)
        sliderDuration.maximumValue = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration)
        // auto next sound
        if rightLabelTime.text == "-0:00" && maximumCount == false {
            next()
        }
        //
       if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.playing == false {
            playPauseButton.setImage(UIImage(named: "Play32.png"), forState: UIControlState.Normal)
            playingSong = false
        }
    }
 
    func pause() {
        playPauseButton.setImage(UIImage(named: "Play32.png"), forState: UIControlState.Normal)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.pause()
        currentPause = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
    }
    
    var newIndex: Int!
    var newSong: String!
    func next() {
        let allDigit = arrayOfSongs.count-1
        if arrayOfSongs.count > 1 {
        if currentIndex < allDigit {
            if newIndex == nil {
                newIndex = currentIndex++ + 1
            } else {
                newIndex = currentIndex++
            }
            play()
            controlCenter()
        } else if currentIndex == arrayOfSongs.endIndex {
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
            }
        }
    }

    func controlCenter() {
        let mpPlaysCenter = MPNowPlayingInfoCenter.defaultCenter()
        mpPlaysCenter.nowPlayingInfo = [MPMediaItemPropertyArtist: titleArtistForControl, MPMediaItemPropertyTitle: titleSongForControl, MPMediaItemPropertyPlaybackDuration: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration, MPMediaItemPropertyPlayCount: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime, MPNowPlayingInfoPropertyElapsedPlaybackTime: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime]
    }
    
    // MARK: - swipe functions 
    
    @IBAction func leftSwipe(sender: UISwipeGestureRecognizer) {
        sender.direction = UISwipeGestureRecognizerDirection.Left
        next()
    }
    
    @IBAction func rightSwipe(sender: UISwipeGestureRecognizer) {
        sender.direction = UISwipeGestureRecognizerDirection.Right
        previous()
    }
    
    // MARK: - functions
    
    func mpVolumeView() {
        let mpView = MPVolumeView(frame: CGRectMake(8, 15, self.view.bounds.size.width-16, self.volumeView.bounds.size.height))
        volumeView.addSubview(mpView)
    }
    
    // MARK: - banner view function
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("Banner error is %@", error)
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        bannerView.hidden = false
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
}
