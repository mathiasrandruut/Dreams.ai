import SwiftUI

struct DreamDetailsView: View {
    var dreamEntry: DreamEntryEntity
    @Binding var isShowing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Date: \(dreamEntry.dreamDate ?? Date(), formatter: DateFormatter.date)")
                .font(.headline)
            Text("I dreamed about:")
                .font(.headline)
            Text(dreamEntry.dreamInput ?? "No dream input")
            Text("Interpretation:")
                .font(.headline)
            Text(dreamEntry.dreamInterpretation ?? "No interpretation")
            Spacer()
            Button("Close") {
                isShowing = false
            }
            .padding()
        }
        .frame(width: 300, height: 400)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}

