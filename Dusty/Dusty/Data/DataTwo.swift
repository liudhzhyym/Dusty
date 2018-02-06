//
//  DataTwo.swift
//  Dusty
//
//  Created by moonhohyeon on 2/5/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation

class DataTwo
{
    var pm10: String?
    var pm25: String?
    var khai: String?
    
    init?(dataDic: [[String:Any]])
    {
        guard let pm10 = dataDic[0]["pm10Value"] as? String else { return }
        self.pm10 = pm10
        
        guard let pm25 = dataDic[0]["pm25Value"] as? String else { return }
        self.pm25 = pm25
        
        guard let khai = dataDic[0]["khaiValue"] as? String else { return }
        self.khai = khai
    }
    
//        for data in dataDic
//        {
//            guard let pm10 = data["pm10Value"] as? Double else { return }
//            self.pm10 = pm10
//            print(pm10)
//
//            guard let pm25 = data["pm25Value"] as? Double else { return }
//            self.pm25 = pm25
//
//            guard let khai = data["khaiValue"] as? Double else { return }
//            self.khai = khai
//        }
        
//        pm10 = pm10 / Double(dataDic.count)
//        pm25 = pm25 / Double(dataDic.count)
//        khai = khai / Double(dataDic.count)
}
