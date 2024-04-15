import SwiftUI

struct DreamEntryDetailView: View {
    @ObservedObject var viewModel: DreamEntriesViewModel
    var dreamEntry: DreamEntryEntity
    @Binding var isShowingDetail: DreamEntryEntity?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Date: \(dreamEntry.dreamDate ?? Date(), formatter: DateFormatter.date)").font(.headline)
            Text("I dreamed about:").font(.subheadline)
            Text(dreamEntry.dreamInput ?? "No dream input").padding(.bottom)
            Text("Interpretation:").font(.subheadline)
            Text(dreamEntry.dreamInterpretation ?? "No interpretation").padding(.bottom)
            Spacer()
            HStack {
                Spacer()
                Button("Delete") {
                    viewModel.deleteDreamEntry(entry: dreamEntry) { success in
                        if success {
                            // Close the detail view since the entry is deleted
                            isShowingDetail = nil
                        }
                    }
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                Spacer()
                Button("Back") {
                    isShowingDetail = nil // Correctly dismiss the view
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .frame(width: 300, height: 400)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
