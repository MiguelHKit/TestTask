//
//  RadioSelectionView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

fileprivate struct RadioButton: View {
    let id: Int
    @Binding var selectedId: Int?
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
    @Binding var selectedId: Int?
    @Binding var selectedItems: [String]
    var items: [(key: Int, value: String)]
    var titleLabel: String
    var allowMultiselection: Bool
    var tint: Color
    
    var body: some View {
        VStack {
            HStack {
                Text(titleLabel)
                    .font(.nunitoSans(size: 18))
                Spacer()
            }
            ForEach(items, id: \.key) { item in
                HStack {
                    RadioButton(
                        id: item.key,
                        selectedId: $selectedId,
                        tint: tint
                    )
                    Text(item.value)
                        .font(.nunitoSans(size: 16))
                        .foregroundColor(.black)
                        .onTapGesture { selectedId = item.key } // is necesary this tapEvent causea visual bug when user taps
                    Spacer()
                }
                .padding(.top)
                .padding(.leading)
            }
        }
    }
}

struct RadioSingleSelectionView: View {
    @Binding var selectedId: Int?
    var items: [Int:String]
    var titleLabel: String
    var tint: Color = .appSecondary
    
    var body: some View {
        RadioSelectionView(
            selectedId: $selectedId,
            selectedItems: .constant([]),
            items: items.map { ($0.key, $0.value) },
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
//    var tint: Color = .appSecondary
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
    @State var selectedOption: Int? = nil
    @State var selectedOptions: [Int:String] = [:]
    var items: [Int:String] = [
        0:"item 1",
        1:"item 2",
        2:"item 3",
    ]
    
    var body: some View {
//        TabView {
            ScrollView {
                RadioSingleSelectionView(
                    selectedId: $selectedOption,
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
