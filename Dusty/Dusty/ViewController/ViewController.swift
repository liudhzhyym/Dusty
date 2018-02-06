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
    var city: String!
    var dataFromAirKorea: DataFromAirKorea!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
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
                case "Ulsan":
                    self.city = "울산"
                case "Gyeonggi-do":
                    self.city = "경기"
                case "Gangwon":
                    self.city = "강원"
                case "Chungbuk":
                    self.city = "충북"
                case "Chungnam":
                    self.city = "충남"
                case "Jeonbuk":
                    self.city = "전북"
                case "Jeonnam":
                    self.city = "전남"
                case "Kyungbuk":
                    self.city = "경북"
                case "Gyeongnam":
                    self.city = "경남"
                case "Jeju":
                    self.city = "제주"
                case "Sejong":
                    self.city = "세종"
                default:
                    self.city = "서울"
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
//    func setGradientBackground()
//    {
//        let colorTop =  UIColor(red: 223.0/255.0, green: 227.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor
//        let colorBottom = UIColor(red: 180.0/255.0, green: 190.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [colorTop, colorBottom]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.frame = self.view.bounds
//
//        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
//    }
    
    func load()
    {
        self.currentLocationLabel?.text = city
        self.overallAirLabel?.text = String(describing: self.dataFromAirKorea.dataOne?.dataTwo?.khai)
        self.fineDustLabel?.text = String(describing: self.dataFromAirKorea.dataOne?.dataTwo?.pm10)
        self.superDustLabel?.text = String(describing: self.dataFromAirKorea.dataOne?.dataTwo?.pm25)
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
        lookUpCurrentLocation { (placemark) in
            print(placemark?.name)
            print(placemark?.subLocality)
            
            if let rawCity = placemark?.locality
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
                case "Ulsan":
                    self.city = "울산"
                case "Gyeonggi-do":
                    self.city = "경기"
                case "Gangwon":
                    self.city = "강원"
                case "Chungbuk":
                    self.city = "충북"
                case "Chungnam":
                    self.city = "충남"
                case "Jeonbuk":
                    self.city = "전북"
                case "Jeonnam":
                    self.city = "전남"
                case "Kyungbuk":
                    self.city = "경북"
                case "Gyeongnam":
                    self.city = "경남"
                case "Jeju":
                    self.city = "제주"
                case "Sejong":
                    self.city = "세종"
                default:
                    self.city = "서울"
                }
            }
        }
        
        
        
        
    }
}
