//
//  PlayFromSearchVC.swift
//  Music
//
//  Created by Alexsander  on 8/9/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVFoundation
import iAd

// search artist
class PlayFromSearchVC: UIViewController, ADBannerViewDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
        volumeSliderSystem()
        exportFilesFromFolder()
        play() //!!!!!!!!!!!!!!
        playPauseButton.setImage(UIImage(named: "Pause32.png"), forState: UIControlState.Normal)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timeForLabels", userInfo: nil, repeats: true)
//        println("current song string \(currentSongString)")
        remoteShow()
//        print("Play from search")
        bannerView.delegate = self
        bannerView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer == true {
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            UIApplication.sharedApplication().ignoreSnapshotOnNextApplicationLaunch()
            remoteShow()
        }
    }
    
    // MARK: - become the first responder
 
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func remoteShow() {
        let playingNow = MPNowPlayingInfoCenter.defaultCenter()
        playingNow.nowPlayingInfo = [MPMediaItemPropertyArtist: artistOfSong, MPMediaItemPropertyTitle: titleOfSong, MPMediaItemPropertyPlaybackDuration: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime]
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
 
    // MARK: - IBOutlet 
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageViewOfArt: UIImageView!
    @IBOutlet weak var viewDurationSong: UIView!
    @IBOutlet weak var viewSwitchSong: UIView!
    @IBOutlet weak var viewVolumeSystem: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    // for duration view
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rigthTimeLabel: UILabel!
    @IBOutlet weak var sliderDuration: UISlider!
    
    // MARK: - ADBannerView
    @IBOutlet weak var bannerView: ADBannerView!

    // MARK: - IBAction
    @IBAction func previousSong(sender: UIButton) {
        previous()
    }
    
    func previous() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        pauseTime = nil
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = 0.0
        playPauseButton.setImage(UIImage(named: "Pause32.png"), forState: UIControlState.Normal)
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
        //
        remoteShow()
    }

    var playing: Bool = true
    @IBAction func playSong(sender: UIButton) {
        if playing == true {
            playPauseButton.setImage(UIImage(named: "Play32.png"), forState: UIControlState.Normal)
            pause()
            playing = false
        } else {
            playPauseButton.setImage(UIImage(named: "Pause32.png"), forState: UIControlState.Normal)
            play()
            playing = true
        }
    }
 
    var pauseTime: NSTimeInterval!
    var titleOfSong: String!
    var artistOfSong: String!
    var albumOfSong: String!
    var imageDataOfSong: NSData!
    
    var urlForStop: NSURL!
    func play() {
        for song in localArrayNames {
            let playerItem = AVPlayerItem(URL: song)
            let comMetaData = playerItem.asset.commonMetadata 
            for item in comMetaData {
                if item.commonKey == "title" {
                    titleOfSong = item.stringValue
                }
                if item.commonKey == "artist" {
                    artistOfSong = item.stringValue
                }
                if item.commonKey == "album" {
                    albumOfSong = item.stringValue
                }
                if item.commonKey == "artwork" {
                    imageDataOfSong = item.dataValue
                    print("data type \(item.dataType)")
                }
            }
            titleLabel.text = "\(artistOfSong) - \(titleOfSong)"
            if imageDataOfSong == nil {
                imageViewOfArt.image = UIImage(named: "Notes100.png")
            } else {
                imageViewOfArt.image = UIImage(data: imageDataOfSong)
            }
            urlForStop = song
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer = try? AVAudioPlayer(contentsOfURL: song)
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch _ {
            }
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch _ {
            }
            if pauseTime == nil {
                (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.prepareToPlay()
                (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
            } else {
                (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = pauseTime
                (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.prepareToPlay()
                (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
            }
        }
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
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.pause()
        pauseTime = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
    }
    
    @IBAction func nextSong(sender: UIButton) {
        next()
    }
    
    func next() {
        playPauseButton.setImage(UIImage(named: "Pause32.png"), forState: UIControlState.Normal)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.prepareToPlay()
        pauseTime = nil
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = 0.0
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
        remoteShow()
    }
    
    @IBAction func slider(sender: UISlider) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = Double(sender.value)
    }
    
    // MARK: - function
    func volumeSliderSystem() {
        let volumeView = MPVolumeView(frame: CGRectMake(8.0, 15.0, view.bounds.size.width-16, viewVolumeSystem.bounds.size.height))
        viewVolumeSystem.addSubview(volumeView)
    }
    
    func timeForLabels() {
        let duration = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration - (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
        let remainingTime = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
        let calendar: NSCalendarUnit = [NSCalendarUnit.Minute, NSCalendarUnit.Second]
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Positional
        formatter.allowedUnits = calendar
        formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehavior.Pad

        let timeRight = formatter.stringFromTimeInterval(duration)!
        let timeLeft = formatter.stringFromTimeInterval(remainingTime)!
        
        leftTimeLabel.text = timeLeft
        rigthTimeLabel.text = "-\(timeRight)"
        sliderDuration.minimumValue = 0.0
        sliderDuration.maximumValue = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration)
        sliderDuration.value = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime)
        
        if sliderDuration.value == 0.0 {
            playPauseButton.setImage(UIImage(named: "Play32.png"), forState: UIControlState.Normal)
        }
        
        // function for play button 
        if (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.playing == false {
            playPauseButton.setImage(UIImage(named: "Play32.png"), forState: UIControlState.Normal)
            playing = false
        }
    }

    // MARK: - var and lets
    var currentSongString: String!
    var fileManager = NSFileManager.defaultManager()
    var localArrayNames = [NSURL]()
    var timer: NSTimer!

    func exportFilesFromFolder() {
        let folder = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
        let allFiles = try! fileManager.contentsOfDirectoryAtURL(folder, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        let filterArray = allFiles.filter(){ $0.pathExtension! == "mp3" }.map(){ $0.lastPathComponent! } as [String]
//        println("filter array \(allFiles[3])")
        var superURL: NSURL!
        for itemInFilterArray in filterArray {
            let direct = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
            let url: NSURL = direct.first!
                superURL = url.URLByAppendingPathComponent(itemInFilterArray)
            let playerItem = AVPlayerItem(URL: superURL)
            var equalazerString: String!
            let commonMetaData = playerItem.asset.commonMetadata 
            for item in commonMetaData {
                if item.commonKey == "title" {
                    equalazerString = item.stringValue
                    if equalazerString == currentSongString {
                        localArrayNames.append(superURL)
                    } else {
                    }
                }
            }
        }
    }

    // MARK: - swipe IBAction func 
    
    @IBAction func leftSwipe(sender: UISwipeGestureRecognizer) {
        sender.direction = UISwipeGestureRecognizerDirection.Left
        next()
    }
    
    @IBAction func rightSwipe(sender: UISwipeGestureRecognizer) {
        sender.direction = UISwipeGestureRecognizerDirection.Right
        previous()
    }
    
    // MARK: - ADBanner View function
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("Banner error is %@", error)
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        bannerView.hidden = false
    }
    
    
    
    // MARK: - Navigation function
    
}
