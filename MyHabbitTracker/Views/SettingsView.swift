//
//  SettingsView.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var habits: [Habit]
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var exportData: Data?
    @State private var importAlertMessage: String?
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Данные") {
                    Button(action: exportHabits) {
                        HStack {
                            Text("Экспорт привычек")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    
                    Button(action: { showingImporter = true }) {
                        HStack {
                            Text("Импорт привычек")
                            Spacer()
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                }
                
                Section("Информация") {
                    Text("Версия 1.0")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .fileExporter(
                isPresented: $showingExporter,
                document: HabitDocument(data: exportData ?? Data()),
                contentType: .json,
                defaultFilename: "habits_backup.json"
            ) { result in
                switch result {
                case .success:
                    importAlertMessage = "Экспорт выполнен"
                    showingAlert = true
                case .failure(let error):
                    importAlertMessage = "Ошибка экспорта: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    importHabits(from: url)
                case .failure(let error):
                    importAlertMessage = "Ошибка импорта: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
            .alert("Импорт / Экспорт", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importAlertMessage ?? "")
            }
        }
    }
    
    private func exportHabits() {
        let exportArray = habits.map { $0.toExportData() }
        do {
            let data = try JSONEncoder().encode(exportArray)
            exportData = data
            showingExporter = true
        } catch {
            importAlertMessage = "Не удалось подготовить данные: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func importHabits(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            importAlertMessage = "Нет доступа к файлу"
            showingAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Habit.ExportData].self, from: data)
            
            // Удаляем текущие привычки
            for habit in habits {
                modelContext.delete(habit)
            }
            
            // Создаём новые
            for item in decoded {
                _ = Habit.fromExportData(item, context: modelContext)
            }
            
            try modelContext.save()
            importAlertMessage = "Импорт выполнен. Перезапустите приложение."
            showingAlert = true
        } catch {
            importAlertMessage = "Ошибка импорта: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// Документ для экспорта
struct HabitDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.data = data
        } else {
            self.data = Data()
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
