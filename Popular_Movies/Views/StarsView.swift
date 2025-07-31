//
//  StarsView.swift
//  Popular_Movies
//
//  Created by Nuri Okumuş on 31.07.2025.
//

import SwiftUI

struct StarsView: View {
    @Binding var rating: CGFloat
    var maxRating: Int

    var body: some View {
        let stars = HStack(spacing: 0) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        rating = CGFloat(index + 1)
                    }
            }
        }

        stars.overlay(
            GeometryReader { g in
                let width = rating / CGFloat(maxRating) * g.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: width)
                        .foregroundColor(.yellow)
                }
            }
            .mask(stars)
        )
        .foregroundColor(.gray)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let percent = value.location.x / (CGFloat(maxRating) * 30) // 30 = approximate star width
                    rating = max(0, min(CGFloat(maxRating), percent * CGFloat(maxRating)))
                }
        )
    }
}
