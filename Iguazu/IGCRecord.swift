//
//  IGCRecord.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 12/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

/// Basic protocol all record types need to conform to.
protocol IGCRecord {
    var timestamp: Date { get }
}
