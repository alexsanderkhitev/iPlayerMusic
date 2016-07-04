//
//  DropUpCell.swift
//  iPlayer Music
//
//  Created by Alexsander  on 10/5/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import UIKit

class DropUpCell: UITableViewCell {
    
    @IBOutlet weak var songArtwork: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtistAlbum: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
