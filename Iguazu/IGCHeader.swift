//
//  IGCHeader.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 12/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

extension String {
    // parse strings like 250809 to Aug 25th 2009
    func headerDate() -> Date? {
        guard self.characters.count == 6 else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyy"
        dateFormatter.timeZone = TimeZone(forSecondsFromGMT: 0)
        guard let date = dateFormatter.date(from: self) else { return nil }
        
        return date
    }
    
    func igcHeaderPrefix() -> IGCHeaderField.HeaderPrefix {
        let rawValue = self.substring(to: self.index(self.startIndex, offsetBy: 5, limitedBy: self.endIndex)!)
        
        return IGCHeaderField.HeaderPrefix(rawValue: rawValue)!
    }
}

/// <#Description#>
///
/// - date:               <#date description#>
/// - accuracy:           <#accuracy description#>
/// - pilotInCharge:      <#pilotInCharge description#>
/// - crew:               <#crew description#>
/// - gliderType:         <#gliderType description#>
/// - gliderRegistration: <#gliderRegistration description#>
/// - gpsDatum:           <#gpsDatum description#>
/// - firmwareVersion:    <#firmwareVersion description#>
/// - hardwareVersion:    <#hardwareVersion description#>
/// - loggerType:         <#loggerType description#>
/// - gpsType:            <#gpsType description#>
/// - altimeterType:      <#altimeterType description#>
/// - competitionID:      <#competitionID description#>
/// - competitionClass:   <#competitionClass description#>
enum IGCHeaderField {

    enum HeaderPrefix: String {
        case date = "HFDTE"
        case accuracy = "HFFXA"
        case pilot = "HFPLT"
        case crew = "HFCM2"
        case gliderType = "HFGTY"
    }
    
    // UTC date this file was recorded
    case date(date: Foundation.Date)
    // Fix accuracy in meters, see also FXA three-letter-code reference
    case accuracy(accuracy: Int)
    // Name of the competing pilot
    case pilotInCharge(name: String)
    // Name of the second pilot in a two-seater
    case crew(name: String)
    // Free-text name of the glider model
    case gliderType(gliderType: String)
    // Glider registration number, e.g. N-number
    case gliderRegistration(registration: String)
    // GPS datum used for the log points - use igc code 100 / WGS84 unless you are insane.
    case gpsDatum(datum: String)
    // Any free-text string descibing the firmware revision of the logger
    case firmwareVersion(version: String)
    // Any free-text string giving the hardware revision number of the logger
    case hardwareVersion(version: String)
    // Logger free-text manufacturer and model
    case loggerType(brand: String, model: String)
    // Manufacturer and model of the GPS receiver used in the logger.
    case gpsType(brand: String, model: String, channels: Int, maximumAltitude: Int)
    // Free-text (separated by commas) description of the pressure sensor used in the logger
    case altimeterType(brand: String, model: String, maximumAltitude: Int)
    // The fin-number by which the glider is generally recognised
    case competitionID(competitionID: String)
    // Any free-text description of the class this glider is in, e.g. Standard, 15m, 18m, Open.
    case competitionClass(competitionClass: String)
    
    static func parseHLine(hLine: String) -> IGCHeaderField? {
        let prefix = hLine.igcHeaderPrefix()
        switch prefix {
        case .date:
            return parseDateString(hLine: hLine)
        case .accuracy:
            return parseAccuracyString(hLine: hLine)
        case .pilot:
            return parsePilotInChargeLine(hLine: hLine)
        case .crew:
            return parseCrewLine(hLine: hLine)
        case .gliderType:
            return parseGliderTypeLine(hLine: hLine)
//        case "HFGID":
//            return IGCHeaderField.date(date: Date())
//        case "HFDTM":
//            return IGCHeaderField.date(date: Date())
//        case "HFRFW":
//            return IGCHeaderField.date(date: Date())
//        case "HFRHW":
//            return IGCHeaderField.date(date: Date())
//        case "HFFTY":
//            return IGCHeaderField.date(date: Date())
//        case "HFGPS":
//            return IGCHeaderField.date(date: Date())
//        case "HFPRS":
//            return IGCHeaderField.date(date: Date())
//        case "HFCID":
//            return IGCHeaderField.date(date: Date())
//        case "HFCCL":
//            return IGCHeaderField.date(date: Date())
        default:
            return nil
        }
    }
    
    static func parseDateString(hLine: String) -> IGCHeaderField? {
        guard let prefixRange = hLine.range(of:HeaderPrefix.date.rawValue) else { return nil }
        
        let dateString = hLine.substring(from: prefixRange.upperBound)
        
        guard let date = dateString.headerDate() else { return nil }
        
        return .date(date: date)
    }
    
    static func parseAccuracyString(hLine: String) -> IGCHeaderField? {
        guard let prefixRange = hLine.range(of:HeaderPrefix.accuracy.rawValue) else { return nil }
        
        let accuracyString = hLine.substring(from: prefixRange.upperBound)
        
        guard let accuracy = Int(accuracyString) else { return nil }
        
        return .accuracy(accuracy: accuracy)
    }
    
    static func parsePilotInChargeLine(hLine: String) -> IGCHeaderField? {
        guard let name = parseFreeTextLine(line: hLine, prefix: HeaderPrefix.pilot.rawValue) else { return nil }
        
        return .pilotInCharge(name: name)
    }
    
    static func parseCrewLine(hLine: String) -> IGCHeaderField? {
        guard let name = parseFreeTextLine(line: hLine, prefix: HeaderPrefix.crew.rawValue) else { return nil }
        
        return .crew(name: name)
    }
    
    static func parseGliderTypeLine(hLine: String) -> IGCHeaderField? {
        guard let name = parseFreeTextLine(line: hLine, prefix: HeaderPrefix.gliderType.rawValue) else { return nil }
        
        return .gliderType(gliderType: name)
    }
    
    static func parseFreeTextLine(line: String, prefix: String) -> String? {
        guard let _ = line.range(of:prefix) else { return nil }
        
        guard let separatorRange = line.range(of: ":") else { return nil }
        
        let value = line.substring(from: separatorRange.upperBound)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return value
    }
}


/// <#Description#>
struct IGCHeader {

    /// <#Description#>
    let headerFields: [ IGCHeaderField ]
    
    init?(igcString: String) {
        let lines = igcString.components(separatedBy: .newlines)
            .filter({ (line) -> Bool in
                return line.hasPrefix("H")
            })

        let hf = lines.flatMap { IGCHeaderField.parseHLine(hLine: $0)}
        
        headerFields = hf
        
        return nil
    }
}
