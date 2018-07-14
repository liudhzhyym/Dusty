//
//  ViewController.swift
//  Dusty
//
//  Created by moonhohyeon on 2/5/18.
//  Copyright © 2018 macker. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMobileAds
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate
{
    var interstitial: GADInterstitial!
    
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
    var predictIndex1: Int?
    var predictIndex2: Int?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        request.testDevices = [ "7416938804bd66f79e049ba3971c964b" ]
        interstitial.load(request)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.autocapitalizationType = .none
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "위치 검색"
        definesPresentationContext = true
        searchCity = baseCity
        
        if #available(iOS 11.0, *)
        {
            self.navigationItem.searchController = searchController
        } else
        {
            print("need iOS 11.0 or higher")
        }
        
        if #available(iOS 11.0, *)
        {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else
        {
            print("need iOS 11.0 or higher")
        }                
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard (locations.last?.coordinate) != nil else { return }
        
        let headers: HTTPHeaders = ["Authorization": "KakaoAK c70e9056ac2981fa07457549afe9ee25"]
        
        if let xCoordinate = locations.last?.coordinate.longitude,
            let yCoordinate = locations.last?.coordinate.latitude
        {
            let url = "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=\(xCoordinate)&y=\(yCoordinate)&input_coord=WGS84"
            
            Alamofire.request(url, headers: headers).responseJSON { response in
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print(utf8Text)
                }
            }
        }
        
        location()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if (status == CLAuthorizationStatus.denied)
        {
            self.navigationController?.navigationBar.topItem?.title = "위치 접근 불가"
        }
    }
    
    func location()
    {
        lookUpCurrentLocation { (placemark) in
            if let rawCity = placemark?.administrativeArea
            {
                switch rawCity
                {
                case "Seoul",
                     "서울특별시":
                    self.city = "서울"
                    self.predictIndex1 = 5
                    self.predictIndex2 = 6
                case "Busan",
                     "부산광역시":
                    self.city = "부산"
                    self.predictIndex1 = 77
                    self.predictIndex2 = 78
                case "Daegu",
                     "대구광역시":
                    self.city = "대구"
                    self.predictIndex1 = 69
                    self.predictIndex2 = 70
                case "Incheon",
                     "인천광역시":
                    self.city = "인천"
                    self.predictIndex1 = 153
                    self.predictIndex2 = 154
                case "Gwangju",
                     "광주광역시":
                    self.city = "광주"
                    self.predictIndex1 = 37
                    self.predictIndex2 = 38
                case "Daejeon",
                     "대전광역시":
                    self.city = "대전"
                    self.predictIndex1 = 109
                    self.predictIndex2 = 110
                case "Gyeonggi-do",
                     "경기도":
                    self.city = "경기"
                    self.predictIndex1 = 135
                    self.predictIndex2 = 136
                case "Gangwon",
                     "강원도":
                    self.city = "강원"
                case "North Chungcheong",
                     "충청북도":
                    self.city = "충북"
                    self.predictIndex1 = 93
                    self.predictIndex2 = 94
                case "South Chungcheong",
                     "충청남도":
                    self.city = "충남"
                    self.predictIndex1 = 85
                    self.predictIndex2 = 86
                case "North Jeolla",
                     "전라북도":
                    self.city = "전북"
                    self.predictIndex1 = 29
                    self.predictIndex2 = 30
                case "South Jeolla",
                     "전라남도":
                    self.city = "전남"
                    self.predictIndex1 = 21
                    self.predictIndex2 = 22
                case "North Gyeongsang",
                     "경상북도":
                    self.city = "경북"
                    self.predictIndex1 = 53
                    self.predictIndex2 = 54
                case "South Gyeongsang",
                     "경상남도":
                    self.city = "경남"
                    self.predictIndex1 = 45
                    self.predictIndex2 = 46
                case "Jeju",
                     "제주도",
                     "제주시":
                    self.city = "제주"
                    self.predictIndex1 = 13
                    self.predictIndex2 = 14
                default:
                    self.city = "위치 확인 불가"
                    self.predictIndex1 = nil
                    self.predictIndex2 = nil
                }
                
                self.load()
            } else
            {
                self.city = "위치 시스템 고장"
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
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(self.city, forKey: "city")
            
            if let specificCity = self.specificCity
            {
                self.navigationController?.navigationBar.topItem?.title = specificCity
                UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(specificCity, forKey: "city")
            }
            
            if let khai = self.dataFromAirKorea?.dataOne?.dataTwo?.khai
            {
                self.overallAirLabel?.text = khai
                UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(khai, forKey: "khai")
            } else
            {
                self.overallAirLabel?.text = "-"
                UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("-", forKey: "khai")
            }
            
            if let pm10 = self.dataFromAirKorea?.dataOne?.dataTwo?.pm10
            {
                self.fineDustLabel?.text =  "미세먼지 : " + pm10 + " ㎍/m3"
                UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 : " + pm10 + " ㎍/m3", forKey: "pm10")
                
                if let pm100 = Int(pm10)
                {
                    if 0 <= pm100 && 30 > pm100
                    {
                        self.todayResultLabel?.text = "미세먼지 농도가 좋습니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 223/255, green: 227/255, blue: 238/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 좋습니다", forKey: "today")
                    } else if 30 <= pm100 && 80 > pm100
                    {
                        self.todayResultLabel?.text = "미세먼지 농도가 보통입니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 227/255, green: 230/255, blue: 218/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 보통입니다", forKey: "today")
                    } else if 80 <= pm100 && 150 > pm100
                    {
                        self.todayResultLabel?.text = "미세먼지 농도가 나쁩니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 251/255, green: 217/255, blue: 211/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 나쁩니다", forKey: "today")
                    } else if 150 <= pm100
                    {
                        self.todayResultLabel?.text = "미세먼지가 농도가 매우 나쁩니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 매우 나쁩니다", forKey: "today")
                    } else
                    {
                        self.todayResultLabel?.text = "미세먼지 농도 측정이 불가합니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 223/255, green: 227/255, blue: 238/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도 측정이 불가합니다", forKey: "today")
                    }
                } else
                {
                    self.todayResultLabel?.text = "미세먼지 농도 측정이 불가합니다"
                    self.backgroundView?.backgroundColor = UIColor(red: 223/255, green: 227/255, blue: 238/255, alpha: 1)
                    UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도 측정이 불가합니다", forKey: "today")
                }
            } else
            {
                self.fineDustLabel?.text =  "미세먼지 : - ㎍/m3"
                UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 : - ㎍/m3", forKey: "pm10")
            }
            
            if let pm25 = self.dataFromAirKorea?.dataOne?.dataTwo?.pm25
            {
                self.superDustLabel?.text =  "초미세먼지 : " + pm25 + " ㎍/m3"
                UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("초미세먼지 : " + pm25 + " ㎍/m3", forKey: "pm25")
            } else
            {
                self.superDustLabel?.text =  "초미세먼지 : - ㎍/m3"
                UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("초미세먼지 : - ㎍/m3", forKey: "pm25")
            }
            
            self.specificCity = nil
        })
        
//        if let index1 = self.predictIndex1, let index2 = self.predictIndex2
//        {
//            self.dataFromAirKorea2 = DataFromAirKorea2(index1: index1, index2: index2, completeHandler: {
//                self.predictLabel?.text = "내일 미세먼지 : " + "\(self.dataFromAirKorea2?.dataThree?.dataFour?.str ?? "--")"
//            })
//        }
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
    
    @objc func keyboardWillShow(_ notification:Notification)
    {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
    }
    
    @objc func keyboardWillHide(_ notification:Notification)
    {
        tableView.contentInset = UIEdgeInsets.zero
    }
    
    @IBAction func currentLocation(_ sender: Any)
    {
        locationManager.startUpdatingLocation()
                
        if interstitial.isReady
        {
            interstitial.present(fromRootViewController: self)
        } else
        {
            print("ad wasn't ready")
        }
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
        
        if #available(iOS 11.0, *)
        {
            self.navigationItem.searchController?.isActive = false
        } else
        {
            print("need iOS 11.0 or higher")
        }
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
