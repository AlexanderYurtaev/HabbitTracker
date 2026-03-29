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
    
    @State private var scale: CGFloat = 1.0
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: {
            if !isFuture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 0.9
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        scale = 1
                    }
                }
                onToggle()
            }
        }) {
            VStack(spacing: 4) {
                Text(dayLetter)
                    .font(.caption)
                    .foregroundColor(isFuture ? .gray : .secondary)
                Text(dayNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isFuture ? .gray : .primary)
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.1))
                        .frame(width: 32, height: 32)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
            .scaleEffect(scale)
            .opacity(isFuture ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }
}
