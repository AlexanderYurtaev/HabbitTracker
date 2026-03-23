//
//  HabitWeekView.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI
import SwiftData

struct HabitWeekView: View {
    let habit: Habit
    @Environment(\.modelContext) private var modelContext
    @State private var weekDays: [Date] = []
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(weekDays, id: \.self) { date in
                let isCompleted = habit.completions.contains { $0.date.isSameDay(as: date) }
                let isFuture = date > Date.today
                WeekDayButton(
                    date: date,
                    isCompleted: isCompleted,
                    onToggle: {
                        toggleCompletion(for: date)
                    },
                    isFuture: isFuture
                )
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            updateWeekDays()
        }
    }
    
    private func updateWeekDays() {
        let calendar = Calendar.current
        let today = Date.today
        // Показываем 7 дней: от 6 дней назад до сегодня, в хронологическом порядке
        weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }
    }
    
    private func toggleCompletion(for date: Date) {
        guard date <= Date.today else { return }
        
        if let existing = habit.completions.first(where: { $0.date.isSameDay(as: date) }) {
            modelContext.delete(existing)
        } else {
            let completion = Completion(date: date, habit: habit)
            modelContext.insert(completion)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
}
