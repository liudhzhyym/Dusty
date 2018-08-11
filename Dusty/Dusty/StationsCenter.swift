//
//  StationsCenter.swift
//  Dusty
//
//  Created by moonhohyeon on 7/16/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class StationsCenter
{
    var pm10Value: String?
    var pm25Value: String?
    var khaiValue: String?
    
    var stationNames: [String] = []
    var pm10Values: [String] = []
    var pm25Values: [String] = []
    var khaiValues: [String] = []
    
    init(stationNames: [JSON], completeHandler: @escaping ()->Void)
    {
        for station in stationNames
        {
            if let stationName = station.dictionary?["stationName"]?.stringValue
            {                
                if let encStationName = stationName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                {
                    let url = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?stationName=\(encStationName)&dataTerm=daily&pageNo=1&numOfRows=10&ServiceKey=WUXG8BXM9fSzuziJGtZVy%2F1wCKUhBlf65tcABdSG9zXo0Dk8jv6Q7MhVOJxAgTGe6kRUwYYCzBnBHEDmFQrdbw%3D%3D&ver=1.3&_returnType=json"
                    
                    let response = Alamofire.request(url).responseJSON()
                    if let data = response.data
                    {
                        do
                        {
                            let json = try JSON(data: data)
                            
                            self.stationNames.append(stationName)
                            self.khaiValues.append(json["list"][0]["khaiValue"].stringValue)
                            self.pm10Values.append(json["list"][0]["pm10Value"].stringValue)
                            self.pm25Values.append(json["list"][0]["pm25Value"].stringValue)
                            
                        } catch let error
                        {
                            print("\(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            completeHandler()
        }
    }
}

extension DataRequest
{
    public func response() -> DefaultDataResponse
    {
        let semaphore = DispatchSemaphore(value: 0)
        var result: DefaultDataResponse!
        
        self.response(queue: DispatchQueue.global(qos: .default)) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    public func response<T: DataResponseSerializerProtocol>(responseSerializer: T) -> DataResponse<T.SerializedObject>
    {
        let semaphore = DispatchSemaphore(value: 0)
        var result: DataResponse<T.SerializedObject>!
        
        self.response(queue: DispatchQueue.global(qos: .default), responseSerializer: responseSerializer) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> DataResponse<Any>
    {
        return response(responseSerializer: DataRequest.jsonResponseSerializer(options: options))
    }
}


