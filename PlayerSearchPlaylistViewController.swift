//
//  PlayerSearchPlaylistViewController.swift
//  Music
//
//  Created by Alexsander  on 9/8/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer
import iAd

class PlayerSearchPlaylistViewController: UIViewController, ADBannerViewDelegate {

    // MARK: - override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        volView()
        playMusic()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timeForLabel"), userInfo: nil, repeats: true)
        bannerAd.delegate = self
        bannerAd.hidden = true
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
//        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
    }
   
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            switch event!.subtype {
            case UIEventSubtype.RemoteControlPlay:
                playMusic()
//                println("tap")
                break
            case UIEventSubtype.RemoteControlPause:
                pauseMusic()
                break
            case UIEventSubtype.RemoteControlNextTrack:
                nextMusic()
                break
            case UIEventSubtype.RemoteControlPreviousTrack:
                previousMusic()
                break
            default: break
            }
        }
    }
    
    // MARK: - var and let
//    var currentSong: Song!
    var currentSong: Song!
    let fileManager = NSFileManager.defaultManager()
    var timer: NSTimer!

    // MARK: - IBOutlet 
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    // time labels
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var timeRightLabel: UILabel!
    // button play or pause
    @IBOutlet weak var playPause: UIButton!
    // MARK: - view
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var switchView: UIView!
    @IBOutlet weak var volumeView: UIView!
    // MARK: - BannerView Outlet 
    @IBOutlet weak var bannerAd: ADBannerView!
    
    // MARK: - IBAction func buttons
    var playPauseBool = true
    @IBAction func playPauseButton(sender: UIButton) {
        if playPauseBool == true {
            pauseMusic()
            playPauseBool = false
        } else {
            playMusic()
            playPauseBool = true
        }
    }
    
    @IBAction func nextButton(sender: UIButton) {
        nextMusic()
    }
    
    @IBAction func previousButton(sender: UIButton) {
        previousMusic()
    }
    
    var pauseTime: NSTimeInterval!
    var songTitle: String!
    var songArtist: String!
    var songAlbum: String!

    
    func playMusic() {
        playPause.setImage(UIImage(named: "Pause32.png"), forState: .Normal)
        
        let songData = currentSong.songData
        
        if currentSong.songArtist != "" {
            titleLabel.text = "\(currentSong.songArtist) - \(currentSong.songTitle)"
        } else {
            titleLabel.text = currentSong.songTitle
        }
        artworkImageView.image = UIImage(data: currentSong.songArtwork)
        
        songTitle = currentSong.songTitle
        songArtist = currentSong.songArtist
        songAlbum = currentSong.songAlbum
        
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
    
    func pauseMusic() {
        playPause.setImage(UIImage(named: "Play32.png"), forState: .Normal)
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
    
    func nextMusic() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
        playMusic()
    }
    
    func previousMusic() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
        playMusic()
    }
    
    // MARK: - duration slider and its functions
    
    @IBOutlet weak var durationSlider: UISlider!
    
    @IBAction func sliderDuration(sender: UISlider) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = NSTimeInterval(sender.value)
    }
    
    // MARK: - swipe functions
    @IBAction func leftSwipe(sender: UISwipeGestureRecognizer) {
        sender.direction = UISwipeGestureRecognizerDirection.Left
        nextMusic()
    }
    
    @IBAction func rightSwipe(sender: UISwipeGestureRecognizer) {
        sender.direction = UISwipeGestureRecognizerDirection.Right
        previousMusic()
    }
    
    // MARK: - time for labels
    func timeForLabel() {
        let dateComponentsFormatter = NSDateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Positional
        dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehavior.Pad
        dateComponentsFormatter.allowedUnits = [NSCalendarUnit.Minute, NSCalendarUnit.Second]
        
        let timeForLeft = dateComponentsFormatter.stringFromTimeInterval((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime)!
        let timeForRight = dateComponentsFormatter.stringFromTimeInterval((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration - (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime)!

        timeLeftLabel.text = timeForLeft
        timeRightLabel.text = "-\(timeForRight)"
        
        durationSlider.value = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime)
        durationSlider.minimumValue = 0.0
        durationSlider.maximumValue = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration)
        remoteControl()
    }
    
    // MARK: - remote control function
    func remoteControl() {
        let playingCenter = MPNowPlayingInfoCenter.defaultCenter()
        playingCenter.nowPlayingInfo = [MPMediaItemPropertyTitle: songTitle, MPMediaItemPropertyArtist: songArtist, MPMediaItemPropertyPlaybackDuration: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime]
    }
    
    // MARK: - volume view function
    func volView() {
        let mpVolumeView = MPVolumeView(frame: CGRectMake(8, 15, self.view.bounds.width-16, volumeView.bounds.size.height))
        volumeView.addSubview(mpVolumeView)
    }
    
    // MARK: - banner view functions
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("Banner error is %@", error)
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        bannerAd.hidden = false 
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
