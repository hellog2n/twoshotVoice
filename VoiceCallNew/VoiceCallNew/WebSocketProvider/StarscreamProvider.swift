//
//  StarscreamWebSocket.swift
//  VoiceCallNew
//
//  Created by 2ug2n on 2020/10/06.
//

import Foundation
import Starscream

class StarscreamWebSocket: WebSocketProvider {

    var delegate: WebSocketProviderDelegate?
    private let socket: WebSocket
    
    init(url: URL) {
        self.socket = WebSocket(url: url)
        self.socket.delegate = self
    }
    
    func connect() {
        self.socket.connect()
    }
    
    func send(data: Data) {
        self.socket.write(data: data)
    }
}

extension StarscreamWebSocket: Starscream.WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        self.delegate?.webSocketDidConnect(self)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.delegate?.webSocketDidDisconnect(self)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        self.delegate?.webSocket(self, didReceiveData: data)
    }
    
    
}
