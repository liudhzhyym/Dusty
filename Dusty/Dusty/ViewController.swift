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
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate
{
    // 구글 전면 광고
    var interstitial: GADInterstitial!
    
    // UI 요소들
    @IBOutlet var backgroundView: UIView?
    @IBOutlet weak var overallAirLabel: UILabel?
    @IBOutlet weak var fineDustLabel: UILabel?
    @IBOutlet weak var superDustLabel: UILabel?
    @IBOutlet weak var predictLabel: UILabel?
    @IBOutlet weak var todayResultLabel: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var graph: UIImageView!
    
    // 네트워킹에 필요
    lazy var locationManager = CLLocationManager()
    var stationName: String?
    var umdCenter: UmdCenter?
    var tmCenter: TmCenter?
    var stationCenter: StationCenter?
    
    // 미세먼지 정보
    var sidoName: String?
    var sggName: String?
    var umdName: String?
    var tmX: String?
    var tmY: String?
    var pm10Value: String?
    var pm25Value: String?
    var khaiValue: String?
    
    // 검색에 필요
    var fixedCities: [String] = []
    var sidoNames: [String] = []
    var sggNames: [String] = []
    var umdNames: [String] = []
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 구글 전면 광고
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        request.testDevices = [ "7416938804bd66f79e049ba3971c964b" ]
        interstitial.load(request)
        
        // 위치 정보 파악
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // 검색창
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.autocapitalizationType = .none
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "위치 검색"
        definesPresentationContext = true
        
        // 네비게이션바 검색창
        if #available(iOS 11.0, *)
        {
            self.navigationItem.searchController = searchController
        } else
        {
            print("need iOS 11.0 or higher")
        }
        
        // 네비게이션바 큰 타이틀
        if #available(iOS 11.0, *)
        {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else
        {
            print("need iOS 11.0 or higher")
        }
        
        // 검색시 키보드 작동
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // 카카오 지번주소 API 인증키
        let headers: HTTPHeaders = ["Authorization": "KakaoAK c70e9056ac2981fa07457549afe9ee25"]
        
        // 카카오 지번주소 API 네트워킹
        if let xCoordinate = locations.last?.coordinate.longitude,
            let yCoordinate = locations.last?.coordinate.latitude
        {
            let url = "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=\(xCoordinate)&y=\(yCoordinate)&input_coord=WGS84"
            callAdress(url: url, headers: headers) { self.callUmdCenter() }
        }
        
        // 위치 정보 업데이트 정지
        locationManager.stopUpdatingLocation()
    }
    
    func callUmdCenter()
    {
        self.umdCenter = UmdCenter(sggName: self.sggName, umdName: self.umdName, completeHandler: {
            self.tmX = self.umdCenter?.tmX
            self.tmY = self.umdCenter?.tmY
            
            self.callTmCenter()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        // 위치 꺼놨을때
        if (status == CLAuthorizationStatus.denied)
        {
            self.navigationController?.navigationBar.topItem?.title = "위치 접근 불가"
            
            let alertController = UIAlertController(title: "위치 접근 불가", message: "설정 → 먼지먼지 → 위치 → 앱을 사용하는 동안으로 설정해주세요", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default) { (action:UIAlertAction) in }
            
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // 현재 위치 좌표로 지번주소 및 읍면동 받아오기
    func callAdress(url: String, headers: HTTPHeaders, completeHandler: @escaping ()->Void)
    {
        Alamofire.request(url, headers: headers).responseJSON { response in
            if let data = response.data
            {
                do
                {
                    let json = try JSON(data: data)
                    
                    self.sidoName = "\(json["documents"][0]["address"]["region_1depth_name"])"
                    self.sggName = "\(json["documents"][0]["address"]["region_2depth_name"])"
                    self.umdName = "\(json["documents"][0]["address"]["region_3depth_name"])"
                    
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
    
    // 지번 주소 및 읍면동으로 tm 좌표 받아오기
    func callUmdCenter()
    {
        self.umdCenter = UmdCenter(sggName: self.sggName, umdName: self.umdName, completeHandler: {
//            self.sidoName = self.umdCenter?.sidoName
//            self.sggName = self.umdCenter?.sggName
//            self.umdName = self.umdCenter?.umdName
            self.tmX = self.umdCenter?.tmX
            self.tmY = self.umdCenter?.tmY
            
            self.callTmCenter()
        })
    }
    
    // tm 좌표로 측정소명 받아오기
    func callTmCenter()
    {
        self.tmCenter = TmCenter(tmX: self.tmX, tmY: tmY, completeHandler: {
            self.stationName = self.tmCenter?.stationName
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(self.stationName, forKey: "station")
            
            self.callStationCenter()
        })
    }
    
    // 측정소명으로 미세먼지 정보 받아오기
    func callStationCenter()
    {
        self.stationCenter = StationCenter(stationName: self.stationName, completeHandler: {
            self.pm10Value = self.stationCenter?.pm10Value
            self.pm25Value = self.stationCenter?.pm25Value
            self.khaiValue = self.stationCenter?.khaiValue
            
            self.callInterface()
        })
    }
    
    // 미세먼지 정보 화면에 나타내기
    func callInterface()
    {
        if let umdName = self.umdName
        {
            self.navigationController?.navigationBar.topItem?.title = umdName
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(umdName, forKey: "city")
        } else
        {
            self.navigationController?.navigationBar.topItem?.title = "--"
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("--", forKey: "city")
        }
        
        if let khaiValue = self.khaiValue
        {
            self.overallAirLabel?.text = khaiValue
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(khaiValue, forKey: "khai")
        } else
        {
            self.overallAirLabel?.text = "-"
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("-", forKey: "khai")
        }
        
        if let pm10Value = self.pm10Value
        {
            self.fineDustLabel?.text =  "미세먼지 : " + pm10Value + " ㎍/m3"
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 : " + pm10Value + " ㎍/m3", forKey: "pm10")
            
            if let pm10 = Int(pm10Value),
                let whoBool = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "switch") as? Bool
            {
                if whoBool
                {
                    if 0 <= pm10 && 30 > pm10
                    {
                        self.todayResultLabel?.text = "미세먼지 농도가 좋습니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 214/255, green: 221/255, blue: 238/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 좋습니다", forKey: "today")
                    } else if 30 <= pm10 && 50 > pm10
                    {
                        self.todayResultLabel?.text = "미세먼지 농도가 보통입니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 236/255, green: 242/255, blue: 218/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 보통입니다", forKey: "today")
                    } else if 50 <= pm10 && 100 > pm10
                    {
                        self.todayResultLabel?.text = "미세먼지 농도가 나쁩니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 240/255, green: 201/255, blue: 192/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 나쁩니다", forKey: "today")
                    } else if 100 <= pm10
                    {
                        self.todayResultLabel?.text = "미세먼지가 농도가 매우 나쁩니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 매우 나쁩니다", forKey: "today")
                    } else
                    {
                        self.todayResultLabel?.text = "미세먼지 농도 측정이 불가합니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도 측정이 불가합니다", forKey: "today")
                    }
                    
                    graph.image = UIImage(named: "who graph.png")
                } else
                {
                    if 0 <= pm10 && 30 > pm10
                    {
                        self.todayResultLabel?.text = "미세먼지 농도가 좋습니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 214/255, green: 221/255, blue: 238/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 좋습니다", forKey: "today")
                    } else if 30 <= pm10 && 80 > pm10
                    {
                        self.todayResultLabel?.text = "미세먼지 농도가 보통입니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 236/255, green: 242/255, blue: 218/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 보통입니다", forKey: "today")
                    } else if 80 <= pm10 && 150 > pm10
                    {
                        self.todayResultLabel?.text = "미세먼지 농도가 나쁩니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 240/255, green: 201/255, blue: 192/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 나쁩니다", forKey: "today")
                    } else if 150 <= pm10
                    {
                        self.todayResultLabel?.text = "미세먼지가 농도가 매우 나쁩니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도가 매우 나쁩니다", forKey: "today")
                    } else
                    {
                        self.todayResultLabel?.text = "미세먼지 농도 측정이 불가합니다"
                        self.backgroundView?.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
                        UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("미세먼지 농도 측정이 불가합니다", forKey: "today")
                    }
                    
                    graph.image = UIImage(named: "graph.png")
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
        
        if let pm25Value = self.pm25Value
        {
            self.superDustLabel?.text =  "초미세먼지 : " + pm25Value + " ㎍/m3"
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("초미세먼지 : " + pm25Value + " ㎍/m3", forKey: "pm25")
        } else
        {
            self.superDustLabel?.text =  "초미세먼지 : - ㎍/m3"
            UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue("초미세먼지 : - ㎍/m3", forKey: "pm25")
        }
    }
    
    // 키보드 편의 기능
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
    
    // 현재 위치 눌렀을때 실행되는 메소드
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
        return fixedCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = fixedCities[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        for (index, cityName) in self.fixedCities.enumerated()
        {
            if cityName == cell.textLabel?.text
            {
                self.sidoName = sidoNames[index]
                self.sggName = sggNames[index]
                self.umdName = umdNames[index]
            }
        }
        
        self.callUmdCenter()
        
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
    
    func updateSearchResults(for searchController: UISearchController)
    {
        if let searchTerm = searchController.searchBar.text,
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
                        
                        self.fixedCities = []
                        self.sidoNames = []
                        self.sggNames = []
                        self.umdNames = []
                        
                        for place in json["documents"]
                        {
                            self.fixedCities.append("\(place.1["address"]["address_name"])")
                            self.sidoNames.append("\(place.1["address"]["region_1depth_name"])")
                            self.sggNames.append("\(place.1["address"]["region_2depth_name"])")
                            
                            if "\(place.1["address"]["region_3depth_name"])" != ""
                            {
                                self.umdNames.append("\(place.1["address"]["region_3depth_name"])")
                            } else
                            {
                                self.umdNames.append("\(place.1["address"]["region_3depth_h_name"])")
                            }
                            
                            self.tableView.reloadData()
                        }
                    } catch let error
                    {
                        print("\(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController)
    {
        tableView.alpha = 0.0
        fixedCities = []
        tableView.reloadData()
    }
}
