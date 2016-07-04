//
//  PlayerSFPVC.swift
//  Music
//
//  Created by Alexsander  on 9/7/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer
import iAd

class PlayerSFPVC: UIViewController, ADBannerViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        volume()
        play()
        playPauseButton.setImage(UIImage(named: "Pause32.png"), forState: .Normal)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timeForLabels"), userInfo: nil, repeats: true)
//        println(currentSong)
//        println("Here \(currentSong)")
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - var and let
//    let fileManager = NSFileManager.defaultManager()
    
    // MARK: - var and let from passing
    var currentSong: Song!
    var currentSongArray = [Song]()
    var currentIndex = Int()
    var currentIndexPath = NSIndexPath()
    var timer: NSTimer!
    
    // MARK: - IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    //view
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var switchView: UIView!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    // time labels
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var timeRightLabel: UILabel!
    
    // MARK: - ADBannerView
    @IBOutlet weak var bannerView: ADBannerView!
    
    // MARK: - remote control
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            switch event!.subtype {
            case UIEventSubtype.RemoteControlPlay:
                play()
                break
            case UIEventSubtype.RemoteControlPause:
                pause()
                break
            case UIEventSubtype.RemoteControlNextTrack:
                next()
                break
            case UIEventSubtype.RemoteControlPreviousTrack:
                previous()
                break
            default: break
            }
        }
    }
    
    func remoteControl() {
        let controlCenter = MPNowPlayingInfoCenter.defaultCenter()
        controlCenter.nowPlayingInfo = [MPMediaItemPropertyTitle: songTitle, MPMediaItemPropertyArtist: songArtist, MPMediaItemPropertyPlaybackDuration: durationTime, MPNowPlayingInfoPropertyElapsedPlaybackTime: leftTimeInterval]
    }
    
    // MARK:- UISlider function and outlet
    @IBOutlet weak var sliderDuration: UISlider!
    
    @IBAction func durationSlider(sender: UISlider) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = NSTimeInterval(sender.value)
    }
    
    // MARK: - IBAction switch buttons
    
    var playingMusicBool = true
    
    @IBAction func playMusic(sender: UIButton) {
//        println("Play music button")
        if playingMusicBool == true {
            pause()
//            println("stop")
            playingMusicBool = false
        } else {
            play()
//            println("play")
            playingMusicBool = true
        }
    }
    
    @IBAction func playNext(sender: UIButton) {
        next()
    }
    
    @IBAction func playPrevious(sender: UIButton) {
        previous()
    }
    
    // var for media data
    var songTitle: String!
    var songArtist: String!
    var songAlbum: String!
//    var songImage: UIImage!
    var maximumCount = false
    
    func play() {
        playPauseButton.setImage(UIImage(named: "Pause32.png"), forState: .Normal)
        let musicFileData = currentSongArray[currentIndex]
        let songData = musicFileData.songData
        if currentIndex == currentSongArray.endIndex-1 {
            maximumCount = true
        }
        
        if musicFileData.songArtist != "" {
            titleLabel.text = "\(musicFileData.songArtist) - \(musicFileData.songTitle)"
        } else {
            titleLabel.text = musicFileData.songTitle
        }
        artworkImageView.image = UIImage(data: musicFileData.songArtwork)
        
        songTitle = musicFileData.songTitle
        songArtist = musicFileData.songArtist
        songAlbum = musicFileData.songAlbum
    
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer = try? AVAudioPlayer(data: songData, fileTypeHint: AVFileTypeMPEGLayer3)
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.prepareToPlay()
        if pauseTime == nil {
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
        } else {
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = pauseTime
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
            pauseTime = nil
        }
    }
    
    var pauseTime: NSTimeInterval!
    
    func pause() {
        playPauseButton.setImage(UIImage(named: "Play32.png"), forState: .Normal)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.pause()
        pauseTime = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
    }
    
    func next() {
        let allSongs = currentSongArray.count - 1
//        var newIndex: Int!
        if self.currentIndex < allSongs {
            self.currentIndex++ + 1
//            songImage = nil
        } else {
            self.currentIndex = allSongs
        }
        pauseTime = nil
//        println("button next")
        play()
    }
    
    func previous() {
//        var allSongs = currentSongArray.count - 1
        if self.currentIndex > 0 {
            self.currentIndex--
        } else {
            self.currentIndex = 0
        }
        pauseTime = nil
        maximumCount = false
        play()
//        println("button previous")
    }

    // MARK: - volume functions
    func volume() {
        let addVolumeView = MPVolumeView(frame: CGRectMake(8, 16, self.view.bounds.size.width-16, volumeView.bounds.size.height))
        volumeView.addSubview(addVolumeView)
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
    
    
    // MARK: - function for time
    var durationTime: NSTimeInterval!
    var leftTimeInterval: NSTimeInterval!
    
    func timeForLabels() {
        leftTimeInterval = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
        let rightTimeInterval = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration - (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
        durationTime = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration
        let dateComponentFormatter = NSDateComponentsFormatter()
        dateComponentFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehavior.Pad
        dateComponentFormatter.allowedUnits = [NSCalendarUnit.Minute, NSCalendarUnit.Second]
        
        let timeForLeft = dateComponentFormatter.stringFromTimeInterval(leftTimeInterval)!
        let timeForRight = dateComponentFormatter.stringFromTimeInterval(rightTimeInterval)!
        
        timeRightLabel.text = "-\(timeForRight)"
        timeLeftLabel.text = timeForLeft
        
        sliderDuration.minimumValue = 0.0
        sliderDuration.maximumValue = Float(durationTime)
        sliderDuration.value = Float(leftTimeInterval)
        
        remoteControl()
        
        //switch track 
        if timeRightLabel.text == "-0:00" && maximumCount == false {
            next()
        } else if timeRightLabel.text == "-0:00" && maximumCount == true {
            playingMusicBool = false
            playPauseButton.setImage(UIImage(named: "Play32.png"), forState: .Normal)
        }
    }
    
    // MARK: - ADBannerView functions 
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("Banner error is %@", error)
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        bannerView.hidden = false
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
