//
//  ISO8601DurationParser.swift
//  FOXNOW
//
//  Created by Kevin Chen on 8/7/18.
//

import Foundation


struct ISO8601DurationParser {
    
    enum PeriodUnit {
        case day
        case week
        case month
        case year
        case hour
        /// Minute is forced as 'Z' just for parsing
        case minute
        case second
        
        init?(char: Character) {
            switch char {
            case "D":
                self = .day
            case "W":
                self = .week
            case "M":
                self = .month
            case "Y":
                self = .year
            case "H":
                self = .hour
            case "Z":
                self = .minute
            case "S":
                self = .second
            default:
                return nil
            }
        }
    }

    
    /**
     Parser for duration based on ISO 8601. For example, "P3Y6M4DT12H30M5S" represents a duration of "three years, six months, four days, twelve hours, thirty minutes, and five seconds". Decimal fraction may be specified with either a comma or a full stop, e.g. "P0,5Y" or "P0.5Y".
     */
    static func parse(_ string: String) -> [PeriodUnit: Double]? {
        guard string.first == "P" else {
            return nil
        }
        
        var modString = String(string.dropFirst())
        
        // Seperate minute from month
        if modString.contains("T") {
            var splitString = modString.components(separatedBy: "T")
            if splitString.indices.contains(1), !splitString.isEmpty {
                splitString[1] = splitString[1].replacingOccurrences(of: "M", with: "Z")
                modString = splitString.joined()
            }
        }
        
        var numberString = ""
        let dictionary = modString.reduce(into: [PeriodUnit: Double]()) { (result, character) in
            let stringCharacter = String(character)
            
            // add a character or decimal pt to string
            if stringCharacter == "." || stringCharacter == "," || Int(stringCharacter) != nil {
                var characterToAdd = stringCharacter
                if stringCharacter == "," {
                    characterToAdd = "."
                }
                
                numberString.append(characterToAdd)
            }
            
            if let period = PeriodUnit(char: character) {
                result[period] = Double(numberString)
                
                numberString = ""
            }
        }
        
        return dictionary.isEmpty ? nil : dictionary
    }
}
