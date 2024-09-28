//
//  TopTitleView.swift
//  Testtask
//
//  Created by Miguel T on 27/09/24.
//

import SwiftUI

struct TopTitleView: View {
    var title: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.nunitoSans(size: 20))
            Spacer()
        }
        .padding(.vertical)
        .background(.appPrimary)
        .clipped()
    }
}

#Preview {
    TopTitleView(title: String(localized: "UsersView_title"))
}
