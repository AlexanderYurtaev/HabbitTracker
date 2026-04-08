import XCTest

final class HabitTrackerUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        deleteApp()
        app.launch()
    }

    override func tearDownWithError() throws {
        deleteApp()
        super.tearDown()
    }

    // MARK: - Удаление приложения
    private func deleteApp() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let appIcon = springboard.icons["MyHabbitTracker"]
        guard appIcon.exists else { return }
        
        appIcon.press(forDuration: 1.5)
        
        let deleteAppButton = springboard.buttons.matching(NSPredicate(format: "label == 'Удалить приложение' OR label == 'Delete App'")).firstMatch
        if deleteAppButton.waitForExistence(timeout: 2) {
            deleteAppButton.tap()
            
            // Ждём появления любого диалога и ищем кнопку "Удалить" (не "Отмена")
            let confirmButton = springboard.alerts.buttons.matching(NSPredicate(format: "label == 'Удалить приложение' OR label == 'Delete'")).firstMatch
            if confirmButton.waitForExistence(timeout: 3) {
                confirmButton.tap()
                sleep(2)
            } else {
                // Если не нашли в springboard, ищем в приложении
                let appConfirm = XCUIApplication().alerts.buttons.matching(NSPredicate(format: "label == 'Удалить' OR label == 'Delete'")).firstMatch
                if appConfirm.waitForExistence(timeout: 2) {
                    appConfirm.tap()
                    sleep(2)
                }
            }
            // Ждём появления любого диалога и ищем кнопку "Удалить" (не "Отмена")
            let confirmButton2 = springboard.alerts.buttons.matching(NSPredicate(format: "label == 'Удалить' OR label == 'Delete'")).firstMatch
            if confirmButton2.waitForExistence(timeout: 3) {
                confirmButton2.tap()
                sleep(2)
            } else {
                // Если не нашли в springboard, ищем в приложении
                let appConfirm2 = XCUIApplication().alerts.buttons.matching(NSPredicate(format: "label == 'Удалить' OR label == 'Delete'")).firstMatch
                if appConfirm2.waitForExistence(timeout: 2) {
                    appConfirm2.tap()
                    sleep(2)
                }
            }
        }
    }

    // MARK: - Тесты

    func testAddNewHabit() throws {
        let addButton = app.buttons["addHabitButton"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()

        let nameTextField = app.textFields["habitNameTextField"]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 2))
        nameTextField.tap()
        nameTextField.typeText("Тестовая привычка")

        let firstCardColor = app.otherElements["cardColor_0"].firstMatch
        if firstCardColor.exists { firstCardColor.tap() }

        let saveButton = app.buttons["saveHabitButton"]
        saveButton.tap()

        // Ждём, пока список обновится
        let newHabit = app.staticTexts["Тестовая привычка"] // поиск по тексту
        let exists = newHabit.waitForExistence(timeout: 5)
        if !exists {
            print(app.debugDescription)
        }
        XCTAssertTrue(exists)
    }

    func testMarkHabitCompletion() throws {
        let habitName = "Тест_для_отметки"
        addTestHabit(name: habitName)
        
        let habitText = app.staticTexts[habitName]
        XCTAssertTrue(habitText.waitForExistence(timeout: 5))
        
        // Находим ячейку списка, которая содержит этот текст
        let cell = app.cells.containing(.staticText, identifier: habitName).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        
        sleep(1) // даём время на отрисовку кнопок внутри ячейки
        
        let dayNumber = Calendar.current.component(.day, from: Date())
        // Ищем кнопку внутри ячейки, чей label содержит число дня
        let dayButton = cell.buttons.matching(NSPredicate(format: "label CONTAINS %@", String(dayNumber))).firstMatch
        XCTAssertTrue(dayButton.waitForExistence(timeout: 3))
        dayButton.tap()
        
        let checkmark = dayButton.images["checkmark"]
        XCTAssertTrue(checkmark.waitForExistence(timeout: 2))
    }

    func testNavigateToHabitHistory() throws {
        addTestHabit(name: "Тест_для_навигации")
        let habitText = app.staticTexts["Тест_для_навигации"]
        XCTAssertTrue(habitText.waitForExistence(timeout: 3))
        habitText.tap()
        let historyNavBar = app.navigationBars["Тест_для_навигации"]
        XCTAssertTrue(historyNavBar.waitForExistence(timeout: 2))
    }

    func testSwitchPeriodTo12Months() throws {
        addTestHabit(name: "Тест_периода")
        let habitText = app.staticTexts["Тест_периода"]
        XCTAssertTrue(habitText.waitForExistence(timeout: 3))
        habitText.tap()

        let periodPicker = app.segmentedControls["periodPicker"]
        XCTAssertTrue(periodPicker.exists)
        periodPicker.buttons["12 месяцев"].tap()

        // Ищем кнопки навигации по годам
        let prevButton = app.buttons["previousYearButton"]
        let nextButton = app.buttons["nextYearButton"]
        XCTAssertTrue(prevButton.exists)
        XCTAssertTrue(nextButton.exists)
    }

    func testEditHabit() throws {
        let habitName = "Редактируемая_привычка"
        addTestHabit(name: habitName)
        
        let habitText = app.staticTexts["\(habitName)"]
        XCTAssertTrue(habitText.waitForExistence(timeout: 3))
        habitText.tap()

        let editButton = app.buttons["editHabitButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 2))
        editButton.tap()

        let nameField = app.textFields["habitNameTextField"]
        nameField.tap()
        nameField.tap() // выделить весь текст
        nameField.typeText("Новое название")

        let saveButton = app.buttons["saveEditedHabitButton"]
        if saveButton.exists {
            saveButton.tap()
        } else {
            app.buttons["Сохранить"].tap()
        }

        // Возвращаемся на главный экран
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        backButton.tap()
        
        let updatedHabit = app.staticTexts["\(habitName)Новое название"]
        XCTAssertTrue(updatedHabit.waitForExistence(timeout: 2))
    }

    // MARK: - Вспомогательные методы
    private func addTestHabit(name: String) {
        // Если привычка уже есть, не создаём заново
        if app.staticTexts[name].exists { return }
        
        app.buttons["addHabitButton"].tap()
        let textField = app.textFields["habitNameTextField"]
        textField.tap()
        textField.typeText(name)
        app.buttons["saveHabitButton"].tap()
        // Ждём появления текста привычки
        _ = app.staticTexts[name].waitForExistence(timeout: 5)
    }
}
