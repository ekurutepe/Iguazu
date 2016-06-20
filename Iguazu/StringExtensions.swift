//
//  StringExtensions.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 20/06/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

extension String {
    func extract(from start:Int, length: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(startIndex, offsetBy: length)
        
        return self.substring(with: startIndex..<endIndex)
    }
}
