//
//  WebRTCClient.swift
//  VideoChatApp
//
//  Created by 2ug2n on 2020/07/28.
//  Copyright © 2020 jinji. All rights reserved.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate {
    func didGenerateCandidate(iceCandidate: RTCIceCandidate)
    func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState)
    func didConnectWebRTC()
    func didDisconnectWebRTC()
    
}

class WebRTCClient: NSObject, RTCPeerConnectionDelegate, RTCVideoViewDelegate, RTCDataChannelDelegate {
    
    
    var delegate: WebRTCClientDelegate?
    public private(set) var isConnected: Bool = false
    
}
