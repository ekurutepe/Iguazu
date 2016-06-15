//
//  IGCHeader.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 12/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation


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
    // UTC date this file was recorded
    case date(date: Foundation.Date)
    // Fix accuracy in meters, see also FXA three-letter-code reference
    case accuracy(accuracy: Int)
    // Name of the competing pilot
    case pilotInCharge(pilotName: String)
    // Name of the second pilot in a two-seater
    case crew(crewName: String)
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
    
    static func headerField(hLine: String) -> IGCHeaderField? {
        return nil
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
        
        let hf = lines.map { (line) -> IGCHeaderField? in
                return IGCHeaderField.headerField(hLine: line)
            }
            .filter { (headerField) -> Bool in
                return headerField != nil
            }
            .map { (maybeHeaderField) -> IGCHeaderField in
                return maybeHeaderField as IGCHeaderField!
            }
        
        headerFields = hf
        
        return nil
    }
}
