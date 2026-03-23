//
//  Habit.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI
import SwiftData

@Model
final class Habit {
    var name: String
    var colorHex: String
    var createdAt: Date
    var order: Int
    
    @Relationship(deleteRule: .cascade) var completions: [Completion] = []
    
    init(name: String, colorHex: String = "#000000", order: Int = 0) {
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
        self.order = order
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .black
    }
}

// MARK: - Экспорт/импорт
extension Habit {
    struct ExportData: Codable {
        var name: String
        var colorHex: String
        var order: Int
        var completions: [Date]  // даты выполнения
    }
    
    func toExportData() -> ExportData {
        ExportData(
            name: self.name,
            colorHex: self.colorHex,
            order: self.order,
            completions: self.completions.map { $0.date }
        )
    }
    
    static func fromExportData(_ data: ExportData, context: ModelContext) -> Habit {
        let habit = Habit(name: data.name, colorHex: data.colorHex, order: data.order)
        for date in data.completions {
            let completion = Completion(date: date, habit: habit)
            context.insert(completion)
        }
        return habit
    }
}
