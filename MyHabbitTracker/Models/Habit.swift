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
    var colorHex: String        // цвет текста
    var cardColorHex: String    // цвет фона карточки
    var createdAt: Date
    var order: Int
    
    @Relationship(deleteRule: .cascade) var completions: [Completion] = []
    
    init(name: String, colorHex: String = "#000000", cardColorHex: String = "#F5F5F5", order: Int = 0) {
        self.name = name
        self.colorHex = colorHex
        self.cardColorHex = cardColorHex
        self.createdAt = Date()
        self.order = order
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .black
    }
    
    var cardColor: Color {
        Color(hex: cardColorHex) ?? Color(red: 0.96, green: 0.96, blue: 0.97)
    }
}

// MARK: - Экспорт/импорт
extension Habit {
    struct ExportData: Codable {
        var name: String
        var colorHex: String
        var cardColorHex: String
        var order: Int
        var completions: [Date]
    }
    
    func toExportData() -> ExportData {
        ExportData(
            name: self.name,
            colorHex: self.colorHex,
            cardColorHex: self.cardColorHex,
            order: self.order,
            completions: self.completions.map { $0.date }
        )
    }
    
    static func fromExportData(_ data: ExportData, context: ModelContext) -> Habit {
        let habit = Habit(name: data.name, colorHex: data.colorHex, cardColorHex: data.cardColorHex, order: data.order)
        for date in data.completions {
            let completion = Completion(date: date, habit: habit)
            context.insert(completion)
        }
        return habit
    }
}
