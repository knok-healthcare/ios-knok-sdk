//
//  VideoPublisher.swift
//  knokSDK
//
//  Created by André Sousa on 26/08/2020.
//  Copyright © 2020 Seems Possible, Lda. All rights reserved.
//

import UIKit
import OpenTok

public class VideoPublisher: NSObject {
    public var container : OTPublisher!
    convenience init(with publisher: OTPublisher) {
        self.init()
        self.container = publisher
    }
}
