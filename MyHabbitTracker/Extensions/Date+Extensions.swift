//
//  Date+Extensions.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import Foundation

extension Date {
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    func endOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: 6, to: startOfWeek(using: calendar))!
    }
    
    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }
    
    func dayOfWeek(calendar: Calendar = .current) -> Int {
        let component = calendar.component(.weekday, from: self)
        // В календаре по умолчанию воскресенье = 1, понедельник = 2...
        // Приводим к индексу 0..6 (пн = 0, вс = 6)
        return (component + 5) % 7
    }
    
    static var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
}
