//
//  MovieListViewModel.swift
//  Popular_Movies
//
//  Created by Nuri Okumuş on 29.07.2025.
//

import SwiftUI

class MovieListViewModel: ObservableObject {
    @Published var movies: [MovieBrief] = []
    @Published var searchText: String = ""
    @Published var showFavoritesOnly: Bool = false
    @Published var favoriteIDs: Set<Int> = []

    var allMovies: [MovieBrief] = []
    var currentPage = 1
    var isLoading = false

    func updateMovies() {
        var list = allMovies

        // Favori filtresi
        if showFavoritesOnly {
            list = list.filter { favoriteIDs.contains($0.id) }
        }

        // Arama filtresi
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter { $0.title.lowercased().contains(q) }
        }

        movies = list
    }

    var favoriteIconName: String {
        showFavoritesOnly ? "star.fill" : "star"
    }

    func toggleFavorites() {
        showFavoritesOnly.toggle()
        updateMovies()
    }

    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        updateMovies()
    }

    func loadPage(page: Int) {  // yeni gelen sayfayı alta ekler
        guard !isLoading else { return }
        guard page <= 5 else { return }
        isLoading = true

        Task {
            let newMovies = await getMovies(page: page)
            await MainActor.run {
                self.allMovies.append(contentsOf: newMovies)
                self.updateMovies()
                self.currentPage = page
                self.isLoading = false
            }
        }
    }
}
