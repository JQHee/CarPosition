//
//  AppDelegate-AMap.swift
//  CarPosition
//
//  Created by HJQ on 2017/11/17.
//  Copyright © 2017年 HJQ. All rights reserved.
//

import Foundation

let AMap_appkey = "b7d82f5e6b2050472e7697f44999fd87"

// 高德地图
extension AppDelegate {
    
    // 高德地图初始化
    func AMap_setup() {
        AMapServices.shared().apiKey = AMap_appkey
        ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
        AMapServices.shared().enableHTTPS = true
    }
    
}
