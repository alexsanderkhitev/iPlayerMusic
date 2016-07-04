//
//  SongsCellArtist.swift
//  Music
//
//  Created by Александр Хитёв on 7/29/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import Foundation

class SongsCellArtist: UITableViewCell {

    @IBOutlet weak var imageSongs: UIImageView!
    @IBOutlet weak var nameSong: UILabel!
    @IBOutlet weak var artistAlbumName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
