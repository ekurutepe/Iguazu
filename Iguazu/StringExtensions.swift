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
    func extractString(from start:Int, length: Int) -> String? {
        guard start+length <= self.utf8.count else { return nil }
        guard start >= 0 else { return nil }
        
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
    func extractTime(from start:Int) -> DateComponents? {
        let length = 6
        guard start+length <= self.utf8.count else { return nil }
        guard start >= 0 else { return nil }
        
        guard let hours = Int(self.extractString(from: start, length: 2)!) else { return nil }
        guard let minutes = Int(self.extractString(from: start+2, length: 2)!) else { return nil }
        guard let seconds = Int(self.extractString(from: start+4, length: 2)!) else { return nil }
        
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
    
    // parse strings like 250809 to Aug 25th 2009
    func headerDate() -> Date? {
        guard self.characters.count == 6 else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyy"
        dateFormatter.timeZone = TimeZone(forSecondsFromGMT: 0)
        guard let date = dateFormatter.date(from: self) else { return nil }
        
        return date
    }
    
    func igcHeaderPrefix() -> IGCHeaderField.HeaderPrefix? {
        let index = self.index(self.startIndex, offsetBy: 5, limitedBy: self.endIndex) ?? self.startIndex
        let rawValue = self.substring(to: index)
        
        return IGCHeaderField.HeaderPrefix(rawValue: rawValue)
    }
}
