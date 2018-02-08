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
    @IBOutlet weak var overallAirLabel: UILabel?
    @IBOutlet weak var fineDustLabel: UILabel?
    @IBOutlet weak var superDustLabel: UILabel?
    @IBOutlet weak var predictLabel: UILabel?
    @IBOutlet weak var todayResultLabel: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var locationManager = CLLocationManager()
    var city: String?
    var dataFromAirKorea: DataFromAirKorea?
    var dataFromAirKorea2: DataFromAirKorea2?
    var baseCity: [String] = []
    var searchCity: [String] = []
    var searchTerm: String?
    var specificCity: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.autocapitalizationType = .none
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "도시 세부 검색"
        definesPresentationContext = true
        self.navigationItem.searchController = searchController
        self.navigationController?.navigationBar.prefersLargeTitles = true
        searchCity = baseCity
        
        location()        
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
    
    func location()
    {
        lookUpCurrentLocation { (placemark) in
            if let rawCity = placemark?.administrativeArea
            {
                print(rawCity)
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
                case "North Gyeongsang":
                    self.city = "경북"
                case "South Gyeongsang":
                    self.city = "경남"
                case "Jeju":
                    self.city = "제주"
                default:
                    self.city = "위치 확인 불가"
                }
                
                self.load()
            } else
            {
                self.city = "위치 확인 불가"
                self.load()
            }
        }
    }
    
    func load()
    {
        self.dataFromAirKorea = DataFromAirKorea(city: self.city, specificCity: self.specificCity, completeHandler: {
            
            guard let baseCity = self.dataFromAirKorea?.dataOne?.dataTwo?.specificCityArray else { return }
            self.baseCity = baseCity
            
            self.navigationController?.navigationBar.topItem?.title = self.city
            
            if let specificCity = self.specificCity
            {
                self.navigationController?.navigationBar.topItem?.title = specificCity
            }
            
            guard let khai = self.dataFromAirKorea?.dataOne?.dataTwo?.khai else { return }
            self.overallAirLabel?.text = khai
            
            guard let pm10 = self.dataFromAirKorea?.dataOne?.dataTwo?.pm10 else { return }
            self.fineDustLabel?.text =  "미세 먼지 : " + pm10 + " ㎍/m3"
            
            guard let pm25 = self.dataFromAirKorea?.dataOne?.dataTwo?.pm25 else { return }
            self.superDustLabel?.text =  "미세 먼지 : " + pm25 + " ㎍/m3"
            
            if 0 <= Double(pm10)! && 30 > Double(pm10)!
            {
                self.todayResultLabel?.text = "미세먼지 농도가 좋습니다"
                self.backgroundView?.backgroundColor = UIColor(red: 223/255, green: 227/255, blue: 238/255, alpha: 1)
            } else if 30 <= Double(pm10)! && 80 > Double(pm10)!
            {
                self.todayResultLabel?.text = "미세먼지 농도가 보통이에요"
                self.backgroundView?.backgroundColor = UIColor(red: 227/255, green: 230/255, blue: 218/255, alpha: 1)
            } else if 80 <= Double(pm10)! && 150 > Double(pm10)!
            {
                self.todayResultLabel?.text = "미세먼지 농도가 나쁩니다"
                self.backgroundView?.backgroundColor = UIColor(red: 251/255, green: 217/255, blue: 211/255, alpha: 1)
            } else if 150 <= Double(pm10)!
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
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void )
    {
        if let lastLocation = self.locationManager.location
        {
            let geocoder = CLGeocoder()
            
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
    
    @IBAction func currentLocation(_ sender: Any)
    {
        location()
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchCity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = searchCity[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        specificCity = (cell.textLabel?.text)!
        location()
        self.navigationItem.searchController?.isActive = false
    }
}

extension ViewController: UISearchControllerDelegate, UISearchResultsUpdating
{
    func willPresentSearchController(_ searchController: UISearchController)
    {
        tableView.alpha = 1.0
    }
    
    func willDismissSearchController(_ searchController: UISearchController)
    {
        tableView.alpha = 0.0
        filterContent(searchText: "")
    }
    
    func filterContent(searchText: String)
    {
        if searchText != ""
        {
            findMatches(searchText)
        } else
        {
            searchCity = baseCity
        }
        
        tableView.reloadData()
    }
    
    func findMatches(_ searchText: String)
    {
        let filtered = baseCity.filter
        {
            return $0.range(of: searchText, options: .caseInsensitive) != nil
        }
        
        self.searchCity = filtered
    }

    func updateSearchResults(for searchController: UISearchController)
    {
        filterContent(searchText: searchController.searchBar.text!)
    }
}
