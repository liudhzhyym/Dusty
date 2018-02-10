//
//  DataFromAirKorea.swift
//  Dusty
//
//  Created by moonhohyeon on 2/5/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation

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
    var sumPm10: Int = 0
    var sumPm25: Int = 0
    var sumKhai: Int = 0
    var countPm10: Int = 0
    var countPm25: Int = 0
    var countKhai: Int = 0
    var specificCity: String?
    var tempArray: [String] = []
    var specificCityArray: [String] = []
    
    init?(specificCity: String?, dataDic: [[String:Any]])
    {
        self.specificCity = specificCity
        
        if !(dataDic.isEmpty)
        {
            if self.specificCity != nil
            {
                for data in dataDic
                {
                    if let stationName = data["stationName"] as? String
                    {
                        tempArray.append(stationName)
                        self.specificCityArray = tempArray.sorted(by: <)
                    }
                    
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
                    if let stationName = data["stationName"] as? String
                    {
                        tempArray.append(stationName)
                        self.specificCityArray = tempArray.sorted(by: <)
                    }
                    
                    if let d1 = data["pm10Value"] as? String
                    {
                        if let pm10 = Int(d1)
                        {
                            self.sumPm10 += pm10
                            self.countPm10 += 1
                            self.pm10 = "\(sumPm10 / countPm10)"
                        }
                    }
                    
                    if let d2 = data["pm25Value"] as? String
                    {
                        if let pm25 = Int(d2)
                        {
                            self.sumPm25 += pm25
                            self.countPm25 += 1
                            self.pm25 = "\(sumPm25 / countPm25)"
                        }
                    }
                    
                    if let d3 = data["khaiValue"] as? String
                    {
                        if let khai = Int(d3)
                        {
                            self.sumKhai += khai
                            self.countKhai += 1
                            self.khai = "\(sumKhai / countKhai)"
                        }
                    }
                }
            }
        }
    }
    
    func getNumber(number: Any?) -> NSNumber
    {
        guard let statusNumber:NSNumber = number as? NSNumber else
        {
            guard let statString:String = number as? String else
            {
                return 0
            }
            if let myInteger = Int(statString)
            {
                return NSNumber(value:myInteger)
            }
            else{
                return 0
            }
        }
        return statusNumber
    }

}

class DataFromAirKorea2
{
    var dataThree: DataThree?
    var dataDic2: [String:Any]?
    
    init(index1: Int, index2: Int, completeHandler: @escaping ()->Void)
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
                    self.dataThree = DataThree(index1: index1, index2: index2, dataDic: self.dataDic2!)
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
    
    init?(index1: Int, index2: Int, dataDic: [String:Any])
    {
        guard let data = dataDic["list"] as? [[String:Any]] else { return }
        self.data = data
        
        dataFour = DataFour(index1: index1, index2: index2, dataDic: data)
    }
    
}

class DataFour
{
    var grade: String?
    var str: String?
    var str1 : String?
    
    init?(index1: Int, index2: Int, dataDic: [[String:Any]])
    {
        guard let grade = dataDic[1]["informGrade"] as? String else { return }
        str = "\(grade[grade.index(grade.startIndex, offsetBy: index1)])" + "\(grade[grade.index(grade.startIndex, offsetBy: index2)])"        
    }
}
