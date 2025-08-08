//
//  ContentView.swift
//  udiSearch
//
//  Created by Nicole Tang on 7/29/25.
//

import SwiftUI

struct ContentView: View {
    @State private var diInput = ""
    @State private var keyValues: [KeyValue] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("UDI Lookup from GUDID")
                .font(.title2)
                .fontWeight(.bold)

            TextField("Enter Device Identifier (DI)", text: $diInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Lookup Device") {
                lookupDevice()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(diInput.isEmpty)

            if isLoading {
                ProgressView("Loading...")
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if !keyValues.isEmpty {
                List(keyValues) { item in
                    HStack {
                        Text(formatKey(item.key))
                            .fontWeight(.bold)
                            .frame(width: 150, alignment: .leading)
                        Spacer()
                        Text(item.value)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            Spacer()
        }
        .padding()
    }

    private func lookupDevice() {
        isLoading = true
        errorMessage = nil
        keyValues = []

        APIService.shared.fetchFilteredKeyValues(di: diInput) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let pairs):
                    if pairs.isEmpty {
                        self.errorMessage = "Product not found"
                    } else {
                        self.keyValues = pairs
                    }
                case .failure:
                    self.errorMessage = "Product not found"
                }
            }
        }
    }

    private func formatKey(_ key: String) -> String {
        return key.split(separator: ".").last.map(String.init) ?? key
    }
}
