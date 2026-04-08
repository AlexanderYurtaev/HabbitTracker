//
//  EditHabitView.swift
//  MyHabbitTracker
//
//  Created by Alex on 08.04.2026.
//

import SwiftUI
import SwiftData

struct EditHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var habit: Habit
    
    @State private var name: String
    @State private var selectedTextColor: Color
    @State private var selectedCardColor: Color
    
    private let cardColors: [Color] = [
        Color(red: 0.96, green: 0.96, blue: 0.97),
        Color(red: 0.93, green: 0.98, blue: 0.93),
        Color(red: 1.00, green: 0.96, blue: 0.92),
        Color(red: 0.95, green: 0.93, blue: 1.00),
        Color(red: 0.90, green: 0.95, blue: 1.00),
        Color(red: 0.98, green: 0.94, blue: 0.98),
        Color(red: 0.94, green: 0.98, blue: 0.96),
        Color(red: 0.98, green: 0.98, blue: 0.90),
        Color(red: 0.92, green: 0.95, blue: 0.94),
        Color(red: 0.97, green: 0.94, blue: 0.90)
    ]
    
    private let textColors: [Color] = [
        .black, .blue, .green, .orange, .purple, .red, .teal
    ]
    
    init(habit: Habit) {
        self.habit = habit
        _name = State(initialValue: habit.name)
        _selectedTextColor = State(initialValue: Color(hex: habit.colorHex) ?? .black)
        _selectedCardColor = State(initialValue: Color(hex: habit.cardColorHex) ?? Color(red: 0.96, green: 0.96, blue: 0.97))
    }
    
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
                            ForEach(cardColors, id: \.self) { color in
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
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .accessibilityIdentifier("saveEditedHabitButton")
                }
            }
        }
    }
    
    private func saveChanges() {
        habit.name = name
        habit.colorHex = selectedTextColor.toHex() ?? "#000000"
        habit.cardColorHex = selectedCardColor.toHex() ?? "#F5F5F5"
        try? modelContext.save()
    }
}
