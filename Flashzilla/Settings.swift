//
//  Settings.swift
//  Flashzilla
//
//  Created by Arkasha Zuev on 28.09.2021.
//

import SwiftUI

struct Settings: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var reuseWords = false
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Reuse words", isOn: $reuseWords)
                    .padding()
                Spacer()
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: Button("Done", action: {
                dismiss()
            }))
            .onAppear(perform: loadData)
        }
    }
    
    func dismiss() {
        saveData()
        presentationMode.wrappedValue.dismiss()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "reuseWords") {
            if let decoded = try? JSONDecoder().decode(Bool.self, from: data) {
                reuseWords = decoded
            }
        }
    }
    
    func saveData() {
        if let data = try? JSONEncoder().encode(reuseWords) {
            UserDefaults.standard.setValue(data, forKey: "reuseWords")
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
