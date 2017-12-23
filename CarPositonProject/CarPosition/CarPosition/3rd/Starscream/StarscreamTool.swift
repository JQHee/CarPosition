//
//  StarscreamTool.swift
//  CarPosition
//
//  Created by HJQ on 2017/11/17.
//  Copyright © 2017年 HJQ. All rights reserved.
//

import UIKit
import Starscream

class StarscreamTool {

    static let shared = StarscreamTool()
    private init(){
        //websocketDidConnect
        socket.onConnect = {
            print("websocket is connected")
            //self.socket.write(string: "12")
        }
        //websocketDidDisconnect
        socket.onDisconnect = { (error: Error?) in
            print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
        }
    }
    private let socket = WebSocket(url: URL(string: "ws://23.106.148.27:19501")!)
    
    // 初始化化
    func websocketDidReceiveMessage(resultBlock: @escaping (_ text: String)->()) {
        //websocketDidReceiveMessage
        socket.onText = { (text: String) in
            print("got some text: \(text)")
            resultBlock(text)
        }
    }
    
    func websocketDidReceiveData(resultBlock: @escaping (_ data: Data)->()) {
        //websocketDidReceiveData
        socket.onData = { (data: Data) in
            print("got some data: \(data.count)")
            resultBlock(data)
        }
    }
    
    // 连接
    func connect() {
        socket.connect()
    }
    
}
