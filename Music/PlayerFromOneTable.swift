//
//  PlayerFromOneTable.swift
//  Music
//
//  Created by Alexsander  on 8/17/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import iAd

class PlayerFromOneTable: UIViewController, ADBannerViewDelegate {

    // MARK: - override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
        exportAllFiles()
        play()
        volumeSlider()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timeForLabels", userInfo: nil, repeats: true)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        //
        bannerAd.delegate = self
        bannerAd.hidden = true
       
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - IBOutlet 
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageViewArtWork: UIImageView!
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var viewSwtich: UIView!
    @IBOutlet weak var viewVolumeSystem: UIView!
    @IBOutlet weak var playStopButton: UIButton!
    // MARK: ADBannerView
    @IBOutlet weak var bannerAd: ADBannerView!
    
    // MARK: - var and let 
    var currentTrack: String!
    let fileManager = NSFileManager.defaultManager()
    var timer: NSTimer!
    var currentPause: NSTimeInterval!
    
    // MARK: - IBAction func and their functions (they are switch)
    
 
    @IBAction func previousTrack(sender: UIButton) {
        previous()
    }
    
    func previous() {
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = 0.0
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.prepareToPlay()
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
    }
    
    var playOrPause = true
    
    @IBAction func playTrack(sender: UIButton) {
        if playOrPause == true {
            pause()
            playOrPause = false
        } else {
            play()
            playOrPause = true
        }
    }
    
    func play() {
        playStopButton.setImage(UIImage(named: "Pause32.png"), forState: .Normal)
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer = try? AVAudioPlayer(contentsOfURL: urlSong)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.prepareToPlay()
        if currentPause == nil {
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
        } else {
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = currentPause
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
        }
    }
    
    func pause() {
        playStopButton.setImage(UIImage(named: "Play32.png"), forState: UIControlState.Normal)
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.pause()
        currentPause = (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime
    }
    
    @IBAction func nextTrack(sender: UIButton) {
        next()
    }
    
    func next() {
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.stop()
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = 0.0
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.prepareToPlay()
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.play()
    }
    
    
    // MARK: - UISlider and its functions
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    
    @IBAction func sliderDurationSwitch(sender: UISlider) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime = NSTimeInterval(sender.value)
    }
    
    var timeForLeftLabelCurrentTime: String!
    func timeForLabels() {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Positional
        formatter.allowedUnits = [NSCalendarUnit.Minute, NSCalendarUnit.Second]
        formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehavior.Pad
        
        timeForLeftLabelCurrentTime = formatter.stringFromTimeInterval(NSTimeInterval((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime))
        leftTimeLabel.text = timeForLeftLabelCurrentTime!
        let timeForRightLabel = formatter.stringFromTimeInterval(NSTimeInterval((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration - (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime))!
        rightTimeLabel.text = "-\(timeForRightLabel)"
        
        durationSlider.minimumValue = 0.0
        durationSlider.value = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime)
        durationSlider.maximumValue = Float((UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration)
        //
        
        let mpPlayingCenter = MPNowPlayingInfoCenter.defaultCenter()
        mpPlayingCenter.nowPlayingInfo = [MPMediaItemPropertyTitle: titleSongForCenter, MPMediaItemPropertyArtist: titleArtistForCenter, MPMediaItemPropertyPlaybackDuration: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.currentTime]
    }
    
    // MARK: - func 
    func volumeSlider() {
        let volumeSlider = MPVolumeView(frame: CGRectMake(8.0, 15.0, self.view.bounds.size.width-16, self.viewVolumeSystem.bounds.size.height))
        viewVolumeSystem.addSubview(volumeSlider)
    }
    
    var titleSong: String!
    var titleAlbum: String!
    var titleArtist: String!
    var imageDataArtwork: NSData!
    var urlSong: NSURL!
    // MARK: data for control now playing control
    
    var titleSongForCenter: String!
    var titleArtistForCenter: String!
    var titleAlbumForCenter: String!
    var durationForCenter: String!
    
    
    func exportAllFiles() {
        imageDataArtwork = nil
        let urlForExportAllFiles = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
        let arrayContent = try! fileManager.contentsOfDirectoryAtURL(urlForExportAllFiles, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        let arrayMP3files = arrayContent.filter(){ $0.pathExtension! == "mp3" }.map(){ $0.lastPathComponent! } as [String]
        var megaURL: NSURL!
        for item in arrayMP3files {
            let url = urlForExportAllFiles
            megaURL = url.URLByAppendingPathComponent(item)
            let playerItem = AVPlayerItem(URL: megaURL) //
            let commonMetaData = playerItem.asset.commonMetadata 
            for metaItem in commonMetaData {
                if metaItem.commonKey == "title" {
                    titleSong = metaItem.stringValue
//                    println("title song \(titleSong)")
                }
                if metaItem.commonKey == "artist" {
                    titleArtist = metaItem.stringValue
                }
                if metaItem.commonKey == "album" {
                    titleAlbum = metaItem.stringValue
                }
                if titleSong == currentTrack {
                    if metaItem.commonKey == "artwork" {
                        imageDataArtwork = metaItem.dataValue
                    }
                }
                if titleSong == currentTrack {
                    let urlCurrentSong = urlForExportAllFiles
                    urlSong = urlCurrentSong.URLByAppendingPathComponent(item)
                    titleSongForCenter = titleSong
                    titleArtistForCenter = titleArtist
                    titleAlbumForCenter = titleAlbum
                    nameLabel.text = "\(titleArtist) - \(titleSong)"
                    if imageDataArtwork != nil {
                        imageViewArtWork.image = UIImage(data: imageDataArtwork)
                    } else {
                        imageViewArtWork.image = UIImage(named: "Notes100.png")
                    }
                }
            }
        }
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
    
    // MARK: - control and remote centers
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        super.remoteControlReceivedWithEvent(event)
        if event!.type == UIEventType.RemoteControl {
            switch event!.subtype {
            case UIEventSubtype.RemoteControlPlay:
                play()
                break
            case UIEventSubtype.RemoteControlPause:
                pause()
                break
            case UIEventSubtype.RemoteControlPreviousTrack:
                previous()
                break
            case UIEventSubtype.RemoteControlNextTrack:
                next()
                break
            default: break
            }
        }
    }
    
    // MARK: - ADBannerView
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("Banner error is %@", error)
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        bannerAd.hidden = false
        NSLog("Banner is loaded")
    }
 
//    func controlCenter() {
//        var nowPlayeingCenter = MPNowPlayingInfoCenter.defaultCenter()
//        nowPlayeingCenter.nowPlayingInfo = [MPMediaItemPropertyTitle: titleSongForCenter, MPMediaItemPropertyArtist: titleArtistForCenter, MPMediaItemPropertyPlaybackDuration: (UIApplication.sharedApplication().delegate as! AppDelegate).mainAudioPlayer.duration]
//    }

}
