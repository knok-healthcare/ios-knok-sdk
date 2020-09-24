//
//  ViewController.swift
//  knokSDKExample
//
//  Created by André Sousa on 24/08/2020.
//  Copyright © 2020 Seems Possible, Lda. All rights reserved.
//

import UIKit
import knokSDK
import AVFoundation

class ViewController: UIViewController,
SessionListener {
        
    private let KNOK_API_KEY = ""
    private let sessionId = ""
    private let sessionToken = ""
    
    private var knok: Knok!
    private var publisher: VideoPublisher!
    private var subscriber: VideoSubscriber!

    @IBOutlet weak var publisherView : UIView!
    @IBOutlet weak var subscriberView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestPermissions()
    }
    
    func requestPermissions() {
        if TARGET_OS_SIMULATOR != 0 {
            // target running in the simulator. just connect and return
            setup()
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
        
//        let audioAuthStatus = AVAudioSession.sharedInstance().recordPermission
//        switch audioAuthStatus {
//        case .granted:
//            allowedMicAccess = true
//        case .denied:
//            alertPromptToAllowHardwareAccessViaSettings(hardware: NSLocalizedString("Microphone", comment: "Microphone"))
//            return
//        case .undetermined:
//            requestMicrophoneAccess()
//            return
//        @unknown default:
//            requestMicrophoneAccess()
//            return
//        }
        
        if allowedCameraAccess && allowedMicAccess {
            setup()
        }
    }
    
    
    func setup() {
        knok = Knok(with: KNOK_API_KEY, sessionId: sessionId, sessionToken: sessionToken)
        knok.setSessionListener(videoSessionListener: self)
        knok.startVideoAppointment()
    }

    func onStreamReceived(videoSubscriber: VideoSubscriber) {
        subscriber = videoSubscriber
        knok.subscribe(videoSubscriber: subscriber!)
        subscriber.container!.view!.frame = subscriberView.frame
        subscriberView?.addSubview(subscriber.container!.view!)
    }
    
    func onConnected(videoPublisher: VideoPublisher) {
        publisher = videoPublisher
        publisher.container!.view!.frame = CGRect(x: 0, y: 0, width: publisherView.frame.width, height: publisherView.frame.height)
        publisherView?.addSubview(publisher.container!.view!)
        view.bringSubview(toFront: publisherView)
        knok.publish(videoPublisher: publisher)
    }
    
    func onStreamDropped() {
        if (subscriber != nil) {
            subscriber = nil
            subscriberView?.removeFromSuperview()
        }
    }
    
    
    // MARK: - Helpers
    
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
        present(alert, animated: true, completion: nil)
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
        present(alert, animated: true, completion: nil)
    }
    
    func requestMicrophoneAccess() {
        
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async() {
                self.requestPermissions()
            }
        }
    }

}

