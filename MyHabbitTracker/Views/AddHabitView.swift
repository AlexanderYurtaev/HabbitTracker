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
    @State private var selectedColor: Color = .black
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Название привычки", text: $name)
                
                ColorPicker("Цвет названия", selection: $selectedColor, supportsOpacity: false)
                    .padding(.vertical, 4)
            }
            .navigationTitle("Новая привычка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        addHabit()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addHabit() {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.order, order: .reverse)])
        let existingHabits = try? modelContext.fetch(descriptor)
        let maxOrder = existingHabits?.first?.order ?? -1
        
        let colorHex = selectedColor.toHex() ?? "#000000"
        let habit = Habit(name: name, colorHex: colorHex, order: maxOrder + 1)
        modelContext.insert(habit)
        try? modelContext.save()
    }
}
