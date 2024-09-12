//
//  RadioSelectionView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

fileprivate struct RadioButton: View {
    let id: Int
    @Binding var selectedId: Int
    var tint: Color

    var body: some View {
        Button {
            selectedId = id
        } label: {
            Image(systemName: selectedId == id ? "smallcircle.fill.circle.fill" : "circle")
                .foregroundColor(selectedId == id ? tint : .gray)
        }
    }
}

fileprivate struct RadioSelectionView: View {
    @State private var selectedId: Int = -1
    @Binding var selectedItem: String
    @Binding var selectedItems: [String]
    var items: [String]
    var titleLabel: String
    var allowMultiselection: Bool
    var tint: Color
    
    var body: some View {
        VStack {
            HStack {
                Text(titleLabel)
                    .font(.title2)
                Spacer()
            }
            ForEach(items.indices, id: \.self) { index in
                HStack {
                    RadioButton(
                        id: index,
                        selectedId: $selectedId,
                        tint: tint
                    )
                    Text(items[index])
                        .foregroundColor(.black)
                        .onTapGesture { selectedId = index } // is necesary this tapEvent causea visual bug when user taps
                    Spacer()
                }
                .padding(.top)
                .padding(.leading)
            }
        }
        .onChange(of: selectedId) {
            guard 
                selectedId >= 0,
                let selected = items[safe: selectedId]
            else { selectedItem = ""; return }
//            if allowMultiselection {
//                selectedItems.append(selected)
////                selectedItems = Array(Set(selectedItems))
//            } else {
                selectedItem = selected
//            }
        }
    }
}

struct RadioSingleSelectionView: View {
    @Binding var selectedItem: String
    var items: [String]
    var titleLabel: String
    var tint: Color = .appCyan
    
    var body: some View {
        RadioSelectionView(
            selectedItem: $selectedItem,
            selectedItems: .constant([]),
            items: items,
            titleLabel: titleLabel,
            allowMultiselection: false,
            tint: tint
        )
    }
}

//struct RadioMultiSelectionView: View {
//    @Binding var selectedItems: [String]
//    var items: [String]
//    var titleLabel: String
//    var tint: Color = .appCyan
//    
//    var body: some View {
//        RadioSelectionView(
//            selectedItem: .constant(""),
//            selectedItems: $selectedItems,
//            items: items,
//            titleLabel: titleLabel,
//            allowMultiselection: true,
//            tint: tint
//        )
//    }
//}

fileprivate struct PreviewView: View {
    @State var selectedOption: String = ""
    @State var selectedOptions: [String] = []
    var items: [String] = .init(repeating: "Item", count: 25)
    
    var body: some View {
//        TabView {
            ScrollView {
                RadioSingleSelectionView(
                    selectedItem: $selectedOption,
                    items: items,
                    titleLabel: "Select your position"
                )
                .padding()
            }
//            .tabItem { Label("Single Selection", systemImage: "") }
//            ScrollView {
//                RadioMultiSelectionView(
//                    selectedItems: $selectedOptions,
//                    items: items,
//                    titleLabel: "Select your position"
//                )
//                .padding()
//            }
//            .tabItem { Label("Multi Selection", systemImage: "") }
//        }
    }
}

#Preview(body: {
    PreviewView()
})
