//
//  AddHabitView.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedTextColor: Color = .black
    @State private var selectedCardColor: Color = Color(red: 0.96, green: 0.96, blue: 0.97)
    
    // 10 спокойных мягких цветов для фона
    private let cardColors: [Color] = [
        Color(red: 0.91, green: 0.91, blue: 0.92), // мягкий серый
        Color(red: 0.86, green: 0.96, blue: 0.86), // мятный
        Color(red: 0.99, green: 0.93, blue: 0.86), // персиковый
        Color(red: 0.91, green: 0.88, blue: 0.99), // лавандовый
        Color(red: 0.84, green: 0.91, blue: 0.99), // небесно-голубой
        Color(red: 0.96, green: 0.89, blue: 0.96), // бледно-розовый
        Color(red: 0.89, green: 0.96, blue: 0.93), // бледно-бирюзовый
        Color(red: 0.97, green: 0.96, blue: 0.86), // кремовый
        Color(red: 0.87, green: 0.91, blue: 0.89), // светло-серо-зелёный
        Color(red: 0.96, green: 0.91, blue: 0.84)  // песочный
    ]
    
    private let textColors: [Color] = [
        .black, .blue, .green, .orange, .purple, .red, .teal
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Название") {
                    TextField("Название привычки", text: $name)
                        .accessibilityIdentifier("habitNameTextField")
                }
                
                Section("Цвет названия") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(textColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedTextColor == color ? Color.black : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedTextColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Цвет фона карточки") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(Array(cardColors.enumerated()), id: \.element) { index, color in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(color)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedCardColor == color ? Color.black : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedCardColor = color
                                    }
                                    .accessibilityIdentifier("cardColor_\(index)")
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Предпросмотр") {
                    HStack {
                        Text(name.isEmpty ? "Название привычки" : name)
                            .font(.headline)
                            .foregroundColor(selectedTextColor)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedCardColor)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                }
            }
            .navigationTitle("Новая привычка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        addHabit()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .accessibilityIdentifier("saveHabitButton")
                }
            }
        }
    }
    
    private func addHabit() {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.order, order: .reverse)])
        let existingHabits = try? modelContext.fetch(descriptor)
        let maxOrder = existingHabits?.first?.order ?? -1
        
        let habit = Habit(
            name: name,
            colorHex: selectedTextColor.toHex() ?? "#000000",
            cardColorHex: selectedCardColor.toHex() ?? "#F5F5F5",
            order: maxOrder + 1
        )
        modelContext.insert(habit)
        try? modelContext.save()
    }
}
