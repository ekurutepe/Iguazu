//
//  Date+Midnight.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 18/08/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

extension Date {
    
    /// Last midnight preceeding the receiver
    var midnightInUTC: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.timeZone = TimeZone(abbreviation: "UTC")
        return calendar.date(from: components)!
    }
    
    // parse strings like 250809 to Aug 25th 2009
    static func parse(headerDateString: String) -> Date? {
        guard headerDateString.characters.count == 6 else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: headerDateString)
        
        return date
    }
    
    static func parse(fixTimeString: String, on midnight: Date) -> Date? {
        precondition(fixTimeString.utf8.count == 6)
        
        guard let hours = Int(fixTimeString.extractString(from: 0, length: 2)!),
            let minutes = Int(fixTimeString.extractString(from: 2, length: 2)!),
            let seconds = Int(fixTimeString.extractString(from: 4, length: 2)!) else { return nil }
        
        let calendar = Calendar.current
        let components = DateComponents(calendar: calendar,
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
        
        return calendar.date(byAdding: components, to: midnight)
    }
    
    public var igcFixTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: self)
    }
    
    public var igcHeaderDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: self)
    }
    
}
