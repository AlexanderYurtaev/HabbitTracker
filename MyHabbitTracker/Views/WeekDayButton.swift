//
//  WeekDayButton.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI

struct WeekDayButton: View {
    let date: Date
    let isCompleted: Bool
    let onToggle: () -> Void
    let isFuture: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"       // короткое название дня недели (две буквы)
        formatter.locale = Locale(identifier: "ru_RU")  // русская локаль
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: {
            if !isFuture {
                onToggle()
            }
        }) {
            VStack(spacing: 2) {
                Text(dayLetter)
                    .font(.caption)
                    .foregroundColor(isFuture ? .gray : .primary)
                Text(dayNumber)
                    .font(.caption2)
                    .foregroundColor(isFuture ? .gray : .primary)
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 32)
            }
            .opacity(isFuture ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }
}
