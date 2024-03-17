import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date?
    @State private var currentMonth = Date()
    @ObservedObject private var viewModel: CalendarViewModel
    @State private var showingDreamDetails = false
    @State private var selectedDreamEntry: DreamEntryEntity?

    init() {
        let sessionManager = SessionManager.shared
        _viewModel = ObservedObject(wrappedValue: CalendarViewModel(coreDataManager: CoreDataManager.shared, sessionManager: sessionManager))
    }

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "dream.jpg") ?? UIImage())
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
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

                HStack {
                    Button(action: {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                        viewModel.fetchDreamEntries(for: currentMonth) // Fetch entries for the new month
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .padding(.leading)

                    Text(currentMonth, formatter: DateFormatter.monthYear)
                        .font(.title)
                        .foregroundColor(.white)

                    Button(action: {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                        viewModel.fetchDreamEntries(for: currentMonth) // Fetch entries for the new month
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing)
                }

                ScrollView {
                    CalendarGridView(selectedDate: $selectedDate, currentMonth: $currentMonth, dreamEntries: viewModel.dreamEntries)

                }
                .padding(30)

                if let selectedDate = selectedDate,
                let dreamEntry = viewModel.dreamEntries.first(where: { Calendar.current.isDate($0.dreamDate ?? Date(), inSameDayAs: selectedDate) }) {
                Button("Show Dream Details") {
                    self.selectedDreamEntry = dreamEntry
                    self.showingDreamDetails = true
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .blur(radius: showingDreamDetails ? 20 : 0)

        if showingDreamDetails, let selectedDreamEntry = selectedDreamEntry {
            DreamDetailsView(dreamEntry: selectedDreamEntry, isShowing: $showingDreamDetails)
                .animation(.easeInOut)
                .transition(.move(edge: .bottom))
        }
    }
    .onChange(of: selectedDate) { newDate in
        guard let newDate = newDate else { return }
        viewModel.fetchDreamEntries(for: newDate) // Refetch entries for the selected date
    }
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
            }
        }) {
            Text("\(day)")
                .font(hasEntry ? .headline.weight(.bold) : .headline) // Apply bold font if there's an entry
                .foregroundColor(isSelected ? .black : .white)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.white : Color.black)
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

