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

class ViewController: UIViewController, SetupListener, SessionListener {
        
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
        setup()
    }
    
    func setup() {
        knok = Knok(with: KNOK_API_KEY, sessionId: sessionId, sessionToken: sessionToken, setupListener: self)
    }
    
    func onSetupSuccess() {
        knok.setSessionListener(videoSessionListener: self)
        knok.startVideoAppointment()
    }
    
    func onSetupError(message: String) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .cancel))
        present(alert, animated: true, completion: nil)
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

}

