import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date?
    @State private var currentMonth = Date()
    @ObservedObject private var viewModel: DreamEntriesViewModel
    @State private var showingDreamDetails = false
    @State private var selectedDreamEntries: [DreamEntryEntity] = []

    init() {
        _viewModel = ObservedObject(wrappedValue: DreamEntriesViewModel(coreDataManager: CoreDataManager.shared, sessionManager: SessionManager.shared))
    }

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "dream.jpg") ?? UIImage())
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .blur(radius: showingDreamDetails ? 20 : 0)

            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: MainView()) {
                        Image(systemName: "house.circle")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                .offset(x: -15, y: 0)

                Text("Your dream journal")
                    .font(.title)
                    .bold()
                    .padding()
                    .foregroundColor(.white)

                monthNavigation

                ScrollView {
                    CalendarGridView(selectedDate: $selectedDate, currentMonth: $currentMonth, dreamEntries: selectedDreamEntries)
                }
                .padding(30)
            }

            if showingDreamDetails {
                DreamDetailsView(viewModel: viewModel, isShowing: $showingDreamDetails)
                    .animation(.easeInOut)
                    .transition(.move(edge: .bottom))
            }
        }
        .onChange(of: showingDreamDetails) { _ in
            if !showingDreamDetails {
                selectedDate = nil
                selectedDreamEntries = []
            }
        }
        .onChange(of: selectedDate) { _ in
            processDateChange()
        }
        .onAppear {
            fetchDreamEntriesForCurrentMonth()
        }
    }

    private func fetchDreamEntriesForCurrentMonth() {
        if let userEmail = SessionManager.shared.userEmail {
            viewModel.fetchDreamEntries(forUserEmail: userEmail, byDate: currentMonth)
        }
    }

    private func processDateChange() {
        guard let newDate = selectedDate else {
            showingDreamDetails = false
            selectedDreamEntries = []
            return
        }

        selectedDreamEntries = viewModel.dreamEntries.filter { entry in
            guard let entryDate = entry.dreamDate else { return false }
            return Calendar.current.isDate(entryDate, inSameDayAs: newDate)
        }

        showingDreamDetails = !selectedDreamEntries.isEmpty
    }

    private var monthNavigation: some View {
        HStack {
            Button(action: {
                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                fetchDreamEntriesForCurrentMonth()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .padding(.leading)

            Text(currentMonth, formatter: DateFormatter.monthYear)
                .font(.title2)
                .foregroundColor(.white)

            if !currentMonth.isStartOfMonth() { // Check if the currentMonth is not the start of the current month
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                    fetchDreamEntriesForCurrentMonth()
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                .padding(.trailing)
                .disabled(currentMonth.isDateInFuture())
            }
        }
    }
}

// Extension to check if a date is in the future
extension Date {
    func isDateInFuture() -> Bool {
        return self > Date()
    }
}


struct CalendarGridView: View {
    @Binding var selectedDate: Date?
    @Binding var currentMonth: Date
    var dreamEntries: [DreamEntryEntity] // Add dreamEntries to CalendarGridView
    

    var body: some View {
        let calendar = Calendar.current
        let dateRange = calendar.range(of: .day, in: .month, for: currentMonth)!
        let daysInMonth = dateRange.count

        return LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
            ForEach(1..<daysInMonth + 1, id: \.self) { day in
                CalendarCell(day: day, selectedDate: $selectedDate, currentMonth: currentMonth, dreamEntries: dreamEntries) // Pass dreamEntries to CalendarCell
            }
        }
    }
}


struct CalendarCell: View {
    let day: Int
    @Binding var selectedDate: Date?
    let currentMonth: Date
    let dreamEntries: [DreamEntryEntity]

    var isSelected: Bool {
        guard let selectedDate = selectedDate else { return false }
        let calendar = Calendar.current
        guard let dayDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentMonth),
                                                               month: calendar.component(.month, from: currentMonth),
                                                               day: day)) else { return false }
        return calendar.isDate(selectedDate, inSameDayAs: dayDate)
    }

    var hasEntry: Bool {
        let calendar = Calendar.current
        guard let dayDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentMonth),
                                                               month: calendar.component(.month, from: currentMonth),
                                                               day: day)) else { return false }
        return dreamEntries.contains(where: { entry in
            guard let entryDate = entry.dreamDate else { return false }
            return calendar.isDate(entryDate, inSameDayAs: dayDate)
        })
    }

    var body: some View {
        Button(action: {
            if let newDate = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: currentMonth),
                                                                        month: Calendar.current.component(.month, from: currentMonth),
                                                                        day: day)) {
                selectedDate = newDate
                print("Selected day: \(day)") // Print the selected day
            }
        }) {
            Text("\(day)")
                .font(hasEntry ? .headline.weight(.bold) : .headline)
                .foregroundColor(isSelected ? .black : .white)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.white : Color.black.opacity(0.7))
                .cornerRadius(20)
        }
    }
}





extension DateFormatter {
    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMMM yyyy"
        formatter.timeZone = TimeZone.current // Ensure the formatter uses the current time zone
        return formatter
    }()

    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}

extension Date {
    func isStartOfMonth() -> Bool {
        let calendar = Calendar.current
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        return calendar.isDate(self, equalTo: startOfCurrentMonth, toGranularity: .month)
    }
}

