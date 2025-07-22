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
            UserDefaults.standard.set(isFavourite, forKey: favoriteKey)
        } label : {
            Label("Favorite", systemImage: isFavourite ? "star.fill" : "star")
                .labelStyle(IconOnlyLabelStyle())
                .foregroundStyle(isFavourite ? .yellow : .gray)
        }
    }
}

#Preview {
    FavoriteButton(isFavourite: .constant(true))
}
