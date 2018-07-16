//
//  TmCenter.swift
//  Dusty
//
//  Created by moonhohyeon on 7/15/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TmCenter
{
    var stationName: String?
    
    init(tmX: String?, tmY: String?, completeHandler: @escaping ()->Void)
    {
        if let tmX = tmX, let tmY = tmY
        {
            let url = "http://openapi.airkorea.or.kr/openapi/services/rest/MsrstnInfoInqireSvc/getNearbyMsrstnList?tmX=\(tmX)&tmY=\(tmY)&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&_returnType=json"
            
            Alamofire.request(url).responseJSON { response in
                if let data = response.data
                {
                    do
                    {
                        let json = try JSON(data: data)
                        
//                        self.stationName = json[]
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
