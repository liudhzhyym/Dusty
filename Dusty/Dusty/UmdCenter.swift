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

class UmdCenter
{
    var sidoName: String?
    var sggName: String?
    var umdName: String?
    var tmX: String?
    var tmY: String?
    
    init(sggName: String?, umdName: String?, completeHandler: @escaping ()->Void)
    {
        if let sggName = sggName,
            let umdName = umdName,
            let encUmdName = umdName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        {            
            let url = "http://openapi.airkorea.or.kr/openapi/services/rest/MsrstnInfoInqireSvc/getTMStdrCrdnt?umdName=\(encUmdName)&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&_returnType=json"
            
            Alamofire.request(url).responseJSON { response in
                if let data = response.data
                {
                    do
                    {
                        let json = try JSON(data: data)
                        
                        for name in json["list"]
                        {
                            if sggName == "\(name.1["sggName"])"
                            {
//                                self.sidoName = "\(name.1["sidoName"])"
//                                self.sggName = "\(name.1["sggName"])"
//                                self.umdName = "\(name.1["umdName"])"
                                self.tmX = "\(name.1["tmX"])"
                                self.tmY = "\(name.1["tmY"])"
                            }
                        }
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
