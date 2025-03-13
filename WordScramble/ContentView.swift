//
//  ContentView.swift
//  WordScramble
//
//  Created by Izaan Saleem on 31/01/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords: [String] = []
    //@State private var usedWords: [String] = ["chink", "chock", "conch", "chino", "icing", "king", "inch", "icon", "coin"]
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var attempts = 0
    @State private var showScore: Bool = false
    @State private var score: Double = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        .accessibilityElement()
                        .accessibilityLabel(word)
                        .accessibilityHint("\(word.count) letters") // hint reads after short pause
                    }
                }
                Section {
                    Text("Attempt(s): \(attempts)")
                    Text("Accepted word(s): \(usedWords.count)")
                }
                
                Section {
                    if showScore {
                        HStack {
                            Spacer()
                            VStack {
                                Text("Result").font(.title2).fontWeight(.medium).fontDesign(.monospaced)
                                Text("\(score.formatted())%").font(.title).fontWeight(.medium).fontDesign(.monospaced)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("Start Game") {
                    startGame()
                }
            }
            .onSubmit {
                if rootWord != "" {
                    addNewWord()
                } else {
                    wordError(title: "Oops!!", message: "Start game to continue!")
                }
            }
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        attempts += 1
        
        if isWordAllowed(word: answer) {
            if isOriginal(word: answer) {
                if isPossible(word: answer) {
                    if isReal(word: answer) {
                        withAnimation {
                            usedWords.insert(answer, at: 0)
                        }
                        newWord = ""
                    } else {
                        wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
                    }
                } else {
                    wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
                }
            } else {
                wordError(title: "Word used already", message: "Be more original")
            }
        } else {
            wordError(title: "Word not allowed", message: "Words less then 3 characters are not allowed!")
        }
        
        if attempts >= 10 {
            showScore = true
            score = Double(usedWords.count)/10.0 * 100.0
        }
        
        
        /*guard isWordAllowed(word: answer) else {
            wordError(title: "Word not allowed", message: "Words less then 3 characters are not allowed!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        
        
        if attempts > 2 {
            showScore = true
            score = attempts - usedWords.count
            return
        }*/
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                newWord = ""
                attempts = 0
                usedWords = []
                score = 0
                showScore = false
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isWordAllowed(word: String) -> Bool {
        return word.count > 3 ? true : false
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
