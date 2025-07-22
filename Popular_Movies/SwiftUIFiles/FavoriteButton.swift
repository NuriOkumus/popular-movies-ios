//
//  FavoriteButton.swift
//  Popular_Movies
//
//  Created by Nuri Okumuş on 22.07.2025.
//


import SwiftUI

struct FavoriteButton: View {
    @Binding var isFavourite : Bool
    let favoriteKey = "isFavorite"
    
    
    var body: some View {
        Button {
            isFavourite.toggle()
        } label : {
            Label("Favorite", systemImage: isFavourite ? "star.fill" : "star")
                .imageScale(.large)
                .labelStyle(IconOnlyLabelStyle())
                .foregroundStyle(isFavourite ? .yellow : .gray)
        }
    }
}

#Preview {
    FavoriteButton(isFavourite: .constant(true))
}
