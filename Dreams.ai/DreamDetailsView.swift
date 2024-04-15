import SwiftUI

struct DreamDetailsView: View {
    @ObservedObject var viewModel: DreamEntriesViewModel
    @Binding var isShowing: Bool
    @State private var selectedEntry: DreamEntryEntity?

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).edgesIgnoringSafeArea(.all).onTapGesture {
                isShowing = false
            }
            VStack(spacing: 10) {
                Text("Dreams Overview").font(.title).bold().padding()
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.dreamEntries, id: \.self) { entry in
                            Button(action: {
                                self.selectedEntry = entry
                            }) {
                                dreamEntryRow(for: entry)
                            }
                        }
                    }
                }
                Button("Close") { isShowing = false }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .frame(width: 360, height: 480)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding([.horizontal, .top])
        }
        .overlay(
            Group {
                if let selectedEntry = selectedEntry {
                    DreamEntryDetailView(viewModel: viewModel, dreamEntry: selectedEntry, isShowingDetail: $selectedEntry)
                }
            }
        )
        .onAppear {
            if viewModel.dreamEntries.count == 1 {
                selectedEntry = viewModel.dreamEntries.first
            }
        }
    }

    @ViewBuilder
    private func dreamEntryRow(for entry: DreamEntryEntity) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.dreamInput?.prefix(50) ?? "No dream input").lineLimit(1)
                Text(entry.dreamDate ?? Date(), formatter: DateFormatter.date).font(.caption).opacity(0.7)
            }
            Spacer()
            Image(systemName: "chevron.right.circle.fill")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

