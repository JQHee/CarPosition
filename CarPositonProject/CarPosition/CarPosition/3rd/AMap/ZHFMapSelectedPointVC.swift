//
//  ZHFMapSelectedPointVC.swift
//  CarPosition
//
//  Created by HJQ on 2017/12/23.
//  Copyright © 2017年 HJQ. All rights reserved.
//

import UIKit

// 地图选点
class ZHFMapSelectedPointVC: UIViewController {

    @IBOutlet weak var labelCurrentLocation: UILabel!
    @IBOutlet weak var mapView: MAMapView!
    
    
    // MARK: - System methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
        //locationManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.delegate = nil
        //locationManager.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
        viewBindEvents()
    }
    
    // MARK: - Private method
    private func  setupMapView() {
        
        mapView.setZoomLevel(14, animated: false)
        // 显示定位蓝点
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        // 指南针
        mapView.showsCompass = false
        
    }
    
    
    private func setupLocationManager() {
        // 偏差在10米左右
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.locationTimeout = 10
        locationManager.reGeocodeTimeout = 10
        // 返回地址信息（true）
        locationManager.requestLocation(withReGeocode: true, completionBlock: { [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
            
            if let error = error {
                let error = error as NSError
                
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    NSLog("定位错误:{\(error.code) - \(error.localizedDescription)};")
                    return
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    
                    //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
                    NSLog("逆地理错误:{\(error.code) - \(error.localizedDescription)};")
                }
                else {
                    //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
                }
            }
            
            if let location = location {
                NSLog("location:%@", location)
            }
            
            if let reGeocode = reGeocode {
                NSLog("reGeocode:%@", reGeocode)
            }
        })
    }
    
    // 添加单击手势
    private func viewBindEvents() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(currentTapTapGes(ges: )))
        tap.delegate = self
        mapView.addGestureRecognizer(tap)
        
    }
    
    // 反地址编码
    private func setLocation(coordinate2D: CLLocationCoordinate2D) {

        AMapServices.shared().apiKey = AMap_appkey
        let location = CLLocation.init(latitude: coordinate2D.latitude, longitude: coordinate2D.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if (error != nil) {
                print("反编码失败")
            }else {
                print(placemarks ?? "")
                guard let _ = placemarks else {return}
                let placemark = placemarks?.last
                //let addressDict = placemark?.addressDictionary
                guard let place = placemark else {return}
                print(place.location ?? "")
                let city = place.locality == nil ? "" : place.locality!
                let province = place.administrativeArea == nil ? "" : place.administrativeArea!
                let sublocality = place.subLocality == nil ? "" : place.subLocality!
                let streetStr = place.thoroughfare == nil ? "" : place.thoroughfare!
                let subStreetStr = place.subThoroughfare == nil ? "" : place.subThoroughfare!
                
                print(province + city + sublocality + streetStr + subStreetStr)
            }
        }
        
    }

    // MARK: - Event respose
    @objc func currentTapTapGes(ges: UITapGestureRecognizer) {
        // 移除地图标注
        mapView.removeAnnotation(myLocation)
        
        // 坐标转换
        let touchPoint = ges.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        myLocation.coordinate = touchMapCoordinate
        mapView.addAnnotation(myLocation)
        
        // 反地址编码
        setLocation(coordinate2D: touchMapCoordinate)
    }
    
    
    @IBAction func sureAction(_ sender: Any) {
    }
    
    // MARK: - Lazy load
    // 大头针
    private lazy var myLocation: MAAnimatedAnnotation = MAAnimatedAnnotation()
    // 地图定位服务
    private lazy var locationManager: AMapLocationManager = AMapLocationManager()
    
}

// MARK: - MAMapViewDelegate
extension ZHFMapSelectedPointVC: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView, viewFor annotation: MAAnnotation) -> MAAnnotationView? {
        
        if annotation.isEqual(myLocation) {
            
            let annotationIdentifier = "myLcoationIdentifier"
            
            var poiAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
            if poiAnnotationView == nil {
                poiAnnotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            
            poiAnnotationView?.image = UIImage(named: "car")
            poiAnnotationView!.canShowCallout = false
            poiAnnotationView?.centerOffset = CGPoint.init(x: 0, y: -18)
            
            return poiAnnotationView;
        }
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let annotationIdentifier = "lcoationIdentifier"
            
            var poiAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MAPinAnnotationView
            
            if poiAnnotationView == nil {
                poiAnnotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            
            poiAnnotationView!.animatesDrop   = true
            poiAnnotationView!.canShowCallout = true
            
            return poiAnnotationView;
        }
        
        return nil
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension ZHFMapSelectedPointVC: UIGestureRecognizerDelegate {
    
    // 允许多手势响应
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
