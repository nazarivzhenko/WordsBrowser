import SwiftUI

struct ContentView: View {
    @State private var wordText: String = ""
    @State private var isSearching: Bool = false
    @FocusState private var isFocused: Bool
    @EnvironmentObject private var storeProvider: StoreProvider
    private let wordsData = WordsData()
    
    var body: some View {
        NavigationStack {
            List {
                if !storeProvider.words.isEmpty {
                    Section {
                        ForEach(storeProvider.words, id: \.word) { wordEntity in
                            NavigationLink(destination: WordDetailView(wordEntity: wordEntity)) {
                                Text(wordEntity.word)
                            }
                        }
                    } header: {
                        Text("All words")
                    }
                }
            }
            .overlay {
                HStack {
                    TextField("Type your word...", text: $wordText)
                        .focused($isFocused)
                        .accentColor(.gray)
                        .fontDesign(.rounded)
                        .textInputAutocapitalization(.never)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                        }
                    Spacer()
                    Button(action: fetchWord) {
                        Image(systemName: "plus")
                            .padding(8)
                            .fontWeight(.medium)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .disabled(wordText.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .overlay {
                if isSearching {
                    VStack {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.25))
                }
            }
            .navigationTitle("Words")
        }
        .task {
            try? await Task.sleep(for: .seconds(0.15))
            isFocused = true
        }
        .onAppear {
            storeProvider.fetchAllWords()
        }
    }
    
    private func fetchWord() {
        Task {
            do {
                isSearching = true
                let word = try await wordsData.fetchWord(wordText)
                
                try await Task.sleep(for: .seconds(0.5))
                
                storeProvider.saveWord(word.word, pronunciation: word.pronunciation.all)
                word.results.forEach { resultElement in
                    storeProvider.saveDefinition(
                        resultElement.definition,
                        partOfSpeech: resultElement.partOfSpeech,
                        for: word.word
                    )
                }
                storeProvider.fetchAllWords()
            } catch {
                print("Error fetching word: \(error.localizedDescription)")
            }
            
            withAnimation {
                wordText.removeAll()
                isSearching = false
                isFocused = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreProvider.preview)
}
