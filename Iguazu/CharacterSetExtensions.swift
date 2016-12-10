//
//  CharacterSetExtensions.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 10/12/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

extension CharacterSet {
    static var northSouth: CharacterSet {
        return CharacterSet(charactersIn: "NS")
    }
    
    static var eastWest: CharacterSet {
        return CharacterSet(charactersIn: "EW")
    }
    
    static var plusMinus: CharacterSet {
        return CharacterSet(charactersIn: "+-")
    }
}
