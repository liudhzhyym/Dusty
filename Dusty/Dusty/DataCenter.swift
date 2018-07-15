//
//  DataCenter.swift
//  Dusty
//
//  Created by moonhohyeon on 7/15/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DataCenter
{
    init(umdName: String?, completeHandler: @escaping ()->Void)
    {
        let umdName = umdName!
        let encUmdName = umdName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        
        let url = "http://openapi.airkorea.or.kr/openapi/services/rest/MsrstnInfoInqireSvc/getTMStdrCrdnt?umdName=\(encUmdName)&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D"
        
        Alamofire.request(url).responseJSON { response in
            print(response)
            if let data = response.data
            {
                do
                {
                    let json = try JSON(data: data)
                    print(json)
                    print("hi")
                } catch let error
                {
                    print("\(error.localizedDescription)")
                }
            }
        }
        
    }
}
