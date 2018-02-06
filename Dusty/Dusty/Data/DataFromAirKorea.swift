//
//  DataFromAirKorea.swift
//  Dusty
//
//  Created by moonhohyeon on 2/5/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation

// WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D

class DataFromAirKorea
{
    var dataOne: DataOne?
    var dataDic: [String:Any]?
    
    init(city: String, completeHandler: @escaping ()->Void)
    {
        let urlStr = city
        let encoded = urlStr.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let url = URL(string: "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty?sidoName=\(encoded)&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&ver=1.3&_returnType=json")
        
        print(city)
        print(url)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data
            {
                do
                {
                    let dic = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    self.dataDic = dic
                    self.dataOne = DataOne(dataDic: self.dataDic!)
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
