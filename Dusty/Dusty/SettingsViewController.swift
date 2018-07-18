//
//  SettingsViewController.swift
//  Dusty
//
//  Created by moonhohyeon on 7/14/18.
//  Copyright © 2018 macker. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet weak var whoSwitch: UISwitch!
    @IBOutlet weak var concentrationSetting: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    @IBAction func doneAction(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
        
        if let concentrationSetting = Int(concentrationSetting.text!)
        {
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(concentrationSetting, forKey: "concentration")
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
