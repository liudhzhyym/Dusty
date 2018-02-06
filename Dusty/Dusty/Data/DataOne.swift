//
//  DataOne.swift
//  Dusty
//
//  Created by moonhohyeon on 2/5/18.
//  Copyright © 2018 macker. All rights reserved.
//

import Foundation

class DataOne
{
    var dataTwo: DataTwo?
    var data: [Any]?
    
    init?(dataDic: [String:Any])
    {
        guard let data = dataDic["list"] as? [[String:Any]] else { return }
        self.data = data
        
        dataTwo = DataTwo(dataDic: data)
    }
}

