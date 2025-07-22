//
//  MovieBrief.swift
//  Popular_Movies
//
//  18.07.2025 tarihinde Nuri Okumuş tarafından oluşturuldu.
//
//  Bu dosya, TMDB (The Movie Database) servisinden çekilen popüler filmlerin
//  **özet** (brief) bilgilerini temsil eden küçük bir model yapısı içerir.
//  Uygulamanın farklı katmanlarında (liste, detay ekranı vb.) kullanılmak üzere
//  yalın tutulmuştur.
//
//  Alanlar:
//  - `title`:   Filmin başlığı.
//  - `overview`: Kısa açıklaması / özeti.
//  - `posterPath`: Afiş görselinin **yalnızca yol** (path) kısmı. Tam URL içermez;
//                  tam URL, uzantıdaki hesaplanan özellik (`posterURL500`) ile
//                  elde edilir.
//

import Foundation

// MARK: - Model

struct MovieBrief {
    let title: String                // Filmin adı
    let overview: String             // Kısa tanıtım metni
    let posterPath: String?          // "\u002Fabc123.jpg" gibi; tam URL değil
}

// MARK: - Yardımcı Genişletme

extension MovieBrief {
    /// TMDB'nin resim CDN'inden poster URL'sini döndürür.
    /// * Genişlik parametresi kodda `w200` olarak sabitlenmiş durumda.
    /// * `posterPath` nil ise fonksiyon da `nil` döner.
    var posterURL500: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") // w200 -> w500 kalite için 
    }
}
