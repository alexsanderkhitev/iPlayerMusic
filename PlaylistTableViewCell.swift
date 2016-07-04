//
//  PlaylistTableViewCell.swift
//  Music
//
//  Created by Alexsander  on 9/2/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var namePlaylistLabel: UILabel!
    @IBOutlet weak var numberOfSongPlaylistLabel: UILabel!
    
    
}
