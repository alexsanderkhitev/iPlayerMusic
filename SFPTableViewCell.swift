//
//  SFPTableViewCell.swift
//  Music
//
//  Created by Alexsander  on 9/7/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit

class SFPTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameArtistAlbumLabel: UILabel!
    
}
