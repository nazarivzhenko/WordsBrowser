import SwiftUI

struct WordDetailView: View {
    let word: Word
    let wordsData = WordsData()
    
    private enum Mode: String, Identifiable, CaseIterable {
        var id: Self { self }
        
        case definition
        case synomyms
        case examples
    }
    
    @State private var currentMode: Mode = .definition
    @State private var synonyms: [String] = []
    @State private var examples: [String] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(word.word)
                .font(.title2)
                .fontWeight(.medium)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.9), lineWidth: 1)
                }
            Text(word.pronunciation.all)
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.7))
            DetailsPickerView(
                options: Mode.allCases.map { $0.rawValue.capitalized },
                selection: Binding(
                    get: { Mode.allCases.firstIndex(where: { $0 == currentMode })! },
                    set: { currentMode = Mode.allCases[$0] }
                )
            )
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    switch currentMode {
                    case .definition:
                        WordDefinitionsView(word: word)
                    case .synomyms:
                        if !synonyms.isEmpty {
                            DetailsListView(elements: synonyms)
                        } else {
                            Text("No synonyms found 😔")
                        }
                    case .examples:
                        if !examples.isEmpty {
                            DetailsListView(elements: examples)
                        } else {
                            Text("No examples found 😔")
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.top, 8)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .task {
            await fetchData()
        }
    }
    
    private func fetchData() async {
        do {
            async let wordSynonyms = wordsData.fetchSynonyms(word.word)
            async let wordExamples = wordsData.fetchExamples(word.word)
            
            synonyms = try await wordSynonyms.synonyms
            examples = try await wordExamples.examples
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}

struct WordDefinitionsView: View {
    let word: Word
    
    var body: some View {
        ForEach(word.results) { result in
            if let index = word.results.firstIndex(where: { $0.definition == result.definition }) {
                DefinitionView(index: index,
                                   definition: result.definition,
                                   partOfSpeech: result.partOfSpeech)
                if index < word.results.indices.last ?? 0 {
                    Divider()
                }
            }
        }
    }
}

struct DefinitionView: View {
    let index: Int
    let definition: String
    let partOfSpeech: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(partOfSpeech)
                .partOfSpeechTextBackground(partOfSpeech)
            HStack(alignment: .top) {
                Text("\(index + 1).")
                Text(definition)
            }
        }
    }
}

struct DetailsListView<T: RandomAccessCollection>: View where T.Element: StringProtocol, T.Index: Numeric {
    let elements: T
    
    var body: some View {
        ForEach(elements, id: \.self) { element in
            if let index = elements.firstIndex(of: element) {
                HStack(alignment: .top) {
                    Text("\(index + 1).")
                    Text(element)
                }
                if index < elements.indices.endIndex {
                    Divider()
                }
            }
        }
    }
}

struct DetailsPickerView: View {
    let options: [String]
    @Binding var selection: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                Button {
                    selection = index
                } label: {
                    VStack {
                        if selection == index {
                            Divider()
                                .frame(height: 2)
                                .overlay { Color.blue }
                        }
                        Spacer()
                        Text(options[index])
                            .foregroundStyle(selection == index ? Color.black : Color.gray)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                        Spacer()
                        if selection != index {
                            Divider()
                        }
                    }
                    .background(selection == index ? Color.white : Color.gray.opacity(0.1))
                }
                if selection != options.indices.last {
                    Divider()
                }
            }
        }
        .frame(maxHeight: 48)
        .fixedSize()
    }
}

#Preview {
    let word = Word.sampleData[0]
    WordDetailView(word: word)
}
