//
//  MovieListViewController.swift
//  Popular_Movies
//
//  18.07.2025 tarihinde Nuri Okumuş tarafından oluşturuldu.
//
//  Bu UIKit denetleyicisi (**UIViewController**) popüler filmlerin listesini bir
//  **UITableView** üzerinde gösterir. Veri kaynağı olarak TMDB’den çekilen
//  `MovieBrief` modelleri kullanılır. Hücre seçildiğinde SwiftUI
//  `MovieDetailView` bileşeni bir `UIHostingController` aracılığıyla açılır.
//  ───────────────────────────────────────────────────────────────────────────

import UIKit
import SwiftUI

/// Filmler listesi ekranı (UIKit + SwiftUI entegrasyonu)
class MovieListViewController: UIViewController,
                               UITableViewDataSource,
                               UITableViewDelegate,
                               UISearchResultsUpdating {
    // MARK: - UITableViewDataSource
    /// Tabloda kaç satır olacağını döndürür → filmler dizisinin uzunluğu
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    /// Her satır için hücre oluşturur ve yapılandırır
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reuse mekanizması ile özel hücremizi alıyoruz
        let cell = tableView.dequeueReusableCell(
                      withIdentifier: MovieTableViewCell.reuseID,
                      for: indexPath) as! MovieTableViewCell
        // Hücreyi ilgili filmle yapılandır
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row == movies.count - 1 {      // En alttaki hücre gözüktüğünde yeni sayfayı çağırır
            loadPage(page: currentPage + 1)
        }
    }

    // MARK: - UITableViewDelegate
    /// Bir satıra dokunulduğunda detay ekranına geçiş yapar
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Görsel geri bildirim
        let movie = movies[indexPath.row]
        // SwiftUI ekranını UIKit içerisinde barındırıyoruz
        let detailVC = UIHostingController(rootView: MovieDetailView(movie: movie))
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: - Özellikler
    /// Servisten doldurulan filmler dizisi
    var movies: [MovieBrief] = []
    /// Servisten gelen TAM liste (filtrelenmemiş)
    private var allMovies: [MovieBrief] = []
    /// Yalnızca favorileri gösterme modu açık mı?
    private var showFavoritesOnly: Bool = false
    /// UserDefaults'ta saklanan favori film başlıkları kümesi
    private var favoriteTitles: Set<String> {
        // 1) Yeni format: tek dizi altında saklanan başlıklar
        let stored = UserDefaults.standard.stringArray(forKey: "favoriteTitles") ?? []

        // 2) Eski format: her film başlığı için "fav_<title>" anahtarı, bool == true
        let legacy = UserDefaults.standard.dictionaryRepresentation()
            .filter { $0.key.hasPrefix("fav_") && ($0.value as? Bool) == true }
            .map { String($0.key.dropFirst(4)) }

        return Set(stored).union(legacy)
    }
    /// Şu anda yüklü olan son sayfa
    private var currentPage: Int = 1
    /// Aynı anda iki kez istek atmayı engellemek için bayrak
    private var isLoading:  Bool = false
    /// Storyboard üzerinden bağlanan tablo görünümü (IBOutlet)
    /// Arama çubuğundaki metin
    private var searchText: String = ""
    @IBOutlet var MovieListTableView: UITableView!

    // MARK: - Yaşam Döngüsü
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigasyon çubuğu başlığı ve büyük başlık tercihi
        navigationItem.title = "Popular Movies"
        navigationController?.navigationBar.prefersLargeTitles = true

        // Arama çubuğu
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search movies"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // Sağ üstte favori filtresi düğmesi
        let favoritesButton = UIBarButtonItem(
            image: UIImage(systemName: "star"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorites)
        )
        navigationItem.rightBarButtonItem = favoritesButton
        updateFavoriteIcon()

        // Özel hücre sınıfını tabloya kaydet
        MovieListTableView.register(MovieTableViewCell.self,
                               forCellReuseIdentifier: MovieTableViewCell.reuseID)

        loadPage(page: 1)               // İlk sayfayı getir

        // Delegeler ve veri kaynağı
        MovieListTableView.dataSource = self
        MovieListTableView.delegate   = self

    }
    /// Belirtilen sayfayı indirir ve tabloyu günceller
    private func loadPage(page: Int) {  // yeni gelen sayfayı alta ekler
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
    
    override func viewWillAppear(_ animated: Bool) { // detaydan ana sayfaya tekrar döndüğünde listeyi günceller
        super.viewWillAppear(animated)
        updateMovies()
    }
    
    /// movies dizisini showFavoritesOnly, favoriteTitles ve arama metnine göre günceller
    private func updateMovies() {
        var list = allMovies

        // Favori filtresi
        if showFavoritesOnly {
            list = list.filter { favoriteTitles.contains($0.title) }
        }

        // Arama filtresi
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter { $0.title.lowercased().contains(q) }
        }

        // Favori filtresindeyken yinelenen başlıkları ayıkla
        if showFavoritesOnly {
            var seen = Set<String>()
            list = list.filter { movie in
                let inserted = seen.insert(movie.title).inserted
                return inserted
            }
        }

        movies = list
        MovieListTableView.reloadData()
    }
    // MARK: - Favori Filtresi
    /// Sağ üstteki yıldız düğmesine basıldığında çağrılır
    @objc private func toggleFavorites() {
        showFavoritesOnly.toggle()
        updateFavoriteIcon()
        updateMovies()
    }

    /// Yıldız ikonunu showFavoritesOnly durumuna göre günceller
    private func updateFavoriteIcon() {
        let symbolName = showFavoritesOnly ? "star.fill" : "star"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: symbolName)
    }
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        updateMovies()
    }
}
