//
//  TouchIDVC.swift
//  iPlayer Music
//
//  Created by Alexsander  on 9/25/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import LocalAuthentication

class TouchIDVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        checkPassword()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var checkButton: UIButton!
    
    let localContext = LAContext()

    func checkPassword() {
        var error: NSError?
        if localContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthentication, error: &error) {
            // use touch id
            let authenticationString = "Authentication"
            localContext.localizedFallbackTitle = ""
            localContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthentication, localizedReason: authenticationString, reply: { (success: Bool, localError: NSError?) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("showTabController", sender: self)
                    })
                } else {
                    switch localError!.code {
                    case LAError.AppCancel.rawValue:
                        NSLog("App cancel")
                    case LAError.AuthenticationFailed.rawValue:
                        NSLog("Failed")
                    case LAError.InvalidContext.rawValue:
                        NSLog("Invalid context")
                    case LAError.PasscodeNotSet.rawValue:
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.performSegueWithIdentifier("showTabController", sender: self)
                        })
                    case LAError.SystemCancel.rawValue:
                        NSLog("System cancel")
                    case LAError.TouchIDLockout.rawValue:
                        NSLog("Touch id lockout")
                    case LAError.TouchIDNotAvailable.rawValue:
                        NSLog("Touch id now avaulable")
                    case LAError.TouchIDNotEnrolled.rawValue:
                        NSLog("Touch id not entrolled")
                    case LAError.UserCancel.rawValue:
                        NSLog("User cancel")
                    case LAError.UserFallback.rawValue:
                        NSLog("User fallback")
                    default: break
                    }
                }
            })
        }
    }
 
    
    // MARK: - @IBAction
    @IBAction func authenticationButton(sender: UIButton) {
        checkPassword()
        NSLog("print authentication button")
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
