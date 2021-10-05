//
//  ContentView.swift
//  Flashzilla
//
//  Created by Arkasha Zuev on 08.09.2021.
//

import CoreHaptics
import SwiftUI

enum ActiveSheet: Identifiable {
    case first, second
    
    var id: Int {
        hashValue
    }
    
}

struct ContentView: View {
    
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    @State private var cards = [Card]()
    @State private var timeRemaining = 100
    @State private var isActive = true
    @State private var reuseWords = false
    @State private var activeSheet: ActiveSheet?
    @State private var showingAlert = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack {
                    HStack {
                        Button {
                            activeSheet = .first
                        } label: {
                            Image(systemName: "plus.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .padding([.leading], 10)
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding()
                        
                        Spacer()
                        
                        Text("Timer: \(timeRemaining)")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding([.horizontal], 20)
                            .padding([.vertical], 5)
                            .background(
                                Capsule()
                                    .fill(Color.black)
                                    .opacity(0.75)
                            )
                        
                        Spacer()
                        
                        Button {
                            activeSheet = .second
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .padding([.trailing], 10)
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding()
                    }
                }
                .padding([.top], 10)
                
                Spacer()
                
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: self.cards[index]) { move in
                            if move {
                                self.moveToBack(at: index)
                            } else {
                                self.removeCard(at: index)
                            }
                        }
                        .stacked(at: index, in: self.cards.count)
                        .allowsHitTesting(index == self.cards.count - 1)
                        .accessibility(hidden: index < self.cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty {
                    Button("Start again", action: resetCards)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || accessibilityEnabled {
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            withAnimation {
                                self.moveToBack(at: self.cards.count - 1)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(label: Text("Mark your answer as being incorect."))
                        
                        Spacer()

                        Button {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1)
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(label: Text("Mark your answer as being correct."))
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard self.isActive else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.showingAlert = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if self.cards.isEmpty == false {
                self.isActive = true
            }
        }
        .onAppear(perform: resetCards)
        .sheet(item: $activeSheet, onDismiss: resetCards) { item in
            switch item {
            case .first:
                EditCards()
            case .second:
                Settings()
            }
        }
        .alert(isPresented: $showingAlert) {
            let message =
                cards.count == 1
                ? "1 word was not guessed"
                : "\(cards.count) words were not guessed"
            return Alert(title: Text("Game over"), message: Text(message), dismissButton: .default(Text("OK"), action: {
                resetCards()
            }))
        }
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
        if let data = UserDefaults.standard.data(forKey: "reuseWords") {
            if let decoded = try? JSONDecoder().decode(Bool.self, from: data) {
                self.reuseWords = decoded
            }
        }
    }
    
    func resetCards() {
        timeRemaining = 5
        isActive = true
        loadData()
        cards.shuffle()
    }
    
    func moveToBack(at index: Int) {
        guard index >= 0 else { return }
        
        let card = cards.remove(at: index)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cards.insert(card, at: 0)
        }
//        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
//            cards.insert(card, at: 0)
//        }
    }
    
    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        
        cards.remove(at: index)
        
        if cards.isEmpty {
            isActive = false
        }
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 20))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
