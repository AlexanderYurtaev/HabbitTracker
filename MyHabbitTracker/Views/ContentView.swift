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
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                ForEach(habits) { habit in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(habit.name)
                            .font(.headline)
                            .foregroundColor(habit.color)
                            .frame(maxWidth: .infinity, alignment: .leading) // убирает отступ справа
                            .contentShape(Rectangle()) // увеличивает область нажатия
                            .onTapGesture {
                                navigationPath.append(habit)
                            }

                        HabitWeekView(habit: habit)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Color(red: 0.96, green: 0.96, blue: 0.97))
                            .fill(Color(red: 0.94, green: 0.94, blue: 0.94))
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                .onDelete(perform: deleteHabits)
                .onMove(perform: moveHabit)
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
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
            .navigationDestination(for: Habit.self) { habit in
                HabitHistoryView(habit: habit)
            }
        }
    }

    // MARK: - Methods
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
