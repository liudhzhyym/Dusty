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

// searchTerm > X, Y > umdName > tmX, tmY > stationName > pm
// 카카오 검색 api > 카카오 주소 api > 미세먼지 9,6,12 api
class ViewController: UIViewController, CLLocationManagerDelegate, GADInterstitialDelegate
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
    var addressCenter: AddressCenter?
    var umdCenter: UmdCenter?
    var tmCenter: TmCenter?
    var stationsCenter: StationsCenter?
    var searchCenter: SearchCenter?
    
    // 미세먼지 정보
    var xCoordinate: String?
    var yCoordinate: String?
    var sidoName: String?
    var sggName: String?
    var umdName: String?
    var tmX: String?
    var tmY: String?
    var stationName: String?
    var stationNames: [JSON] = []
    var pm10Value: String?
    var pm25Value: String?
    var khaiValue: String?
    
    // 검색에 필요
    var searchTerm: String?
    var info: [[String:JSON]] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 구글 전면 광고
        interstitial = createAndLoadInterstitial()
        
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        callInterface()
    }
    
    // 구글 전면 광고
    func createAndLoadInterstitial() -> GADInterstitial
    {
        // 테스트 광고
        // let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-2178088560941007/3979710443")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        
        return interstitial
    }
    
    // 구글 전면 광고 닫음
    func interstitialDidDismissScreen(_ ad: GADInterstitial)
    {
        interstitial = createAndLoadInterstitial()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // 위치 좌표 받아오기
        if let xCoordinate = locations.last?.coordinate.longitude,
            let yCoordinate = locations.last?.coordinate.latitude
        {
            self.xCoordinate = "\(xCoordinate)"
            self.yCoordinate = "\(yCoordinate)"
            
            self.callAddressCenter()
        }
        
        // 위치 정보 업데이트 정지
        locationManager.stopUpdatingLocation()
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
    
    // 위치 좌표로 지번주소 및 읍면동 받아오기
    func callAddressCenter()
    {
        self.addressCenter = AddressCenter(xCoordinate: self.xCoordinate, yCoordinate: self.yCoordinate, completeHandler: {
            self.sidoName = self.addressCenter?.sidoName
            self.sggName = self.addressCenter?.sggName
            self.umdName = self.addressCenter?.umdName
            
            self.callUmdCenter()
        })
    }
    
    // 지번 주소 및 읍면동으로 tm 좌표 받아오기
    func callUmdCenter()
    {
        self.umdCenter = UmdCenter(sggName: self.sggName, umdName: self.umdName, completeHandler: {
            self.tmX = self.umdCenter?.tmX
            self.tmY = self.umdCenter?.tmY            
            
            self.callTmCenter()
        })
    }
    
    // tm 좌표로 측정소명 받아오기
    func callTmCenter()
    {
        self.tmCenter = TmCenter(tmX: self.tmX, tmY: tmY, completeHandler: {
            self.stationNames = (self.tmCenter?.stationNames)!
            
            self.callStationsCenter()
        })
    }
    
    // 측정소명으로 미세먼지 정보 받아오기
    func callStationsCenter()
    {
        self.stationsCenter = StationsCenter(stationNames: self.stationNames, completeHandler: {
            
            for (index, element) in self.stationsCenter!.pm10Values.enumerated()
            {
                if element != ""
                {
                    let stationName = self.stationsCenter?.stationNames[index]
                    UserDefaults.init(suiteName: "group.com.macker.Dusty")?.setValue(stationName, forKey: "station")
                    
                    self.pm10Value = self.stationsCenter?.pm10Values[index]
                    self.pm25Value = self.stationsCenter?.pm25Values[index]
                    self.khaiValue = self.stationsCenter?.khaiValues[index]
                    
                    break
                }
            }
            
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
            
            if let pm10 = Int(pm10Value)
            {
                if let whoBool = UserDefaults.init(suiteName: "group.com.macker.Dusty")?.value(forKey: "switch") as? Bool
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
                }
            } else
            {
                self.todayResultLabel?.text = "미세먼지 농도 측정이 불가합니다"
                self.backgroundView?.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
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
        
        // 구글 전면 광고
        // if interstitial.isReady
        // {
        //     interstitial.present(fromRootViewController: self)
        // } else
        // {
        //     print("ad wasn't ready")
        // }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return info.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let address = info[indexPath.row]["address"]?.dictionary
        {
            cell.textLabel?.text = address["address_name"]?.stringValue
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if let address = info[indexPath.row]["address"]?.dictionary
        {
            if address["address_name"]?.stringValue == cell.textLabel?.text
            {
                self.xCoordinate = info[indexPath.row]["x"]?.stringValue
                self.yCoordinate = info[indexPath.row]["y"]?.stringValue                
            }
        }
        
        self.callAddressCenter()
        
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
        if let searchTerm = searchController.searchBar.text
        {
            self.searchTerm = searchTerm
            callSearchCenter()
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController)
    {
        tableView.alpha = 0.0
        self.info = []
        tableView.reloadData()
    }
    
    func callSearchCenter()
    {
        self.searchCenter = SearchCenter(searchTerm: self.searchTerm, completeHandler: {
            self.info = (self.searchCenter?.info)!
            self.tableView.reloadData()
        })
    }
}
