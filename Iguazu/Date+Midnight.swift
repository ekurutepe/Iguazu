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
    var midnight: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)!
    }
}
