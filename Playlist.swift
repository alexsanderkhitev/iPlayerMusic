//
//  Playlist.swift
//  iPlayer Music
//
//  Created by Alexsander  on 9/14/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import Foundation
import CoreData

@objc(Playlist)
class Playlist: NSManagedObject {

    @NSManaged var playlistCoverImage: NSData
    @NSManaged var playlistCreatedDate: NSDate
    @NSManaged var playlistName: String
    @NSManaged var songRelationship: NSSet

}
