//
//  AddressCenter.swift
//  Dusty
//
//  Created by moonhohyeon on 7/18/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AddressCenter
{
    var sidoName: String?
    var sggName: String?
    var umdName: String?
    
    init(xCoordinate: String?, yCoordinate: String?, completeHandler: @escaping ()->Void)
    {
        if let xCoordinate = xCoordinate,
            let yCoordinate = yCoordinate
        {
            // 카카오 지번주소 API 네트워킹
            let headers: HTTPHeaders = ["Authorization": "KakaoAK c70e9056ac2981fa07457549afe9ee25"]
            let url = "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=\(xCoordinate)&y=\(yCoordinate)&input_coord=WGS84"
        
            Alamofire.request(url, headers: headers).responseJSON { response in
                if let data = response.data
                {
                    do
                    {
                        let json = try JSON(data: data)
                        
                        self.sidoName = json["documents"][0]["address"]["region_1depth_name"].stringValue
                        self.sggName = json["documents"][0]["address"]["region_2depth_name"].stringValue
                        self.umdName = json["documents"][0]["address"]["region_3depth_name"].stringValue.components(separatedBy: " ").first                                                
                        
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
