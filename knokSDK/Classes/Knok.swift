//
//  knokSDK.swift
//  knokSDK
//
//  Created by André Sousa on 24/08/2020.
//  Copyright © 2020 Seems Possible, Lda. All rights reserved.
//

import Foundation
import OpenTok

public protocol SessionListener {
    func onStreamReceived(videoSubscriber: VideoSubscriber)
    func onConnected(videoPublisher: VideoPublisher)
    func onStreamDropped()
}

public class Knok: NSObject, OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate, OTSubscriberKitDelegate {
    
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

    public func startVideoAppointment() {
        session = OTSession(apiKey: self.apiKey!, sessionId: videoSession!.sessionId!, delegate: self)
        videoToken = videoSession!.sessionToken
        var error: OTError?
        defer {
            processConnectionError(error)
        }
        session!.connect(withToken: videoToken!, error: &error)
    }
    
    public func setSessionListener(videoSessionListener: SessionListener) {
        sessionlistener = videoSessionListener
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

}
