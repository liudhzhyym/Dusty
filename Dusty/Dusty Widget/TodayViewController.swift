//
//  TodayViewController.swift
//  Dusty Widget
//
//  Created by moonhohyeon on 2/8/18.
//  Copyright © 2018 macker. All rights reserved.
//

import UIKit
import NotificationCenter

import Alamofire
import SwiftyJSON

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
        
        // 위젯 업데이트
        if let stationName = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "station") as? String,
            let cityName = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "city") as? String,
            let encStationName = stationName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        {
            // 네트워킹
            let url = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?stationName=\(encStationName)&dataTerm=daily&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&ver=1.3&_returnType=json"
            
            Alamofire.request(url).responseJSON { response in
                if let data = response.data
                {
                    do
                    {
                        let json = try JSON(data: data)
                        
                        let cityValue: String? = cityName
                        let todayValue: String? = "자세한 정보는 앱을 확인해주세요!"
                        let khaiValue: String? = json["list"][0]["khaiValue"].stringValue
                        let pm10Value: String? = "미세먼지 : " + "\(json["list"][0]["pm10Value"].stringValue)" + " ㎍/m3"
                        let pm25Value: String? = "미세먼지 : " + "\(json["list"][0]["pm25Value"].stringValue)" + " ㎍/m3"
                        
                        if let city = cityValue
                        {
                            if city != self.city.text
                            {
                                self.city.text = city
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
                        
                        if let today = todayValue
                        {
                            if today != self.today.text
                            {
                                self.today.text = today
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
                        
                        if let khai = khaiValue
                        {
                            if khai != self.khai.text
                            {
                                self.khai.text = khai
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
                        
                        if let pm10 = pm10Value
                        {
                            if pm10 != self.pm10.text
                            {
                                self.pm10.text = pm10
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
                        
                        if let pm25 = pm25Value
                        {
                            if pm25 != self.pm25.text
                            {
                                self.pm25.text = pm25
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
                    } catch let error
                    {
                        print("\(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
}
