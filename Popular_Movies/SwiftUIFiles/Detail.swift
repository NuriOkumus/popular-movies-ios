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

import SwiftUI        // SwiftUI çerçevesi: Deklaratif arayüz oluşturma API’si
import Kingfisher

// MARK: - Film Detay Görünümü
/// Popüler filmler listesinden seçilen filmi detaylı gösterir.
struct MovieDetailView: View {
    /// Liste ekranından gelen film modeli
    let movie: MovieBrief
    @State private var isFavourite = false
    
    init(movie: MovieBrief) {
        self.movie = movie
        // “fav_Superman” anahtarındaki değeri oku (yoksa false)
        _isFavourite = State(initialValue:
            UserDefaults.standard.bool(forKey: "fav_\(movie.title)") // favori olup olmadığını kontrol 
        )
    }
    
    
    var body: some View {
        // Kaydırılabilir dikey alan—uzun açıklamalar ekrana sığmayabilir
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                KFImage(movie.posterURL500)
                    .placeholder { ProgressView() }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)

                // MARK: Başlık
                Text(movie.title)
                    .font(.title)
                    .bold()

                // MARK: Açıklama
                Text(movie.overview)
                    .font(.body)

                // Alt boşluk: Son öğenin ekran kenarıyla bitişmesini engeller
                Spacer(minLength: 20)
            }
            .padding() // Çevresel iç kenar boşluğu
        }
        
        .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        FavoriteButton(isFavourite: $isFavourite)
                    }
                }
        .onChange(of: isFavourite) { newValue in // değişimi dinler userdefaults'a entegre eder
            UserDefaults.standard.set(newValue,
                                      forKey: "fav_\(movie.title)")
        }
    }
}



// MARK: - Önizleme
struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MovieDetailView(movie: MovieBrief(
                title: "Inception",
                overview: "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.",
                posterPath: "/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg"
            ))
        }
    }
}
