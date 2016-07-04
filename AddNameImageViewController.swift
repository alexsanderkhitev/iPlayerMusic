//
//  AddNameImageViewController.swift
//  Music
//
//  Created by Alexsander  on 9/3/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class AddNameImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    // MARK: - override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.tabBarController?.tabBar.hidden = true 
        pickerController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - var and let
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    // MARK: - IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView! {
        didSet {
            titleTextView.delegate = self
        }
    }
    @IBOutlet weak var coverImageView: UIImageView!
    
    
    // MARK: - @IBAction
    @IBAction func takePhoto(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            self.takePhoto()
        }))
        alertController.addAction(UIAlertAction(title: "Choose Photo", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            self.choosePhoto()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    var examString = "Test"
    let dateNow = NSDate()

    @IBAction func saveData(sender: UIBarButtonItem) {
        if titleTextView.text != "" && titleTextView.text != examString && titleTextView.text != "Add the title of the playlist"{
            examString = titleTextView.text
//            println(dateNow)
            let playlistEntity = NSEntityDescription.insertNewObjectForEntityForName("Playlist", inManagedObjectContext: managedObjectContext) as! Playlist
            let imageData = UIImageJPEGRepresentation(coverImageView.image!, 1.0)
            playlistEntity.playlistName = titleTextView.text
            playlistEntity.playlistCreatedDate = dateNow
            playlistEntity.playlistCoverImage = imageData!
            do {
                try managedObjectContext.save()
            } catch _ {
            }
//            println(playlistEntity)
         performSegueWithIdentifier("selectSong", sender: self)
        } else if titleTextView.text == examString {
            let alertController = UIAlertController(title: "Playlist with the same name is already exist.", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alertController, animated: true, completion: nil)
            let digit = 1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(digit))
            dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
        } else if titleTextView.text == "" || titleTextView.text == "Add the title of the playlist" {
            let alertController = UIAlertController(title: "Write the name of the playlist", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alertController, animated: true, completion: nil)
            let digit = 1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(digit))
            dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }

    // MARK: - UIImagePickerController take photo
    let pickerController = UIImagePickerController()
    func takePhoto() {
        print("camera")
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
        pickerController.allowsEditing = true
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        let albumImage = image
//        println(albumImage)
        pickerController.dismissViewControllerAnimated(true, completion: nil)
        coverImageView.image = image 
    }
    
    // MARK: - text view function
    func textViewDidBeginEditing(textView: UITextView) {
        titleTextView.text = nil 
    }
    
    // MARK: UIImagePickerController choose photo from library
    func choosePhoto() {
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }
        
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectSong" {
            let allSongTVC = segue.destinationViewController as! AllSongForSelectTVC
            allSongTVC.dateFromPlaylist = dateNow
//            println(dateNow)
        }
    }

}
