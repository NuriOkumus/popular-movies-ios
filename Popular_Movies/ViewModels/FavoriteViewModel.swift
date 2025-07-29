//
//  FavoriteViewModel.swift
//  Popular_Movies
//
//  Created by Nuri Okumuş on 29.07.2025.
//

import SwiftUI

class FavoriteViewModel: ObservableObject {
    @Published var isFavorite: Bool

    private let movieID: Int

    init(movieID: Int) {
        self.movieID = movieID
        let ids = UserDefaults.standard.array(forKey: "favoriteIDs") as? [Int] ?? []
        self.isFavorite = ids.contains(movieID)
    }

    func toggleFavorite() {
        var ids = UserDefaults.standard.array(forKey: "favoriteIDs") as? [Int] ?? []
        if let idx = ids.firstIndex(of: movieID) {
            ids.remove(at: idx)
            isFavorite = false
        } else {
            ids.append(movieID)
            isFavorite = true
        }
        UserDefaults.standard.set(ids, forKey: "favoriteIDs")
    }
}
