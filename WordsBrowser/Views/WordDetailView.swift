import SwiftUI

struct WordDetailView: View {
    let wordEntity: WordEntity
    let wordsData = WordsData()
    
    @EnvironmentObject private var storeProvider: StoreProvider
    
    private enum Mode: String, Identifiable, CaseIterable {
        var id: Self { self }
        
        case definition
        case synomyms
        case examples
    }
    
    @State private var currentMode: Mode = .definition
    @State private var word: String = ""
    @State private var pronunciation: String = ""
    @State private var definitions: [Definition] = []
    @State private var synonyms: [String] = []
    @State private var examples: [String] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(word)
                .font(.title2)
                .fontWeight(.medium)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.9), lineWidth: 1)
                }
            Text(pronunciation)
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
                        WordDefinitionsView(definitions: definitions)
                    case .synomyms:
                        if !synonyms.isEmpty {
                            DetailsListView(elements: synonyms)
                        } else {
                            emptyText("synonyms")
                        }
                    case .examples:
                        if !examples.isEmpty {
                            DetailsListView(elements: examples)
                        } else {
                            emptyText("examples")
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
            await fetchDetails()
        }
    }
    
    private func fetchDetails() async {
        word = wordEntity.word
        pronunciation = wordEntity.pronunciation ?? ""
        definitions = (wordEntity.definitions?.allObjects as? [DefinitionEntity])?.map { definitionEntity -> Definition in
                .init(definition: definitionEntity.definition, partOfSpeech: definitionEntity.partOfSpeech)
        } ?? []
        await fetchSynonyms()
        await fetchExamples()
    }
    
    private func fetchSynonyms() async {
        if let cachedSynonyms = storeProvider.fetchSynonyms(for: word), !cachedSynonyms.isEmpty {
            synonyms = cachedSynonyms
            return
        }
        
        do {
            let fetchedSynonyms = try await wordsData.fetchSynonyms(word)
            synonyms = fetchedSynonyms.synonyms
            storeProvider.saveSynonyms(fetchedSynonyms.synonyms, for: word)
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    private func fetchExamples() async {
        if let cachedExamples = storeProvider.fetchExamples(for: word), !cachedExamples.isEmpty {
            examples = cachedExamples
            return
        }
        
        do {
            let fetchedExamples = try await wordsData.fetchExamples(word)
            examples = fetchedExamples.examples
            storeProvider.saveExamples(fetchedExamples.examples, for: word)
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    private func emptyText(_ text: String) -> some View {
        Text("No \(text) found 😔")
    }
}

struct WordDefinitionsView: View {
    let definitions: [Definition]
    
    var body: some View {
        ForEach(definitions) { result in
            if let index = definitions.firstIndex(where: { $0.definition == result.definition }) {
                DefinitionView(index: index,
                               definition: result.definition,
                               partOfSpeech: result.partOfSpeech)
                if index < definitions.indices.last ?? 0 {
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
    WordDetailView(wordEntity: WordEntity.sampleWord)
        .environmentObject(StoreProvider.preview)
}
