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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
    var window: UIWindow?
    var stationCenter: StationCenter?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // 구글 광고
        GADMobileAds.configure(withApplicationID: "ca-app-pub-2178088560941007~1089414105")
        
        // 로컬 노티
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        center.delegate = self
        
        // 데이터 새로고침 주기
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        
        if let concentration = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.integer(forKey: "concentration")
        {
                if let notificationIsOn = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.bool(forKey: "notification")
                {
                    if 50 >= concentration && notificationIsOn
                    {
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(false, forKey: "notification")
                        
                        let content = UNMutableNotificationContent()
                        content.body = "미세먼지 농도가 설정값을 넘어갔습니다"
                        content.sound = UNNotificationSound.default
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        let request = UNNotificationRequest(identifier: "DustNotification", content: content, trigger: trigger)
                        
                        center.add(request)
                        completionHandler(.newData)
                    } else // falsefalse falsetrue truefalse
                    {
                        if 50 < concentration // falsefalse falsetrue
                        {
                            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(true, forKey: "notification")
                        } else // truefalse
                        {
                            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(false, forKey: "notification")
                        }
                        
                        completionHandler(.noData)
                    }
                }
        }
        
//        if let stationName = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "station") as? String,
//            let concentration = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.integer(forKey: "concentration")
//        {
//            self.stationCenter = StationCenter(stationName: stationName, completeHandler: {
//                if let pm10Value = Int((self.stationCenter?.pm10Value)!),
//                    let notificationIsOn = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.bool(forKey: "notification")
//                {
//                    if pm10Value >= concentration && notificationIsOn
//                    {
//                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(false, forKey: "notification")
//
//                        let content = UNMutableNotificationContent()
//                        content.body = "미세먼지 농도가 설정값을 넘어갔습니다"
//                        content.sound = UNNotificationSound.default
//                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//                        let request = UNNotificationRequest(identifier: "DustNotification", content: content, trigger: trigger)
//
//                        center.add(request)
//                        completionHandler(.newData)
//                    } else // falsefalse falsetrue truefalse
//                    {
//                        if pm10Value < concentration // falsefalse falsetrue
//                        {
//                            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(true, forKey: "notification")
//                        } else // truefalse
//                        {
//                            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.set(false, forKey: "notification")
//                        }
//
//                        completionHandler(.noData)
//                    }
//                }
//            })
//        }
        
        completionHandler(.failed)
    }
}
