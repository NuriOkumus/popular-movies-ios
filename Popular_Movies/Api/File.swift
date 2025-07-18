//
//  File.swift
//  Popular_Movies
//
//  18.07.2025 tarihinde Nuri Okumuş tarafından oluşturuldu.
//
//  Bu dosya, The Movie Database (TMDB) servisinden **Popüler Filmler** listesini
//  çekmek için tek bir yardımcı (helper) fonksiyon içerir. Fonksiyon tamamen
//  asenkron olarak çalışır ve elde ettiği JSON verisini `MovieBrief` model
//  dizisine dönüştürür. Eğer bir hata oluşursa boş bir dizi döner. Global
//  durumda hiçbir değişiklik yapılmaz.
//
//  TMDB "Popüler Filmler" uç noktası dokümantasyonu:
//  https://developer.themoviedb.org/reference/movie-popular-list
//

import Foundation

/// TMDB’den popüler filmleri çeker ve `MovieBrief` dizisi olarak döner.
/// - Returns: `MovieBrief` tipinde popüler film dizisi; hata durumunda boş dizi.
func getMovies () async -> [MovieBrief] {
    // 1. Temel URL oluşturulur.
    let url = URL(string: "https://api.themoviedb.org/3/movie/popular")!

    // 2. Sorgu parametreleri eklemek için URLComponents kullanılır.
    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    let queryItems: [URLQueryItem] = [
        URLQueryItem(name: "language", value: "en-US"), // Dil: İngilizce
        URLQueryItem(name: "page", value: "1"),          // Sayfa: 1
    ]
    // Mevcut queryItems varsa birleştir, yoksa direkt ata
    components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

    // 3. HTTP isteği hazırlığı
    var request = URLRequest(url: components.url!)
    request.httpMethod = "GET"
    request.timeoutInterval = 10 // saniye
    request.allHTTPHeaderFields = [
        "accept": "application/json",
        "Authorization": "Bearer \(ProcessInfo.processInfo.environment["TMDB_BEARER_TOKEN"] ?? "")"
    ]

    do {
        // 4. Asenkron ağ çağrısı
        let (data, _) = try await URLSession.shared.data(for: request)

        // 5. JSON çözümleme
        guard
            let root   = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let items  = root["results"] as? [[String: Any]]
        else {
            return [] // JSON beklenen formatta değilse
        }

        // 6. Modelleştirme: Her sözlüğü `MovieBrief` nesnesine dönüştür
        let movies = items.compactMap { dict -> MovieBrief? in
            guard
                let title    = dict["title"]    as? String,
                let overview = dict["overview"] as? String
            else { return nil }

            let poster = dict["poster_path"] as? String

            return MovieBrief(title: title, overview: overview, posterPath: poster)
        }
        return movies
    } catch {
        // 7. Hata yakalama: Konsola yazdır ve boş dizi döndür
        print("Hata:", error)
        return []
    }
}
