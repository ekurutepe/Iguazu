//
//  IGCHeader.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 12/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

/// Representation of the Header field types as listed in
/// http://carrier.csi.cam.ac.uk/forsterlewis/soaring/igc_file_format/igc_format_2008.html#link_3.3
///
/// - date:               flight date
/// - accuracy:           typical accuracy the logger is capable of
/// - pilotInCharge:      name of PIC
/// - crew:               name of crew
/// - gliderType:         free-text glider make/model
/// - gliderRegistration: official registration of the glider
/// - gpsDatum:           GPS datum used for the fixes
/// - firmwareVersion:    free-text firmware version of the logger (not implemeneted)
/// - hardwareVersion:    free-text hardware version of the logger (not implemeneted)
/// - loggerType:         logger make/model  (not implemeneted)
/// - gpsType:            gps make/model etc  (not implemeneted)
/// - altimeterType:      altimeter make/model etc  (not implemeneted)
/// - competitionID:      competition callsign of the glider
/// - competitionClass:   competition class of the glider
public enum IGCHeaderField {

    enum HeaderRecordCode: String {
        case date = "DTE"
        case accuracy = "FXA"
        case pilot = "PLT"
        case crew = "CM2"
        case gliderType = "GTY"
        case gliderRegistration = "GID"
        case gpsDatum = "DTM"
        case firmwareVersion = "RFW"
        case hardwareVersion = "RHW"
        case loggerType = "FTY"
        case gpsType = "GPS"
        case altimeterType = "PRS"
        case competitionID = "CID"
        case competitionClass = "CCL"
    }

    // UTC date this file was recorded
    case date(flightDate: Date)
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
    case gpsDatum(code: Int, datum: String)
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
    case competitionID(id: String)
    // Any free-text description of the class this glider is in, e.g. Standard, 15m, 18m, Open.
    case competitionClass(competitionClass: String)

    static func parseHLine(hLine: String) -> IGCHeaderField {
        guard let prefix = hLine.igcHeaderPrefix() else { fatalError("unknown header type: \(hLine)") }
        switch prefix {
        case .date:
            return parseDateString(hLine: hLine)
        case .accuracy:
            return parseAccuracyString(hLine: hLine)
        case .pilot:
            let name = parseFreeTextLine(line: hLine, prefix: HeaderRecordCode.pilot.rawValue)
            return .pilotInCharge(name: name)
        case .crew:
            let name = parseFreeTextLine(line: hLine, prefix: HeaderRecordCode.crew.rawValue)
            return .crew(name: name)
        case .gliderType:
            let name = parseFreeTextLine(line: hLine, prefix: HeaderRecordCode.gliderType.rawValue)
            return .gliderType(gliderType: name)
        case .gliderRegistration:
            let value = parseFreeTextLine(line: hLine, prefix: HeaderRecordCode.gliderRegistration.rawValue)
            return .gliderRegistration(registration: value)
        case .gpsDatum:
            // Punt on parsing this header. Assume it's standard.
            return .gpsDatum(code: 100, datum: "WGS-1984")
        case .firmwareVersion:
            return .firmwareVersion(version: "0.0.0")
        case .hardwareVersion:
            return .hardwareVersion(version: "0.0.0")
        case .loggerType:
            return .loggerType(brand: "Unknown Brand", model: "Unknown Model")
        case .gpsType:
            return .gpsType(brand: "Unknown Brand", model: "Unknown Model", channels: 0, maximumAltitude: 0)
        case .altimeterType:
            return .altimeterType(brand: "Unknown Brand", model: "Unknown Model", maximumAltitude: 0)
        case .competitionID:
            let value = parseFreeTextLine(line: hLine, prefix: HeaderRecordCode.competitionID.rawValue)
            return .competitionID(id: value)
        case .competitionClass:
            let value = parseFreeTextLine(line: hLine, prefix: HeaderRecordCode.competitionClass.rawValue)
            return .competitionClass(competitionClass: value)
        }
    }

    static func parseDateString(hLine: String) -> IGCHeaderField {
        guard let prefixRange = hLine.range(of: HeaderRecordCode.date.rawValue) else { fatalError() }

        let dateString = hLine.substring(from: prefixRange.upperBound)

        guard let date = dateString.headerDate() else { fatalError() }

        return .date(flightDate: date)
    }

    static func parseAccuracyString(hLine: String) -> IGCHeaderField {
        guard let prefixRange = hLine.range(of: HeaderRecordCode.accuracy.rawValue) else { fatalError() }

        let accuracyString = hLine.substring(from: prefixRange.upperBound)

        guard let accuracy = Int(accuracyString) else { fatalError() }

        return .accuracy(accuracy: accuracy)
    }

    static func parseFreeTextLine(line: String, prefix: String) -> String {
        guard let _ = line.range(of: prefix),
            let separatorRange = line.range(of: ":") else { fatalError() }

        let value = line.substring(from: separatorRange.upperBound)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return value
    }
}

/// Represents the header section contained in an IGC file
public struct IGCHeader {

    /// header fields in this section
    public let headerFields: [IGCHeaderField]

    init?(igcString: String) {
        let lines = igcString.components(separatedBy: .newlines)
            .filter({ (line) -> Bool in
            return line.hasPrefix("H")
        })

        headerFields = lines.flatMap { IGCHeaderField.parseHLine(hLine: $0) }
    }

    public lazy var flightDate: Date = {
        let midnight = self.headerFields.flatMap({ (header) -> Date? in
            switch header {
            case .date(let flightDate):
                return flightDate
            default:
                return nil
            }
        }).map { (date) -> Date in
            return date.midnight
        }.first!

        return midnight
    }()

    public lazy var pilotInCharge: String = {
        let pic = self.headerFields.flatMap({ (header) -> String? in
            switch header {
            case .pilotInCharge(let name):
                return name
            default:
                return nil
            }
        }).first!

        return pic
    }()
    
    public lazy var crew: String? = {
        let crew = self.headerFields.flatMap({ (header) -> String? in
            switch header {
            case .crew(let name):
                return name
            default:
                return nil
            }
        }).first
        
        return crew
    }()

    public lazy var gliderType: String = {
        let gliderType = self.headerFields.flatMap({ (header) -> String? in
            switch header {
            case .gliderType(let value):
                return value
            default:
                return nil
            }
        }).first!
        
        return gliderType
    }()

    public lazy var gliderRegistration: String = {
        let gliderRegistration = self.headerFields.flatMap({ (header) -> String? in
            switch header {
            case .gliderRegistration(let value):
                return value
            default:
                return nil
            }
        }).first!
        
        return gliderRegistration
    }()


}
