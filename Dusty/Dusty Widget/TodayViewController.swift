//
//  TodayViewController.swift
//  Dusty Widget
//
//  Created by moonhohyeon on 2/8/18.
//  Copyright © 2018 macker. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding
{
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var today: UILabel!
    @IBOutlet weak var khai: UILabel!
    @IBOutlet weak var pm10: UILabel!
    @IBOutlet weak var pm25: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let city = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "city")
        {
            self.city.text = city as? String
        }
        
        if let today = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "today")
        {
            self.today.text = today as? String
        }
        
        if let khai = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "khai")
        {
            self.khai.text = khai as? String
        }
        
        if let pm10 = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "pm10")
        {
            self.pm10.text = pm10 as? String
        }
        
        if let pm25 = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "pm25")
        {
            self.pm25.text = pm25 as? String
        }        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        if let city = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "city")
        {
            if city as? String != self.city.text
            {
                self.city.text = city as? String
                completionHandler(NCUpdateResult.newData)
            } else
            {
                completionHandler(NCUpdateResult.noData)
            }
        } else
        {
            self.city.text = "앱을 열어주세요"
            completionHandler(NCUpdateResult.newData)
        }
        
        if let today = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "today")
        {
            if today as? String != self.today.text
            {
                self.today.text = today as? String
                completionHandler(NCUpdateResult.newData)
            } else
            {
                completionHandler(NCUpdateResult.noData)
            }
        } else
        {
            self.today.text = "---"
            completionHandler(NCUpdateResult.newData)
        }
        
        if let khai = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "khai")
        {
            if khai as? String != self.khai.text
            {
                self.khai.text = khai as? String
                completionHandler(NCUpdateResult.newData)
            } else
            {
                completionHandler(NCUpdateResult.noData)
            }
        } else
        {
            self.khai.text = "-"
            completionHandler(NCUpdateResult.newData)
        }
        
        if let pm10 = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "pm10")
        {
            if pm10 as? String != self.pm10.text
            {
                self.pm10.text = pm10 as? String
                completionHandler(NCUpdateResult.newData)
            } else
            {
                completionHandler(NCUpdateResult.noData)
            }
        } else
        {
            self.pm10.text = "--"
            completionHandler(NCUpdateResult.newData)
        }
        
        if let pm25 = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "pm25")
        {
            if pm25 as? String != self.pm25.text
            {
                self.pm25.text = pm25 as? String
                completionHandler(NCUpdateResult.newData)
            } else
            {
                completionHandler(NCUpdateResult.noData)
            }
        } else
        {
            self.pm25.text = "--"
            completionHandler(NCUpdateResult.newData)
        }
        
    }
    
}
