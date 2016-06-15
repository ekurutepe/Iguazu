//
//  IGCExtension.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 14/06/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

enum IGCExtension {
    case fixAccuracy(startIndex:Int, finalIndex:Int, accuracy: Int)
    case engineNoiseLevel(startIndex:Int, finalIndex:Int, noiseLevel: Int)
}
