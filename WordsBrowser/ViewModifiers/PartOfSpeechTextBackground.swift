import SwiftUI

struct PartOfSpeechTextBackground: ViewModifier {
    var text: String
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(backgroundColor(for: text).opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    private func backgroundColor(for text: String) -> Color {
        switch text {
        case "noun":
            .blue
        case "verb":
            .purple
        case "adjective":
            .yellow
        case "adverb":
            .green
        default:
            .gray
        }
    }
}

extension View {
    func partOfSpeechTextBackground(_ text: String) -> some View {
        modifier(PartOfSpeechTextBackground(text: text))
    }
}
