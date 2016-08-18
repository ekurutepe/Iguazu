//
//  StringExtensions.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 20/06/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

extension String {

    /// Extract a substring from this string
    ///
    /// - parameter start:  start index for the substring
    /// - parameter length: length of the substring to extract
    ///
    /// - returns: the extracted substring
    func extractString(from start: Int, length: Int) -> String? {
        guard start+length <= self.utf8.count,
            start >= 0 else { return nil }
        
        let startIndex = self.index(self.startIndex, offsetBy:start)
        let endIndex = self.index(startIndex, offsetBy: length)
        
        return self.substring(with: startIndex..<endIndex)
    }
    
    /// Extract date components for the time in the format HHMMSS from this 
    /// string starting at given index.
    ///
    /// - parameter start:  the index where the time string of the format HHMMSS starts
    ///
    /// - returns: DateComponents with hour, minute and seconds fields set if 
    ///            the string could be extracted. Nil otherwise.
    func extractTime(from start: Int) -> DateComponents? {
        let length = 6
        guard start >= 0,
        start+length <= self.utf8.count else { return nil }
        
        guard let hours = Int(self.extractString(from: start, length: 2)!),
            let minutes = Int(self.extractString(from: start+2, length: 2)!),
            let seconds = Int(self.extractString(from: start+4, length: 2)!) else { return nil }
        
        return DateComponents(calendar: Calendar.current,
            timeZone: TimeZone(abbreviation: "UTC"),
            era: nil,
            year: nil,
            month: nil,
            day: nil,
            hour: hours,
            minute: minutes,
            second: seconds,
            nanosecond: nil,
            weekday: nil,
            weekdayOrdinal: nil,
            quarter: nil,
            weekOfMonth: nil,
            weekOfYear: nil,
            yearForWeekOfYear: nil)
    }
    
    
    /// <#Description#>
    ///
    /// - parameter start: <#start description#>
    ///
    /// - returns: <#return value description#>
    func extractLatitude(from start: Int) -> Double? {
//    B 104915 5210978N 00006639W A 00114 00065 031 000
        let length = 8
        guard start >= 0,
            start+length <= self.utf8.count else { return nil }
        
        guard let degress = Double(self.extractString(from: start, length: 2)!),
            let minutesInt = Double(self.extractString(from: start+2, length: 2)!),
            let minutesFrac = Double(self.extractString(from: start+4, length: 3)!),
            let hemisphere = self.extractString(from: start+7, length: 1) else { return nil }
        
        let minutes = minutesInt + minutesFrac/1000
        
        let lat = degress + minutes/60
        
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
            start+length <= self.utf8.count else { return nil }
        
        guard let degress = Double(self.extractString(from: start, length: 3)!),
            let minutesInt = Double(self.extractString(from: start+2, length: 2)!),
            let minutesFrac = Double(self.extractString(from: start+4, length: 3)!),
            let hemisphere = self.extractString(from: start+7, length: 1) else { return nil }
        
        let minutes = minutesInt + minutesFrac/1000
        
        let lng = degress + minutes/60
        
        guard hemisphere == "E" else { return -1 * lng }
        
        return lng
    }
    
    func extractAltitude(from start: Int) -> Int? {
        let length = 5
        guard start >= 0,
            start+length <= self.utf8.count else { return nil }
        
        return extractString(from: start, length: length).flatMap { Int($0) }
    }
    
    // parse strings like 250809 to Aug 25th 2009
    func headerDate() -> Date? {
        guard self.characters.count == 6 else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard let date = dateFormatter.date(from: self) else { return nil }
        
        return date
    }
    
    func igcHeaderPrefix() -> IGCHeaderField.HeaderPrefix? {
        let index = self.index(self.startIndex, offsetBy: 5, limitedBy: self.endIndex) ?? self.startIndex
        let rawValue = self.substring(to: index)
        
        return IGCHeaderField.HeaderPrefix(rawValue: rawValue)
    }
    
    
}
