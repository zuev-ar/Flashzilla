//
//  CardView.swift
//  Flashzilla
//
//  Created by Arkasha Zuev on 16.09.2021.
//

import SwiftUI

struct CardView: View {
    
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    let card: Card
    var completion: ((_ deleteCard: Bool) -> Void)? = nil
    
    @State private var offset = CGSize.zero
    @State private var isShowingAnswer = false
    @State private var feedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                        ? Color.white
                        : Color.white
                        .opacity(abs(1 - Double(abs(offset.width) / 50)))
                )
                .background(
                    differentiateWithoutColor
                        ? nil
                        : RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(offset.width > 0 ? Color.green : Color.red)
                )
                .shadow(radius: 10)

            VStack {
                if accessibilityEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .padding()
                    
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding()
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .offset(x: CGFloat(offset.width * 5), y: 0)
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibility(addTraits: .isButton)
        .gesture(
            DragGesture()
                .onChanged({ gesture in
                    self.offset = gesture.translation
                    self.feedback.prepare()
                })
            
                .onEnded({ _ in
                    if abs(self.offset.width) > 100 {
                        if self.offset.width > 0 {
                            self.feedback.notificationOccurred(.success)
                        } else {
                            self.feedback.notificationOccurred(.error)
                        }
                        self.completion?(self.offset.width < 0)
                    } else {
                        self.offset = .zero
                    }
                })
        )
        .onTapGesture {
            self.isShowingAnswer.toggle()
        }
        .animation(.spring())
    }
}

extension View {
    func customRoundedRectangle(differentiateWithoutColor: Bool, offset: CGSize) -> some View {
        self.modifier(customModifier(differentiateWithoutColor: differentiateWithoutColor, offset: offset))
    }
}

struct customModifier: ViewModifier {
    let differentiateWithoutColor: Bool
    let offset: CGSize
    func body(content: Content) -> some View {
        content
        RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(
                differentiateWithoutColor
                    ? Color.white
                    : Color.white
                    .opacity(abs(1 - Double(abs(offset.width) / 50)))
            )
            .background(
                differentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(offset.width > 0 ? Color.green : Color.red)
            )
            .shadow(radius: 10)
            
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example)
    }
}
