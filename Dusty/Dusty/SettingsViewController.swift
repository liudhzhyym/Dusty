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
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func doneAction(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
    }
}
