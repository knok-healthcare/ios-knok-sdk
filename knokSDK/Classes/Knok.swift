//
//  knokSDK.swift
//  knokSDK
//
//  Created by André Sousa on 24/08/2020.
//  Copyright © 2020 Seems Possible, Lda. All rights reserved.
//

import Foundation
import OpenTok

public protocol SetupListener {
    func onSetupSuccess()
    func onSetupError(message: String)
}

public protocol SessionListener {
    func onStreamReceived(videoSubscriber: VideoSubscriber)
    func onConnected(videoPublisher: VideoPublisher)
    func onStreamDropped()
}

public class Knok: NSObject, OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate, OTSubscriberKitDelegate {
    
    private var setupListener: SetupListener?
    private var sessionlistener: SessionListener?
    private var session: OTSession?
    private var videoToken: String?
    private var videoSession: VideoSession?
    private var apiKey: String?
    
    
    public convenience init(with knokApiKey: String, sessionId: String, sessionToken: String) {
        self.init()
        self.videoSession = VideoSession(sessionId: sessionId, sessionToken: sessionToken)
        self.apiKey = knokApiKey
    }

    
    public func setup(listener: SetupListener) {
        self.setupListener = listener
        requestPermissions()
    }
        
    public func setSessionListener(videoSessionListener: SessionListener) {
        sessionlistener = videoSessionListener
    }
    
    public func startVideoAppointment() {
        session = OTSession(apiKey: self.apiKey!, sessionId: videoSession!.sessionId!, delegate: self)
        videoToken = videoSession!.sessionToken
        var error: OTError?
        defer {
            processConnectionError(error)
        }
        session!.connect(withToken: videoToken!, error: &error)
    }

    public func subscribe(videoSubscriber: VideoSubscriber) {
        var error: OTError?
        defer { processError(error) }
        session?.subscribe(videoSubscriber.container, error: &error)
    }

    func disconnect() {
        var error: OTError?
        defer { processError(error) }
        session?.disconnect(&error)
    }

    public func publish(videoPublisher: VideoPublisher) {
        var error: OTError?
        defer { processError(error) }
        session?.publish(videoPublisher.container, error: &error)
    }

    
    // MARK: - Errors
    
    func processError(_ error: OTError?) {
        if let err = error {
            print("processError \(err)")
        }
    }
    
    func processConnectionError(_ error: OTError?) {
        if let err = error {
            print("processConnectionError \(err)")
        }
    }
    
    
    // MARK: - OTSession delegate callbacks
    
    public func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        let videoPublisher = VideoPublisher(with: OTPublisher(delegate: self)!)
        sessionlistener?.onConnected(videoPublisher: videoPublisher)
    }
    
    public func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }
    
    public func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        let videoSubscriber =
            VideoSubscriber(with: OTSubscriber(stream: stream, delegate: self)!)
        sessionlistener?.onStreamReceived(videoSubscriber: videoSubscriber)
    }
    
    public func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        sessionlistener?.onStreamDropped()
    }
    
    public func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect \(error)")
    }
    
    
    // MARK: - OTPublisher delegate callbacks
    
    public func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("publisher streamCreated \(stream.streamId)")
    }
    
    public func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        print("publisher streamDestroyed")
    }
    
    public func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
    
    
    // MARK: - OTSubscriber delegate callbacks
    
    public func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("subscriberDidConnect")
    }
    
    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
    public func subscriberVideoDataReceived(_ subscriber: OTSubscriber) {
        
    }
    
    
    // MARK: - OTSubscriberKit delegate callbacks
    
    public func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
    }
    
    
    // MARK: - Hardware access
    
    func requestPermissions() {
        if TARGET_OS_SIMULATOR != 0 {
            // target running in the simulator. just connect and return
            setupListener?.onSetupSuccess()
            return
        }
        
        var allowedCameraAccess = false
        var allowedMicAccess = false
        
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            allowedCameraAccess = true
        case .denied:
            alertPromptToAllowHardwareAccessViaSettings(hardware: NSLocalizedString("Camera", comment: "Camera"))
            return
        case .notDetermined:
            alertToEncourageHardwareAccessInitially()
            return
        default:
            alertToEncourageHardwareAccessInitially()
            return
        }
                
        let audioAuthStatus = AVAudioSession.sharedInstance().recordPermission()
        switch audioAuthStatus {
        case .granted:
            allowedMicAccess = true
        case .denied:
            alertPromptToAllowHardwareAccessViaSettings(hardware: NSLocalizedString("Microphone", comment: "Microphone"))
            return
        case .undetermined:
            requestMicrophoneAccess()
            return
        }

        if allowedCameraAccess && allowedMicAccess {
            setupListener?.onSetupSuccess()
        }
    }
    
    func alertToEncourageHardwareAccessInitially() {
        
        let alert = UIAlertController(
            title: NSLocalizedString("IMPORTANT", comment: ""),
            message: NSLocalizedString("Please allow camera and microphone access for Video calls", comment: ""),
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .cancel) { alert in
            if AVCaptureDevice.devices(for: AVMediaType.video).count > 0 {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { _ in
                    DispatchQueue.main.async() {
                        self.requestPermissions()
                    }
                }
            }
        })
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowHardwareAccessViaSettings(hardware: String) {
        
        let alert = UIAlertController(
            title: NSLocalizedString("IMPORTANT", comment: ""),
            message: NSLocalizedString("Access required for Video calls. Please go to settings and change your preferences", comment: ""),
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .cancel) { alert in
            if AVCaptureDevice.devices(for: AVMediaType.video).count > 0 {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { _ in
                    DispatchQueue.main.async() {
                        self.requestPermissions()
                    }
                }
            }
        })
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    func requestMicrophoneAccess() {
        
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async() {
                self.requestPermissions()
            }
        }
    }

}

