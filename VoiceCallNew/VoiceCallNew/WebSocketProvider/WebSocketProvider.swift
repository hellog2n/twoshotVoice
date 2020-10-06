//
//  WebSocketProvider.swift
//  VoiceCallNew
//
//  Created by 2ug2n on 2020/10/06.
//

import Foundation

protocol WebSocketProvider: class {
    var delegate: WebSocketProviderDelegate? { get set }
    func connect()
    func send(data: Data)
}

protocol WebSocketProviderDelegate: class {
    func webSocketDidConnect(_ webSocket: WebSocketProvider)
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data)
}
