//
//  MainViewController.swift
//  VoiceCallNew
//
//  Created by 2ug2n on 2020/10/06.
//

import Foundation
import AVFoundation
import WebRTC




class MainViewController: UIViewController {
    @IBOutlet weak var signalingStatusLabel: UILabel!
    
    @IBOutlet weak var localSdpStatusLabel: UILabel!
    @IBOutlet weak var localCandidatesLabel: UILabel!
    @IBOutlet weak var remoteSdpStatusLabel: UILabel!
    @IBOutlet weak var remoteCandidatesLabel: UILabel!
    
    private let config = Config.default
    
    
//    private func buildMainViewController() -> UIViewController {
//
//        let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
//        let signalClient = self.buildSignalingClient()
//        //let mainViewController = MainViewController(signalClient: signalClient, webRTCClient: webRTCClient)
//        let navViewController = UINavigationController(rootViewController: mainViewController)
//        if #available(iOS 11.0, *) {
//            navViewController.navigationBar.prefersLargeTitles = true
//        }
//        else {
//            navViewController.navigationBar.isTranslucent = false
//        }
//        return navViewController
//    }

    private func buildSignalingClient() -> SignalingClient {
        
        // iOS 13 has native websocket support. For iOS 12 or lower we will use 3rd party library.
        let webSocketProvider: WebSocketProvider
        
        if #available(iOS 13.0, *) {
            webSocketProvider = NativeWebSocket(url: self.config.signalingServerUrl)
        } else {
            webSocketProvider = StarscreamWebSocket(url: self.config.signalingServerUrl)
        }
        
        return SignalingClient(webSocket: webSocketProvider)
    }
    
    
    private var signalClient: SignalingClient!
    private var webRTCClient: WebRTCClient!
    //private lazy var videoViewController = VideoViewController(webRTCClient: self.webRTCClient)

    private var signalingConnected: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.signalingConnected {
                    self.signalingStatusLabel?.text = "Connected"
                    self.signalingStatusLabel?.textColor = UIColor.green
                }
                else {
                    self.signalingStatusLabel?.text = "Not connected"
                    self.signalingStatusLabel?.textColor = UIColor.red
                }
            }
        }
    }
    
    private var hasLocalSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.localSdpStatusLabel?.text = self.hasLocalSdp ? "✅" : "❌"
            }
        }
    }
    
    private var localCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.localCandidatesLabel?.text = "\(self.localCandidateCount)"
            }
        }
    }
    
    private var hasRemoteSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.remoteSdpStatusLabel?.text = self.hasRemoteSdp ? "✅" : "❌"
            }
        }
    }
    
    private var remoteCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.remoteCandidatesLabel?.text = "\(self.remoteCandidateCount)"
            }
        }
    }
    
    func setClient(signalClient: SignalingClient, webRTCClient: WebRTCClient) {
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
    }
    
    
//
//     init(signalClient: SignalingClient, webRTCClient: WebRTCClient) {
//        self.signalClient = signalClient
//        self.webRTCClient = webRTCClient
//        super.init(nibName: String(describing: MainViewController.self), bundle: nil)
//    }
//
//
//    @available(*, unavailable)
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        let signalClient = self.buildSignalingClient()
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
        
        self.title = "WebRTC Demo"
        self.signalingConnected = false
        self.hasLocalSdp = false
        self.hasRemoteSdp = false
        self.localCandidateCount = 0
        self.remoteCandidateCount = 0
        self.webRTCClient.delegate = self
        self.signalClient.delegate = self
        self.signalClient.connect()
    }
    
    
    @IBAction func offerDidTap(_ sender: Any) {
        self.webRTCClient.offer { (sdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: sdp)
        }
    }
    
    @IBAction func answerDidTap(_ sender: Any) {
        self.webRTCClient.answer { (localSdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: localSdp)
        }
    }
    
    @IBAction func videoDidTap(_ sender: Any) {
        let vcName = self.storyboard?.instantiateViewController(identifier: "videoViewController") as VideoViewController?
        vcName!.webRTCClient = self.webRTCClient
        self.present(vcName!, animated: true, completion: nil)
    }
    
    
}


extension MainViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        self.webRTCClient.set(remoteSdp: sdp) { (error) in
            self.hasRemoteSdp = true
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("Received remote candidate")
        self.remoteCandidateCount += 1
        self.webRTCClient.set(remoteCandidate: candidate)
    }
}

extension MainViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        let textColor: UIColor
        switch state {
        case .connected, .completed:
            textColor = .green
        case .disconnected:
            textColor = .orange
        case .failed, .closed:
            textColor = .red
        case .new, .checking, .count:
            textColor = .black
        @unknown default:
            textColor = .black
        }
//        DispatchQueue.main.async {
//            self.webRTCStatusLabel?.text = state.description.capitalized
//            self.webRTCStatusLabel?.textColor = textColor
//        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

