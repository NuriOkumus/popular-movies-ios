//
//  Detail.swift
//  Popular_Movies
//
//  18.07.2025 tarihinde Nuri Okumuş tarafından oluşturuldu.
//
//  Bu SwiftUI görünümü, popüler filmler listesinden seçilen bir `MovieBrief`
//  modelinin detaylarını (afiş, başlık ve açıklama) kullanıcıya sunar. Kodda
//  yalnızca görüntüleme (view) katmanına ait düzenlemeler vardır; ağ isteği veya
//  veri işleme yapılmaz.
//
//  ────────────────────────────────────────────────────────────────────────────
//  KULLANIM ÖZETİ
//  • `AsyncImage` ile uzaktan gelen afiş resmi gösterilir.
//  • Başlık (`title`) ve açıklama (`overview`) metin olarak yazdırılır.
//  • Tüm içerik dikey eksende kaydırılabilir (`ScrollView`).
//  • Navigasyon çubuğu başlığı satır‑içi modda tutulur.
//  ────────────────────────────────────────────────────────────────────────────

import SwiftUI
import Kingfisher

struct MovieDetailView: View {
    @StateObject var viewModel: MovieDetailViewModel

    init(movie: MovieBrief) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                KFImage(viewModel.movie.posterURL500)
                    .placeholder { ProgressView() }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)

                Text(viewModel.movie.title)
                    .font(.title)
                    .bold()

                Text(viewModel.movie.overview)
                    .font(.body)

                Spacer(minLength: 20)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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
    }
}
