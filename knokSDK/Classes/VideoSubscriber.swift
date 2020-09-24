//
//  VideoSubscriber.swift
//  knokSDK
//
//  Created by André Sousa on 26/08/2020.
//  Copyright © 2020 Seems Possible, Lda. All rights reserved.
//

import UIKit
import OpenTok

public class VideoSubscriber: NSObject {
    public var container : OTSubscriber!
    convenience init(with subscriber: OTSubscriber) {
        self.init()
        self.container = subscriber
    }
}
