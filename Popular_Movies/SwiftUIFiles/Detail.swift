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

// MARK: - Film Detay Görünümü
/// Popüler filmler listesinden seçilen filmi detaylı gösterir.
struct MovieDetailView: View {
    /// Liste ekranından gelen film modeli
    let movie: MovieBrief

    var body: some View {
        // Kaydırılabilir dikey alan—uzun açıklamalar ekrana sığmayabilir
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: Afiş Görseli
                // `AsyncImage` uzaktan resmi indirir ve durumuna göre arayüz günceller.
                AsyncImage(url: movie.posterURL500) { phase in
                    switch phase {
                    case .empty:
                        // Henüz veri gelmedi—küçük yükleniyor göstergesi
                        ProgressView()
                    case .success(let img):
                        // Resim başarıyla indi—esnek boyutlandırıp köşe yumuşat
                        img.resizable()
                           .aspectRatio(contentMode: .fit)
                           .cornerRadius(8)
                    case .failure:
                        // İndirme başarısız—yer tutucu simge göster
                        Image(systemName: "film")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.secondary)
                    @unknown default:
                        // Gelecekteki bilinmeyen durumlar için güvenli varsayılan
                        EmptyView()
                    }
                }

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
        // Büyük başlık yerine satır‑içi başlık görünümü
        .navigationBarTitleDisplayMode(.inline)
    }
}
