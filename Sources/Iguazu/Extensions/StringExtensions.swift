//
//  StringExtensions.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 20/06/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

extension StringProtocol {

    /// Extract a substring from this string
    ///
    /// - parameter start:  start index for the substring
    /// - parameter length: length of the substring to extract
    ///
    /// - returns: the extracted substring
    func extractString(from start: Int, length: Int) -> String? {
      let realLength = (length > 0) ? length : self.count - start - 1
        guard start + realLength <= self.utf8.count,
            start >= 0 else { return nil }

        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(startIndex, offsetBy: length)
        let val = self[startIndex ..< endIndex]
        return String(val)
    }

    /// Extract date components for the time in the format HHMMSS from this
    /// string starting at given index.
    ///
    /// - parameter start:  the index where the time string of the format HHMMSS starts
    ///
    /// - returns: DateComponents with hour, minute and seconds fields set if
    ///            the string could be extracted. Nil otherwise.
//    func extractTime(from start: Int) -> DateComponents? {
//        
//    }

    /// <#Description#>
    ///
    /// - parameter start: <#start description#>
    ///
    /// - returns: <#return value description#>
    func extractLatitude(from start: Int) -> Double? {
        //    B 104915 5210978N 00006639W A 00114 00065 031 000
        let length = 8
        guard start >= 0,
            start + length <= self.utf8.count else { return nil }

        guard let degress = Double(self.extractString(from: start, length: 2)!),
            let minutesInt = Double(self.extractString(from: start + 2, length: 2)!),
            let minutesFrac = Double(self.extractString(from: start + 4, length: 3)!),
            let hemisphere = self.extractString(from: start + 7, length: 1) else { return nil }

        let minutes = minutesInt + minutesFrac / 1000

        let lat = degress + minutes / 60

        guard hemisphere == "N" else { return -1 * lat }

        return lat
    }

    /// <#Description#>
    ///
    /// - parameter start: <#start description#>
    ///
    /// - returns: <#return value description#>
    func extractLongitude(from start: Int) -> Double? {
        //    B 104915 5210978N 00006639W A 00114 00065 031 000
        let length = 9
        guard start >= 0,
            start + length <= self.utf8.count else { return nil }

        guard let degress = Double(self.extractString(from: start, length: 3)!),
            let minutesInt = Double(self.extractString(from: start + 3, length: 2)!),
            let minutesFrac = Double(self.extractString(from: start + 5, length: 3)!),
            let hemisphere = self.extractString(from: start + 8, length: 1) else { return nil }

        let minutes = minutesInt + minutesFrac / 1000

        let lng = degress + minutes / 60

        guard hemisphere == "E" else { return -1 * lng }

        return lng
    }

    func extractAltitude(from start: Int) -> Int? {
        let length = 5
        guard start >= 0,
            start + length <= self.utf8.count else { return nil }

        return extractString(from: start, length: length).flatMap { Int($0) }
    }

    func extractAccuracy(from start: Int) -> Int? {
        let length = 3
        guard start >= 0,
            start + length <= self.utf8.count else { return nil }

        return extractString(from: start, length: length).flatMap { Int($0) }
    }

    func igcHeaderPrefix() -> IGCHeaderField.HeaderRecordCode? {
        let code = self.extractString(from: 2, length: 3) ?? ""
        
        return IGCHeaderField.HeaderRecordCode(rawValue: code)
    }

}
