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
    @State private var selectedRange: MonthRange = .last1
    @State private var currentMonth = Date()
    @State private var currentYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showingEditSheet = false
    
    enum MonthRange: Int, CaseIterable {
        case last1 = 1
        case last3 = 3
        case last6 = 6
        case last12 = 12
        
        var title: String {
            switch self {
            case .last1: return "1 месяц"
            case .last3: return "3 месяца"
            case .last6: return "6 месяцев"
            case .last12: return "12 месяцев"
            }
        }
    }
    // для 3 и 6 месяцев
    private var recentMonthsForGrid: [Date] {
        let calendar = Calendar.current
        let today = Date()
        var months: [Date] = []
        for i in 0..<selectedRange.rawValue {
            if let date = calendar.date(byAdding: .month, value: -i, to: today) {
                months.append(date)
            }
        }
        // Сортируем от старого к новому (возрастание)
        return months.sorted(by: <)
    }
    
    // Для 12 месяцев – все месяцы выбранного года
    private var monthsInYear: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        for month in 1...12 {
            var components = DateComponents()
            components.year = currentYear
            components.month = month
            if let date = calendar.date(from: components) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private var minAllowedYear: Int {
        Calendar.current.component(.year, from: Date()) - 5 // на 5 лет назад
    }
    
    private var maxAllowedYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
//    var body: some View {
//        VStack(spacing: 0) {
//            Picker("Период", selection: $selectedRange) {
//                ForEach(MonthRange.allCases, id: \.self) { range in
//                    Text(range.title).tag(range)
//                }
//            }
//            .pickerStyle(.segmented)
//            .padding(.horizontal)
//            .padding(.bottom, 8)
//            .onChange(of: selectedRange) { _, newValue in
//                if newValue == .last1 {
//                    currentMonth = Date()
//                }
//            }
//            
//            if selectedRange == .last1 {
//                singleMonthView
//            } else if selectedRange == .last12 {
//                twelveMonthsView
//            } else {
//                multipleMonthsGridView(months: recentMonthsForGrid)
//            }
//        }
//        .navigationTitle(habit.name)
//        .navigationBarTitleDisplayMode(.inline)
//    }
    var body: some View {
        VStack(spacing: 0) {
            Picker("Период", selection: $selectedRange) {
                ForEach(MonthRange.allCases, id: \.self) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .onChange(of: selectedRange) { _, newValue in
                if newValue == .last1 {
                    currentMonth = Date()
                }
            }
            
            if selectedRange == .last1 {
                singleMonthView
            } else if selectedRange == .last12 {
                twelveMonthsView
            } else {
                multipleMonthsGridView(months: recentMonthsForGrid)
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if selectedRange == .last1 {
                    Button(action: { showingEditSheet = true }) {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditHabitView(habit: habit)
        }
    }
    
    // MARK: - Single Month View (1 месяц, навигация по месяцам)
    private var singleMonthView: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                .disabled(currentMonth <= minAllowedDateForSingle)
                
                Spacer()
                Text(monthYearString(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.medium)
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
                .disabled(currentMonth >= Date())
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            CalendarView(habit: habit, month: currentMonth, mode: .normal)
                .padding(.top, 8)
            
            Spacer()
        }
    }
    
    private var minAllowedDateForSingle: Date {
        Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
    }
    
    private func previousMonth() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth),
              newDate >= minAllowedDateForSingle else { return }
        currentMonth = newDate
    }
    
    private func nextMonth() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth),
              newDate <= Date() else { return }
        currentMonth = newDate
    }
    
    // MARK: - 12 Months View (с навигацией по годам)
    private var twelveMonthsView: some View {
        VStack {
            HStack {
                Button(action: previousYear) {
                    Image(systemName: "chevron.left")
                }
                .disabled(currentYear <= minAllowedYear)
                
                Spacer()
                Text(String(currentYear))
                    .font(.title2)
                    .fontWeight(.medium)
                Spacer()
                
                Button(action: nextYear) {
                    Image(systemName: "chevron.right")
                }
                .disabled(currentYear >= maxAllowedYear)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            multipleMonthsGridView(months: monthsInYear)
        }
    }
    
    private func previousYear() {
        guard currentYear - 1 >= minAllowedYear else { return }
        currentYear -= 1
    }
    
    private func nextYear() {
        guard currentYear + 1 <= maxAllowedYear else { return }
        currentYear += 1
    }
    
    // MARK: - Multiple Months Grid (универсальный)
    private func multipleMonthsGridView(months: [Date]) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(months, id: \.self) { month in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(monthYearString(from: month))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .padding(.top, 0)
                            .padding(.leading, 4)
                        CalendarView(habit: habit, month: month, mode: .compactGrid)
                        Spacer(minLength: 0)
                    }
                    .frame(height: 200) // подберите под ваши размеры
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                    .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical)
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
}

// MARK: - CalendarMode
enum CalendarMode {
    case normal        // крупный, без дополнения до 5 строк
    case compactGrid   // мелкий, принудительно 5 строк (35 ячеек)
}

// MARK: - CalendarView
struct CalendarView: View {
    let habit: Habit
    let month: Date
    let mode: CalendarMode
    @Environment(\.modelContext) private var modelContext
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    private var cellSize: CGFloat {
        switch mode {
        case .normal: return 36
        case .compactGrid: return 24
        }
    }
    
    private var fontSize: CGFloat {
        switch mode {
        case .normal: return 17
        case .compactGrid: return 10
        }
    }
    
    private var dayHeaderFont: Font {
        switch mode {
        case .normal: return .caption
        case .compactGrid: return .system(size: 8)
        }
    }
    
    private var spacing: CGFloat {
        switch mode {
        case .normal: return 10
        case .compactGrid: return 2
        }
    }
    
    private var vSpacing: CGFloat {
        switch mode {
        case .normal: return 8
        case .compactGrid: return 2
        }
    }
    
    var body: some View {
        let days = generateDaysForMonth(alwaysFiveRows: mode == .compactGrid)
        
        VStack(spacing: vSpacing) {
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(dayHeaderFont)
                        .foregroundColor(.secondary)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: spacing) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, optionalDate in
                    if let date = optionalDate {
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
                            },
                            size: cellSize,
                            fontSize: fontSize
                        )
                    } else {
                        Color.clear
                            .frame(height: cellSize)
                    }
                }
            }
        }
        .padding(.horizontal, mode == .normal ? 8 : 2)
    }
    
    private func generateDaysForMonth(alwaysFiveRows: Bool = false) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let startOfMonth = monthInterval.start
        let endOfMonth = monthInterval.end
        
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfMonth))!
        
        var dates: [Date?] = []
        var currentDate = startOfWeek
        
        while currentDate < endOfMonth {
            if currentDate < startOfMonth {
                dates.append(nil)
            } else {
                dates.append(currentDate)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        if alwaysFiveRows {
            let requiredTotal = 35
            if dates.count < requiredTotal {
                let missing = requiredTotal - dates.count
                for _ in 0..<missing {
                    dates.append(nil)
                }
            }
        }
        
        return dates
    }
    
    private func toggleCompletion(for date: Date) {
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

// MARK: - DayCell
struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    let isFuture: Bool
    let onTap: () -> Void
    var size: CGFloat = 36
    var fontSize: CGFloat = 17
    
    var body: some View {
        Button(action: {
            if !isFuture {
                onTap()
            }
        }) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: fontSize))
                .foregroundColor(isToday ? .blue : .primary)
                .frame(width: size, height: size)
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
