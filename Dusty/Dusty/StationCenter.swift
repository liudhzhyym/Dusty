//
//  StationCenter.swift
//  Dusty
//
//  Created by moonhohyeon on 7/16/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class StationCenter
{
    var pm10Value: String?
    var pm25Value: String?
    var khaiValue: String?
    
    init(stationName: String?, completeHandler: @escaping ()->Void)
    {
        if let stationName = stationName
        {
            let encStationName = stationName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!            
            let url = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?stationName=\(encStationName)&dataTerm=daily&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&ver=1.3&_returnType=json"
            
            Alamofire.request(url).responseJSON { response in
                if let data = response.data
                {
                    do
                    {
                        let json = try JSON(data: data)
                        
//                        self.pm10Value
//                        self.pm25Value
//                        self.khaiValue
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
