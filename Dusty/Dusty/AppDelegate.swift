//
//  AppDelegate.swift
//  Dusty
//
//  Created by moonhohyeon on 2/5/18.
//  Copyright © 2018 macker. All rights reserved.
//

import UIKit
import UserNotifications

import GoogleMobileAds
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
    var window: UIWindow?
    
    // 노티 센터
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // 구글 광고
        GADMobileAds.configure(withApplicationID: "ca-app-pub-2178088560941007~1089414105")
        
        // 로컬 노티
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        
        // 데이터 새로고침 주기
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        // 로컬 노티
        if let stationName = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "station") as? String,
            let encStationName = stationName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let concentration = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.integer(forKey: "concentration")
        {
            // 네트워킹
            let url = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?stationName=\(encStationName)&dataTerm=daily&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&ver=1.3&_returnType=json"
            
            Alamofire.request(url).responseJSON { response in
                if let data = response.data
                {
                    do
                    {
                        let json = try JSON(data: data)
                        
                        let pm10Value = json["list"][0]["pm10Value"].stringValue
                        
                        if let pm10ValueInt = Int(pm10Value),
                            let notificationIsOn = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.bool(forKey: "notification")
                        {
                            if pm10ValueInt >= concentration && notificationIsOn
                            {
                                
                                // 로컬 노티
                                UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(false, forKey: "notification")
                                
                                let content = UNMutableNotificationContent()
                                content.body = "미세먼지 농도가 설정값을 넘어갔습니다"
                                content.sound = UNNotificationSound.default
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                let request = UNNotificationRequest(identifier: "DustNotification", content: content, trigger: trigger)
                                
                                self.center.add(request)
                                completionHandler(.newData)
                            } else
                            {
                                // 노티 케이스 처리
                                if pm10ValueInt < concentration
                                {
                                    UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(true, forKey: "notification")
                                } else
                                {
                                    UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(false, forKey: "notification")
                                }
                                
                                completionHandler(.noData)
                            }
                        }
                    } catch let error
                    {
                        print("\(error.localizedDescription)")
                    }
                }
            }
        } else
        {
            completionHandler(.failed)
        }
        
        completionHandler(.newData)
    }
}
