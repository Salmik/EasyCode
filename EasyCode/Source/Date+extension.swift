//
//  Date+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension Date {

    var calendar: Calendar { Calendar.current }

    enum Format {

        public enum Time {
            case full(separator: String = "'T'"), fullMilliseconds, fullTimeZone, fullMillisecondsTimeZone
        }

        case ddMMyyyy(separator: String, time: Time? = nil)
        case yyyyMMdd(separator: String, time: Time? = nil)
        case ddMMMMyyyy(separator: String, time: Time? = nil)
        case MMddyyyy(separator: String, time: Time? = nil)
        case dMMMM(separator: String, time: Time? = nil)
        case dMMMMyyyy(separator: String, time: Time? = nil)
        case yyMM(separator: String, time: Time? = nil)
        case MMyy(separator: String, time: Time? = nil)

        var string: String {
            var string: String
            switch self {
            case .ddMMyyyy(let seperator, let time):
                string = ["dd", "MM", "yyyy"].joined(separator: seperator)
                time.map { string += getString(for: $0) }
            case .yyyyMMdd(let separator, let time):
                string = ["yyyy", "MM", "dd"].joined(separator: separator)
                time.map { string += getString(for: $0) }
            case .ddMMMMyyyy(let separator, let time):
                string = ["dd", "MMMM", "yyyy"].joined(separator: separator)
                time.map { string += getString(for: $0) }
            case .MMddyyyy(let separator, let time):
                string = ["MM", "dd", "yyyy"].joined(separator: separator)
                time.map { string += getString(for: $0) }
            case .dMMMM(let separator, let time):
                string = ["d", "MMMM"].joined(separator: separator)
                time.map { string += getString(for: $0) }
            case .dMMMMyyyy(let separator, let time):
                string = ["d", "MMMM", "yyyy"].joined(separator: separator)
                time.map { string += getString(for: $0) }
            case .yyMM(let separator, let time):
                string = ["yy", "MM"].joined(separator: separator)
                time.map { string += getString(for: $0) }
            case .MMyy(let separator, let time):
                string = ["MM", "yy"].joined(separator: separator)
                time.map { string += getString(for: $0) }
            }

            return string
        }

        private func getString(for time: Format.Time) -> String {
            switch time {
            case .full(let separator): return separator + "HH:mm:ss"
            case .fullMilliseconds: return getString(for: .full()) + ".SSS"
            case .fullTimeZone: return getString(for: .full()) + "Z"
            case .fullMillisecondsTimeZone: return getString(for: .fullMilliseconds) + "Z"
            }
        }
    }

    func string(withFormat dateFormat: Date.Format, locale: Locale = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.string
        dateFormatter.locale = locale
        return dateFormatter.string(from: self)
    }

    func isEqual(to date: Date) -> Bool {
        return Calendar.current.startOfDay(for: self) == Calendar.current.startOfDay(for: date)
    }

    func changing(_ component: Calendar.Component, value: Int) -> Date? {
        switch component {
        case .nanosecond:
            guard let allowedRange = calendar.range(of: .nanosecond, in: .second, for: self),
                  allowedRange.contains(value) else {
                return nil
            }
            let currentNanoseconds = calendar.component(.nanosecond, from: self)
            let nanosecondsToAdd = value - currentNanoseconds
            return calendar.date(byAdding: .nanosecond, value: nanosecondsToAdd, to: self)
        case .second:
            guard let allowedRange = calendar.range(of: .second, in: .minute, for: self),
                  allowedRange.contains(value) else {
                return nil
            }
            let currentSeconds = calendar.component(.second, from: self)
            let secondsToAdd = value - currentSeconds
            return calendar.date(byAdding: .second, value: secondsToAdd, to: self)
        case .minute:
            guard let allowedRange = calendar.range(of: .minute, in: .hour, for: self),
                  allowedRange.contains(value) else {
                return nil
            }
            let currentMinutes = calendar.component(.minute, from: self)
            let minutesToAdd = value - currentMinutes
            return calendar.date(byAdding: .minute, value: minutesToAdd, to: self)
        case .hour:
            guard let allowedRange = calendar.range(of: .hour, in: .day, for: self),
                  allowedRange.contains(value) else {
                return nil
            }
            let currentHour = calendar.component(.hour, from: self)
            let hoursToAdd = value - currentHour
            return calendar.date(byAdding: .hour, value: hoursToAdd, to: self)
        case .day:
            guard let allowedRange = calendar.range(of: .day, in: .month, for: self),
                  allowedRange.contains(value) else {
                return nil
            }
            let currentDay = calendar.component(.day, from: self)
            let daysToAdd = value - currentDay
            return calendar.date(byAdding: .day, value: daysToAdd, to: self)
        case .month:
            guard let allowedRange = calendar.range(of: .month, in: .year, for: self),
                  allowedRange.contains(value) else {
                return nil
            }
            let currentMonth = calendar.component(.month, from: self)
            let monthsToAdd = value - currentMonth
            return calendar.date(byAdding: .month, value: monthsToAdd, to: self)
        case .year:
            guard value > 0 else { return nil }
            let currentYear = calendar.component(.year, from: self)
            let yearsToAdd = value - currentYear
            return calendar.date(byAdding: .year, value: yearsToAdd, to: self)
        default:
            return calendar.date(bySetting: component, value: value, of: self)
        }
    }
}
