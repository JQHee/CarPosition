//
//  ViewController.swift
//  CarPosition
//
//  Created by HJQ on 2017/11/17.
//  Copyright © 2017年 HJQ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var mapView: MAMapView!
    private lazy var myLocation: MAAnimatedAnnotation = MAAnimatedAnnotation()
    private var timer: Timer?
    private var latitude: CGFloat = 22.844539
    private var longitude: CGFloat = 108.318774
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "汽车定位"
        setupUI()
        setupWebSocket()
        addTimer()
        setupNavBar()
    
    }
    
    // MARK: - Private methods
    private func setupUI() {
        initMapView()
    }
    
    private func setupNavBar() {
        let rightBarItem = UIBarButtonItem.init(title: "测试", style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightItemAction))
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    @objc func rightItemAction() {
        
        let VC = ZHFMapSelectedPointVC()
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
    private func addTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(tickDown), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    @objc private func tickDown() {
        setupData()
    }
    
    
    private func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.setZoomLevel(14, animated: false)
        // 显示定位蓝点
        //mapView.showsUserLocation = true
        //mapView.userTrackingMode = .follow
        mapView.delegate = self
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
    }
    
    // 初始化webSoket
    private func setupWebSocket() {
        StarscreamTool.shared.websocketDidReceiveData { (data) in
            //self.setupData()
            
        }
        
        StarscreamTool.shared.websocketDidReceiveMessage { (text) in
            
        }
        StarscreamTool.shared.connect()
    }
    
    // 填充数据
    private func setupData() {
        
        mapView?.removeAnnotation(myLocation)
        let centerCoordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        // 设置中心点
        mapView.setCenter(centerCoordinate, animated: false)
        latitude = latitude + 0.0001
        longitude = longitude + 0.0001
        let coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        myLocation.coordinate = coordinate
        mapView.addAnnotation(myLocation)
        //mapView.showAnnotations([myLocation], animated: false)

    }
}

// MARK: - MAMapViewDelegate
extension ViewController: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView, viewFor annotation: MAAnnotation) -> MAAnnotationView? {
        
        if annotation.isEqual(myLocation) {
            
            let annotationIdentifier = "myLcoationIdentifier"
            
            var poiAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
            if poiAnnotationView == nil {
                poiAnnotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            
            poiAnnotationView?.image = UIImage(named: "car")
            poiAnnotationView!.canShowCallout = false
            
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

