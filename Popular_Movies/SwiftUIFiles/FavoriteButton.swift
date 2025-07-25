//
//  FavoriteButton.swift
//  Popular_Movies
//
//  Created by Nuri Okumuş on 22.07.2025.
//


import SwiftUI

struct FavoriteButton: View {
    let movieID: Int
    @State private var isFavourite: Bool

    init(movieID: Int) {
        self.movieID = movieID
        let ids = UserDefaults.standard.array(forKey: "favoriteIDs") as? [Int] ?? []
        _isFavourite = State(initialValue: ids.contains(movieID))
    }

    var body: some View {
        Button {
            toggleFavorite()
        } label: {
            Label("Favorite", systemImage: isFavourite ? "star.fill" : "star")
                .imageScale(.large)
                .labelStyle(.iconOnly)
                .foregroundStyle(isFavourite ? .yellow : .gray)
        }
    }

    private func toggleFavorite() {
        var ids = UserDefaults.standard.array(forKey: "favoriteIDs") as? [Int] ?? []
        if let idx = ids.firstIndex(of: movieID) {
            ids.remove(at: idx)
            isFavourite = false
        } else {
            ids.append(movieID)
            isFavourite = true
        }
        UserDefaults.standard.set(ids, forKey: "favoriteIDs")
    }
}
