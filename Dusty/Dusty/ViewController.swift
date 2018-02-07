//
//  ViewController.swift
//  Dusty
//
//  Created by moonhohyeon on 2/5/18.
//  Copyright © 2018 macker. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate
{
    @IBOutlet var backgroundView: UIView?
    @IBOutlet weak var currentLocationLabel: UILabel?
    @IBOutlet weak var overallAirLabel: UILabel?
    @IBOutlet weak var fineDustLabel: UILabel?
    @IBOutlet weak var superDustLabel: UILabel?
    @IBOutlet weak var predictLabel: UILabel?
    @IBOutlet weak var todayResultLabel: UITextView?
    
    lazy var locationManager = CLLocationManager()
    var city: String = "서울"
    var dataFromAirKorea: DataFromAirKorea?
    var dataFromAirKorea2: DataFromAirKorea2?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        load()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard (locations.last?.coordinate) != nil else { return }
        locationManager.stopUpdatingLocation()
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void )
    {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location
        {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil
                                                {
                                                    let firstLocation = placemarks?[0]
                                                    completionHandler(firstLocation)
                                                }
                                                else 
                                                {
                                                    completionHandler(nil)
                                                }
            })
        }
        else
        {
            completionHandler(nil)
        }
    }
    
    @IBAction func reloadLocationButton(_ sender: Any)
    {
        load()
    }
    
    func load()
    {
        lookUpCurrentLocation { (placemark) in
            if let rawCity = placemark?.administrativeArea
            {
                switch rawCity
                {
                case "Seoul":
                    self.city = "서울"
                case "Busan":
                    self.city = "부산"
                case "Daegu":
                    self.city = "대구"
                case "Incheon":
                    self.city = "인천"
                case "Gwangju":
                    self.city = "광주"
                case "Daejeon":
                    self.city = "대전"
                case "Gyeonggi-do":
                    self.city = "경기"
                case "Gangwon":
                    self.city = "강원"
                case "North Chungcheong":
                    self.city = "충북"
                case "South Chungcheong":
                    self.city = "충남"
                case "North Jeolla":
                    self.city = "전북"
                case "South Jeolla":
                    self.city = "전남"
                case "North Gyeongsan":
                    self.city = "경북"
                case "South Gyeongsang":
                    self.city = "경남"
                case "Jeju":
                    self.city = "제주"
                default:
                    self.city = "서울"
                }
            }
            
            self.dataFromAirKorea = DataFromAirKorea(city: self.city, completeHandler: {
                self.currentLocationLabel?.text = self.city
                self.overallAirLabel?.text = self.dataFromAirKorea?.dataOne?.dataTwo?.khai
                self.fineDustLabel?.text =  "미세 먼지 : " + (self.dataFromAirKorea?.dataOne?.dataTwo?.pm10)! + " ㎍/m3"
                self.superDustLabel?.text = "초미세 먼지 : " + (self.dataFromAirKorea?.dataOne?.dataTwo?.pm25)! + " ㎍/m3"
                
                if 0 <= Double((self.dataFromAirKorea?.dataOne?.dataTwo?.pm10)!)! && 30 > Double((self.dataFromAirKorea?.dataOne?.dataTwo?.pm10)!)!
                {
                    self.todayResultLabel?.text = "미세먼지 농도가 좋습니다"
                    self.backgroundView?.backgroundColor = UIColor(red: 223/255, green: 227/255, blue: 238/255, alpha: 1)
                } else if 30 <= Double((self.dataFromAirKorea?.dataOne?.dataTwo?.pm10)!)! && 80 > Double((self.dataFromAirKorea?.dataOne?.dataTwo?.pm10)!)!
                {
                    self.todayResultLabel?.text = "미세먼지 농도가 보통이에요"
                    self.backgroundView?.backgroundColor = UIColor(red: 227/255, green: 230/255, blue: 218/255, alpha: 1)
                } else if 80 <= Double((self.dataFromAirKorea?.dataOne?.dataTwo?.pm10)!)! && 150 > Double((self.dataFromAirKorea?.dataOne?.dataTwo?.pm10)!)!
                {
                    self.todayResultLabel?.text = "미세먼지 농도가 나쁩니다"
                    self.backgroundView?.backgroundColor = UIColor(red: 251/255, green: 217/255, blue: 211/255, alpha: 1)
                } else if 150 <= Double((self.dataFromAirKorea?.dataOne?.dataTwo?.pm10)!)!
                {
                    self.todayResultLabel?.text = "미세먼지가 농도가 매우 나쁩니다"
                    self.backgroundView?.backgroundColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
                } else
                {
                    self.todayResultLabel?.text = "미세먼지 농도 측정이 불가합니다"
                    self.backgroundView?.backgroundColor = UIColor(red: 223/255, green: 227/255, blue: 238/255, alpha: 1)                    
                }
                
            })
            
            self.dataFromAirKorea2 = DataFromAirKorea2(city: self.city, completeHandler: {
                self.predictLabel?.text = "내일 : " + "보통" + " / 모레 : " + "보통"
            })
        }
    }
}
