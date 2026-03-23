//
//  HabitHistoryView.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI
import SwiftData

struct HabitHistoryView: View {
    let habit: Habit
    @State private var currentMonth = Date()
    
    var body: some View {
        VStack {
            // Заголовок с переключением месяцев
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.medium)
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Календарь
            CalendarView(habit: habit, month: currentMonth)
            
            Spacer()
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
}

struct CalendarView: View {
    let habit: Habit
    let month: Date
    @Environment(\.modelContext) private var modelContext
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    var body: some View {
        let days = generateDaysForMonth()
        
        VStack {
            // Дни недели
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Дни месяца
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        let isCompleted = habit.completions.contains { $0.date.isSameDay(as: date) }
                        let isToday = date.isSameDay(as: Date.today)
                        let isFuture = date > Date.today
                        DayCell(
                            date: date,
                            isCompleted: isCompleted,
                            isToday: isToday,
                            isFuture: isFuture,
                            onTap: {
                                toggleCompletion(for: date)
                            }
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func generateDaysForMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let startOfMonth = monthInterval.start
        let endOfMonth = monthInterval.end
        
        // Определяем первый день, который нужно показать (понедельник перед началом месяца)
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfMonth))!
        
        var dates: [Date?] = []
        var currentDate = startOfWeek
        
        while currentDate < endOfMonth {
            if currentDate < startOfMonth {
                dates.append(nil) // пустая ячейка
            } else {
                dates.append(currentDate)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
    
    private func toggleCompletion(for date: Date) {
        // Не позволяем отмечать будущие дни
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
            print("Ошибка сохранения в календаре: \(error)")
        }
    }
}

struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    let isFuture: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            if !isFuture {
                onTap()
            }
        }) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.body)
                .foregroundColor(isToday ? .blue : .primary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isCompleted ? Color.green.opacity(0.3) : Color.clear)
                )
                .overlay(
                    Circle()
                        .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
        .opacity(isFuture ? 0.5 : 1.0)
    }
}
