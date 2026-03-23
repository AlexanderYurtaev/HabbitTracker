//
//  SettingsView.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Здесь будут настройки")
                .font(.body)
                .foregroundColor(.secondary)
                .navigationTitle("Настройки")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Готово") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
