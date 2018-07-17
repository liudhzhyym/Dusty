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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let isOn = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "switch")
        {
            whoSwitch.isOn = isOn as! Bool
        }
    }
    
    @IBAction func doneAction(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchAction(_ sender: Any)
    {
        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(whoSwitch.isOn, forKey: "switch")
    }
}
