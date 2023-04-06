//
//  ContentView.swift
//  Knapsack
//
//  Created by Tyler Hillsman on 4/5/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var knapsackManager = KnapsackManager()
    
    @State var url = ""
    @State var comment = ""
    
    var body: some View {
        VStack {
            VStack {
                TextField("URL", text: $url)
                    .textContentType(.URL)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                TextField("Comment", text: $comment)
                    .textFieldStyle(.roundedBorder)
                Button {
                    knapsackManager.add(url: url, comment: comment)
                    url = ""
                    comment = ""
                } label: {
                    Text("Save")
                }
            }
            .padding()

            List(knapsackManager.items) { item in
                VStack(alignment: .leading) {
                    Text(item.comment)
                    Text(item.url)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
