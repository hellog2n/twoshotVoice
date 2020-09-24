//
//  Signaling.swift
//  VideoChatApp
//
//  Created by 2ug2n on 2020/07/28.
//  Copyright © 2020 jinji. All rights reserved.
//

import Foundation

// Codable : Decodable과 Encodable을 채택함. 외부표현식 JSON으로 변환할 수 있다.
struct SDP: Codable {
    let sdp: String
}

struct SignalingMessage: Codable {
    let type: String
    let sessionDescription: SDP?
    let candidate: Candidate?
    let destination: String?
    let source: String?
}

struct Candidate: Codable {
    let sdp: String
    let sdpMLineIndex: Int32
    let sdpMid: String
}
