//
//  SearchCenter.swift
//  Dusty
//
//  Created by moonhohyeon on 7/19/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SearchCenter
{
    var info: [[String:JSON]] = []
    
    init(searchTerm: String?, completeHandler: @escaping ()->Void)
    {
        if let searchTerm = searchTerm,
            let encSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        {
            let url = "https://dapi.kakao.com/v2/local/search/address.json?query=\(encSearchTerm)"
            let headers: HTTPHeaders = [ "Authorization" : "KakaoAK c70e9056ac2981fa07457549afe9ee25" ]
            
            Alamofire.request(url, headers: headers).responseJSON { response in
                if let data = response.data
                {
                    do
                    {
                        let json = try JSON(data: data)
                        self.info = []
                        
                        for element in json["documents"].arrayValue
                        {
                            if let elementDic = element.dictionary
                            {
                                self.info.append(elementDic)                                
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
