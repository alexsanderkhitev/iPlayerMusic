//
//  Song.swift
//  iPlayer Music
//
//  Created by Alexsander  on 9/14/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import Foundation
import CoreData

@objc(Song)
class Song: NSManagedObject {

    @NSManaged var songTitle: String
    @NSManaged var songArtist: String
    @NSManaged var songAlbum: String
    @NSManaged var songArtwork: NSData
    @NSManaged var songDate: NSDate
    @NSManaged var songData: NSData
    @NSManaged var songPathExtension: String
    @NSManaged var playlistRelationship: Playlist

}
