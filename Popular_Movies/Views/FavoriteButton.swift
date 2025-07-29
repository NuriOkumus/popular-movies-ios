//
//  FavoriteButton.swift
//  Popular_Movies
//
//  Created by Nuri Okumuş on 22.07.2025.
//


import SwiftUI

struct FavoriteButton: View {
    @StateObject var viewModel: FavoriteViewModel

    var body: some View {
        Button {
            viewModel.toggleFavorite()
        } label: {
            Label("Favorite", systemImage: viewModel.isFavorite ? "star.fill" : "star")
                .imageScale(.large)
                .labelStyle(.iconOnly)
                .foregroundStyle(viewModel.isFavorite ? .yellow : .gray)
        }
    }
}
