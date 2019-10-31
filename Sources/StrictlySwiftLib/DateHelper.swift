//
//  DateHelper.swift
//  StrictlySwift
//
//  Created by strictlyswift on 19-May-19.
//

import Foundation

public extension Date {
    /// Returns a date in the current calendar with the given year, month and day.
    ///
    /// - Note: The time will default to midnight of the current timezone. To set to midnight UTC, pass `isUTC: true`.
    init?(year: Int, month: Int, day: Int, isUTC: Bool = false) {
        let dateComponents = DateComponents(timeZone: (isUTC ? TimeZone(secondsFromGMT: 0) : nil), year: year, month: month, day: day)
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
        self.init(timeInterval: 0, since: date)
    }
    
    /// Initialize a date from the given string in ISO8601 format.
    ///
    /// - Note: macOS >= 10.12,  iOS >= 10.0, watchOS >= 2.0, tvOS >= 10.0
    init?(isoString string: String) {
        if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            guard let date = ISO8601DateFormatter().date(from: string) else { return nil }
            self.init(timeInterval: 0, since: date)
        } else {
            fatalError("ISO8601 is unavailable on this platform")
        }
    }
    
    /// Returns date in ISO8601 format.
    ///
    /// - Note: macOS >= 10.12,  iOS >= 10.0, watchOS >= 2.0, tvOS >= 10.0
    func isoFormat() -> String {
        if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            return ISO8601DateFormatter().string(from: self)
        } else {
            fatalError("ISO8601 is unavailable on this platform")
        }
    }
    
    func to_yyyyMMdd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        return dateFormatter.string(from: self)
    }
    
}
