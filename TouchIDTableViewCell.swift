//
//  TouchIDTableViewCell.swift
//  iPlayer Music
//
//  Created by Alexsander  on 9/25/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import UIKit


class TouchIDTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        let switchString = userDefaults.valueForKey("touchSwitch") as? String
        print(switchString)
        if switchString == nil {
            switchTouch.on = false
        } else {
            if switchString! == "on" {
                switchTouch.on = true
            } else {
                switchTouch.on = false
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        let cell = TouchIDTableViewCell()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    
    
    // MARK: - var and let
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: - IBOutlet 
    @IBOutlet weak var titleSettingLBL: UILabel!
    @IBOutlet weak var switchTouch: UISwitch!
    
    // MARK: - IBAction func
    
    @IBAction func turnTouchID(sender: UISwitch) {
        if sender.on {
//            print("turn on")
            userDefaults.setValue("touchVC", forKey: "mainView")
            userDefaults.setValue("on", forKey: "touchSwitch")
            userDefaults.synchronize()
        } else {
//            print("turn off")
            userDefaults.setValue("mainTabBarController", forKeyPath: "mainView")
            userDefaults.setValue("off", forKey: "touchSwitch")
            userDefaults.synchronize()
        }
    }
    
    
}
