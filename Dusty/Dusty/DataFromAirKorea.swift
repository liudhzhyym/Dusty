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
    
    init(city: String?, specificCity: String?, completeHandler: @escaping ()->Void)
    {
        let urlStr = city!
        let encoded = urlStr.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let url = URL(string: "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty?sidoName=\(encoded)&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&ver=1.3&_returnType=json")
    
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
                    self.dataOne = DataOne(specificCity: specificCity, dataDic: self.dataDic!)
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

class DataOne
{
    var dataTwo: DataTwo?
    var data: [Any]?
    
    init?(specificCity: String?, dataDic: [String:Any])
    {        
        guard let data = dataDic["list"] as? [[String:Any]] else { return }
        self.data = data
        
        dataTwo = DataTwo(specificCity: specificCity, dataDic: data)
    }
}

class DataTwo
{
    var pm10: String?
    var pm25: String?
    var khai: String?
    var specificCity: String?
    var specificCityArray: [String] = []
    
    init?(specificCity: String?, dataDic: [[String:Any]])
    {
        self.specificCity = specificCity
        
        if specificCity != nil
        {
            specificCityArray.append(specificCity!)
        }
        
        if !(dataDic.isEmpty)
        {
            if self.specificCity != nil
            {
                for data in dataDic
                {
                    specificCityArray.append(data["stationName"] as! String)
                    
                    if self.specificCity == data["stationName"] as? String
                    {                        
                        guard let pm10 = data["pm10Value"] as? String else { return }
                        self.pm10 = pm10
                        
                        guard let pm25 = data["pm25Value"] as? String else { return }
                        self.pm25 = pm25
                        
                        guard let khai = data["khaiValue"] as? String else { return }
                        self.khai = khai
                    }
                }
            } else
            {
                for data in dataDic
                {
                    specificCityArray.append(data["stationName"] as! String)
                }
                
                guard let pm10 = dataDic[0]["pm10Value"] as? String else { return }
                self.pm10 = pm10
                
                guard let pm25 = dataDic[0]["pm25Value"] as? String else { return }
                self.pm25 = pm25
                
                guard let khai = dataDic[0]["khaiValue"] as? String else { return }
                self.khai = khai
            }
            
            
            
        }
    }
}

class DataFromAirKorea2
{
    var dataThree: DataThree?
    var dataDic2: [String:Any]?
    
    init(city: String?, completeHandler: @escaping ()->Void)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        let url2 = URL(string: "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMinuDustFrcstDspth?searchDate=\(today)&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&_returnType=json")
        
        var request2 = URLRequest(url: url2!)
        request2.httpMethod = "GET"
        
        let session2 = URLSession.shared
        session2.dataTask(with: request2) { (data, response, error) in
            if let data = data
            {
                do
                {
                    let dic = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    self.dataDic2 = dic
                    self.dataThree = DataThree(dataDic: self.dataDic2!)
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


class DataThree
{
    var dataFour: DataFour?
    var data: [Any]?
    
    init?(dataDic: [String:Any])
    {
        guard let data = dataDic["list"] as? [[String:Any]] else { return }
        self.data = data
        
        dataFour = DataFour(dataDic: data)
    }
    
}

class DataFour
{
    var grade: String?
    
    let city = "서울"
    
    init?(dataDic: [[String:Any]])
    {
        guard let grade = dataDic[0]["informGrade"] as? String else { return }
        
    }
}
