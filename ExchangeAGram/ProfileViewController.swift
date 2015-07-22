//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Kashish Goel on 2015-07-21.
//  Copyright (c) 2015 Kashish Goel. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate {
  
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var fbLoginView: FBSDKLoginButton!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile"]
        self.fbLoginView.publishPermissions = ["publish_actions"]
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "fbProfileChanged:",
            name: FBSDKProfileDidChangeNotification,
            object: nil)
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        // If we have a current Facebook access token, force the profile change handler
        if ((FBSDKAccessToken.currentAccessToken()) != nil)
        {
            self.fbProfileChanged(self)
        } }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    //facebooks functions
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error != nil)
        {
            println( "\(error.localizedDescription)" )
        }
        else if (result.isCancelled)
        {
            // Logged out?
            println( "Login Cancelled")
        }
        else
        {
            // Logged in?
            println( "Logged in")
        }
    }

    

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    
    //see bitfountain
    func fbProfileChanged(sender: AnyObject!) {
        
        let fbProfile = FBSDKProfile.currentProfile()
        if (fbProfile != nil)
        {
            // Fetch & format the profile picture
            let strProfilePicURL = fbProfile.imagePathForPictureMode(FBSDKProfilePictureMode.Square, size: self.profileImageView.frame.size)
            let url = NSURL(string: strProfilePicURL, relativeToURL: NSURL(string: "http://graph.facebook.com/"))
            let imageData = NSData(contentsOfURL: url!)
            let image = UIImage(data: imageData!)
            
            self.nameLabel.text = fbProfile.name
            self.profileImageView.image = image
            
            self.nameLabel.hidden = false
            self.profileImageView.hidden = false
        }
        else
        {
            self.nameLabel.text = ""
            self.profileImageView.image = UIImage(named: "")
            
            self.nameLabel.hidden = true
            self.profileImageView.hidden = true
        }
    }

    @IBAction func mapViewButton(sender: UIButton) {
        performSegueWithIdentifier("mapSegue", sender: nil)
    }
    

}
