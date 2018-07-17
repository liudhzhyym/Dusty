//
//  SettingsViewController.swift
//  Dusty
//
//  Created by moonhohyeon on 7/14/18.
//  Copyright © 2018 macker. All rights reserved.
//

import UIKit
import UserNotifications

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
        
        if let concentrationSetting = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "concentration")
        {
            self.concentrationSetting.text = concentrationSetting as? String
        }
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    @IBAction func doneAction(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
        
        if let concentrationSetting = concentrationSetting.text
        {
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(concentrationSetting, forKey: "concentration")
            
            if #available(iOS 10.0, *)
            {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
                
                // removeNotification()
                // if 네트워킹을 통해 얻은 미세먼지 농도 >= concentrationSetting
                let content = UNMutableNotificationContent()
                content.title = "미세먼지 농도 알림"
                content.body = "미세먼지 : - ㎍/m3" + "\n" + "초미세먼지 : - ㎍/m3"
                content.sound = UNNotificationSound.default
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                let request = UNNotificationRequest(identifier: "DustNotification", content: content, trigger: trigger)
                
                center.add(request)
            } else
            {
                
            }
        }
    }
    
    @IBAction func switchAction(_ sender: Any)
    {
        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(whoSwitch.isOn, forKey: "switch")
    }
}
