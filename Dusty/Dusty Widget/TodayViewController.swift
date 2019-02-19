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
    @IBOutlet weak var pm10: UILabel!
    @IBOutlet weak var pm25: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 저장되어 있던 도시명
        if let city = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "city")
        {
            self.city.text = city as? String
        }
        
        // 저장되어 있던 미세먼지
        if let pm10 = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "pm10")
        {
            self.pm10.text = pm10 as? String
        }
        
        // 저장되어 있던 초미세먼지
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
            let encStationName = stationName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        {
            // 네트워킹
            let url = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?stationName=\(encStationName)&dataTerm=daily&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&ver=1.3&_returnType=json"
            
            // 네트워킹 통신
            Alamofire.request(url).responseJSON { response in
                if let data = response.data
                {
                    do
                    {
                        let json = try JSON(data: data)
                        
                        let pm10Value: String? = "미세먼지 : " + "\(json["list"][0]["pm10Value"].stringValue)" + " ㎍/m3"
                        let pm25Value: String? = "초미세먼지 : " + "\(json["list"][0]["pm25Value"].stringValue)" + " ㎍/m3"
                        
                        // 미세먼지
                        if let pm10 = pm10Value
                        {
                            if self.city.text == "--"
                            {
                                self.pm10.text = "미세먼지 : - ㎍/m3"
                                completionHandler(NCUpdateResult.newData)
                            } else
                            {
                                self.pm10.text = pm10
                                completionHandler(NCUpdateResult.newData)
                            }
                        } else
                        {
                            self.pm10.text = "미세먼지 : - ㎍/m3"
                            completionHandler(NCUpdateResult.newData)
                        }
                        
                        // 초미세먼지
                        if let pm25 = pm25Value
                        {
                            if self.city.text == "--"
                            {
                                self.pm25.text = "초미세먼지 : - ㎍/m3"
                                completionHandler(NCUpdateResult.newData)
                            } else
                            {
                                self.pm25.text = pm25
                                completionHandler(NCUpdateResult.newData)
                            }
                        } else
                        {
                            self.pm25.text = "초미세먼지 : - ㎍/m3"
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
