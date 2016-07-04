//
//  FSTableViewCell.swift
//  Music
//
//  Created by Alexsander  on 9/8/15.
//  Copyright (c) 2015 Alexsander Khitev. All rights reserved.
//

import UIKit

class FSTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistAlbumLabel: UILabel!
    

}
