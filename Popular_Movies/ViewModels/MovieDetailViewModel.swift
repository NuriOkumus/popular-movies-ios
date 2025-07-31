//
//  MovieDetailViewModel.swift
//  Popular_Movies
//
//  Created by Nuri Okumuş on 29.07.2025.
//


import Foundation
import Combine

class MovieDetailViewModel: ObservableObject {
    let movie: MovieBrief  // View'e sunulacak temel veri
    @Published var isFavorite: Bool = false

    init(movie: MovieBrief) {
        self.movie = movie
        let ids = UserDefaults.standard.array(forKey: "favoriteIDs") as? [Int] ?? []
        self.isFavorite = ids.contains(movie.id)
    }

    func toggleFavorite() {
        var ids = UserDefaults.standard.array(forKey: "favoriteIDs") as? [Int] ?? []
        if let idx = ids.firstIndex(of: movie.id) {
            ids.remove(at: idx)
            isFavorite = false
        } else {
            ids.append(movie.id)
            isFavorite = true
        }
        UserDefaults.standard.set(ids, forKey: "favoriteIDs")
    }
}
