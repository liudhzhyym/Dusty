//
//  StationCenter.swift
//  Dusty
//
//  Created by moonhohyeon on 7/19/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class StationCenter
{
    var khaiValue: String?
    var pm10Value: String?
    var pm25Value: String?
    
    var khaiValues: [String] = []
    var pm10Values: [String] = []
    var pm25Values: [String] = []
    
    init(stationName: String?, completeHandler: @escaping ()->Void)
    {
        if let stationName = stationName,
            let encStationName = stationName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        {
            let url = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?stationName=\(encStationName)&dataTerm=daily&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&ver=1.3&_returnType=json"
            
            Alamofire.request(url).responseJSON { response in
                if let data = response.data
                {
                    do
                    {
                        let json = try JSON(data: data)
                        
                        self.khaiValue = json["list"][0]["khaiValue"].stringValue
                        self.pm10Value = json["list"][0]["pm10Value"].stringValue
                        self.pm25Value = json["list"][0]["pm25Value"].stringValue

                    } catch let error
                    {
                        print("\(error.localizedDescription)")
                    }
                }
                
                DispatchQueue.main.async {
                    completeHandler()
                }
            }.resume()
        }
    }
}
