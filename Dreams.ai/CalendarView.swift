import SwiftUI


struct CalendarView: View {
    @State private var selectedDate: Date?
    @State private var currentMonth = Date()

    var body: some View {
        NavigationView {
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
                            selectedDate = nil // Clear the selected date when switching months
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .padding(.leading)

                        Text("\(currentMonth, formatter: DateFormatter.monthYear)")
                            .font(.title)
                            .foregroundColor(.white)

                        if !Calendar.current.isDate(currentMonth, inSameDayAs: Date()) {
                            Button(action: {
                                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                                selectedDate = nil // Clear the selected date when switching months
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing)
                        }
                    }

                    ScrollView {
                        CalendarGridView(selectedDate: $selectedDate, currentMonth: $currentMonth)
                    }
                    .padding(30) // Add padding to the ScrollView

                    if let selectedDate = selectedDate {
                        Text("Selected Date: \(selectedDate, formatter: DateFormatter.date)")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                    }
                }
            }
        }
    .navigationBarBackButtonHidden(true)
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date?
    @Binding var currentMonth: Date
    @State private var dreamEntries: [Date: String] = [:] // Dictionary to store dream entries

    var body: some View {
        let calendar = Calendar.current

        let dateRange = calendar.range(of: .day, in: .month, for: currentMonth)!
        let daysInMonth = dateRange.count

        return LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
            ForEach(1..<daysInMonth + 1, id: \.self) { day in
                CalendarCell(day: day, selectedDate: $selectedDate)
            }
        }
    }
}

struct CalendarCell: View {
    let day: Int
    @Binding var selectedDate: Date?

    var isSelected: Bool {
        if let selectedDate = selectedDate {
            return Calendar.current.isDate(selectedDate, inSameDayAs: Calendar.current.date(bySetting: .day, value: day, of: selectedDate)!)
        }
        return false
    }

    var body: some View {
        Button(action: {
            if let currentSelectedDate = selectedDate, currentSelectedDate != Calendar.current.date(bySetting: .day, value: day, of: currentSelectedDate) {
                selectedDate = Calendar.current.date(bySetting: .day, value: day, of: currentSelectedDate)
            } else {
                selectedDate = Calendar.current.date(bySetting: .day, value: day, of: selectedDate ?? Date())
            }
        }) {
            Text("\(day)")
                .font(.headline)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.white : Color.black) // White if selected, black otherwise
                .foregroundColor(isSelected ? Color.black : Color.white) // Black text if selected, white otherwise
                .cornerRadius(20)
        }
    }
}

extension DateFormatter {
    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMMM yyyy"
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
