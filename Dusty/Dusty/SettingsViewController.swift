//
//  SettingsViewController.swift
//  Dusty
//
//  Created by moonhohyeon on 7/14/18.
//  Copyright © 2018 macker. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SettingsViewController: UIViewController
{
    @IBOutlet weak var whoSwitch: UISwitch!
    @IBOutlet weak var concentrationSetting: UITextField!
    
    // 구글 배너 광고
    @IBOutlet weak var bannerBox: UIView!
    var bannerView: GADBannerView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 구글 배너 광고
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-2178088560941007/3831120339"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        if let isOn = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "switch")
        {
            whoSwitch.isOn = isOn as! Bool
        }
        
        if let concentrationSetting = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.integer(forKey: "concentration")
        {
            self.concentrationSetting.text = "\(concentrationSetting)"
        }
    }
    
    // 구글 배너 광고
    func addBannerViewToView(_ bannerView: GADBannerView)
    {
        bannerBox.translatesAutoresizingMaskIntoConstraints = false
        bannerBox.addSubview(bannerView)
        
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self.bannerBox,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: self.bannerBox,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    @IBAction func doneAction(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
        
        if let concentrationSetting = self.concentrationSetting.text,
            let concentrationInt = Int(concentrationSetting)
        {
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(concentrationInt, forKey: "concentration")
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(true, forKey: "notification")
        } else
        {
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(0, forKey: "concentration")
        }
    }
    
    @IBAction func switchAction(_ sender: Any)
    {
        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(whoSwitch.isOn, forKey: "switch")
    }
}
