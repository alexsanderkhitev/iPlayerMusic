//
//  SongsCellTableView.swift
//  Music
//
//  Created by Александр Хитёв on 7/26/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

class SongsCellTableView: UITableViewCell {
    
    @IBOutlet weak var nameSongLabel: UILabel!
    @IBOutlet weak var nameArtistAlbumLabel: UILabel!
    @IBOutlet weak var imageViewArtwork: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
