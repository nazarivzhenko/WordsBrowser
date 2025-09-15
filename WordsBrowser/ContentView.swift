import SwiftUI

struct ContentView: View {
    @State private var words: [Word] = []
    @State private var wordText: String = ""
    @State private var isSearching: Bool = false
    @FocusState private var isFocused: Bool
    
    let wordsData = WordsData()
    
    var body: some View {
        NavigationStack {
            List {
                if !words.isEmpty {
                    Section {
                        ForEach(words, id: \.word) { word in
                            NavigationLink(destination: WordDetailView(word: word)) {
                                Text(word.word)
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
            do {
                words = try await wordsData.fetchWords()
            } catch {
                print("Error fetching words: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchWord() {
        Task {
            do {
                isSearching = true
                let word = try await wordsData.fetchWord(wordText)
                
                try await Task.sleep(for: .seconds(0.5))
                
                withAnimation {
                    words.insert(word, at: 0)
                    wordText.removeAll()
                    isSearching = false
                    isFocused = false
                }
            } catch {
                print("Error fetching word: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
