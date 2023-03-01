//
//  Settings.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 17.02.21.
//

import Foundation
import CoreLocation

class AppSettings {
    struct Settings: Encodable, Decodable {
        enum distanceEnum: Int, Encodable, Decodable {
            case kilometers = 0
            case miles = 1
        }
        
        enum thermalEnum: Int, Encodable, Decodable {
            case fahrenheit = 1
            case celsius = 0
        }
        enum gpsEnum: Int, Encodable, Decodable {
            case best = 0
            case tenMeters = 1
            case hundretMeters = 2
            case kilometers = 3
        }
        
        var useDemo = false
        var backgroundUpdating = false
        var LiontronHidden: Bool? = false
        var distanceUnit: distanceEnum = .kilometers
        var thermalUnit: thermalEnum = .celsius
        var gpsUnit: gpsEnum = .best
        var gpsAccuracy: CLLocationAccuracy {
            get {
                switch gpsUnit {
                case .best:
                    return kCLLocationAccuracyBest
                case .tenMeters:
                    return kCLLocationAccuracyNearestTenMeters
                case .hundretMeters:
                    return kCLLocationAccuracyHundredMeters
                case .kilometers:
                    return kCLLocationAccuracyKilometer
                }
            }
            set {
                switch newValue {
                case kCLLocationAccuracyBest:
                    gpsUnit = .best
                    break
                case kCLLocationAccuracyNearestTenMeters:
                    gpsUnit = .tenMeters
                    break
                case kCLLocationAccuracyHundredMeters:
                    gpsUnit = .hundretMeters
                    break
                case kCLLocationAccuracyKilometer:
                    gpsUnit = .kilometers
                    break
                default:
                    gpsUnit = .best
                    break
                }
            }
        }
        
        var refreshTime: Int = 1000
    }
}
