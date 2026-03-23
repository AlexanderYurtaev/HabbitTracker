//
//  ContentView.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.order) private var habits: [Habit]
    @State private var showingAddHabit = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(habits) { habit in
                    VStack(alignment: .leading, spacing: 8) {
                        NavigationLink(destination: HabitHistoryView(habit: habit)) {
                            Text(habit.name)
                                .font(.headline)
                                .foregroundColor(habit.color)
                        }
                        .buttonStyle(.plain)

                        HabitWeekView(habit: habit)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.96, green: 0.96, blue: 0.97))
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                .onDelete(perform: deleteHabits)
                .onMove(perform: moveHabit)
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)   // <-- добавлено
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Трекер привычек")
                        .font(.headline)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private func deleteHabits(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(habits[index])
        }
        updateOrders()
    }

    private func moveHabit(from source: IndexSet, to destination: Int) {
        var updatedHabits = habits
        updatedHabits.move(fromOffsets: source, toOffset: destination)

        for (index, habit) in updatedHabits.enumerated() {
            habit.order = index
        }

        do {
            try modelContext.save()
        } catch {
            print("Ошибка сохранения порядка: \(error)")
        }
    }

    private func updateOrders() {
        for (index, habit) in habits.enumerated() {
            habit.order = index
        }
        try? modelContext.save()
    }
}
