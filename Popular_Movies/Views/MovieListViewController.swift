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

import Combine
import CoreData
import SwiftUI

/// Filmler listesi ekranı (UIKit + SwiftUI entegrasyonu)
class MovieListViewController: UIViewController,
                               UITableViewDataSource,
                               UITableViewDelegate,
                               UISearchResultsUpdating,
                               MyDelegate
{
    func sendScore(movieID: Int, score: CGFloat) {
        movieScores[movieID] = score
        print("Score saved - Movie ID: \(movieID), Score: \(score)")
        
        // Tabloyu yenile (score'ları göster)
        DispatchQueue.main.async {
            self.MovieListTableView.reloadData()
        }
    }
    
    
    private var viewModel = MovieListViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    // Score'ları saklamak için - [MovieID: Score]
    private var movieScores: [Int: CGFloat] = [:]
    
    // CoreData context - SceneDelegate'den geçirilecek
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - CoreData Operations
    
    /// CoreData'dan tüm score'ları çekip movieScores dictionary'sine yükler
    private func loadScoresFromCoreData() {
        guard let context = managedObjectContext else { return }
        
        let request: NSFetchRequest<MovieScores> = MovieScores.fetchRequest()
        
        do {
            let savedScores = try context.fetch(request)
            // CoreData'daki skorları dictionary'ye aktar
            for scoreEntity in savedScores {
                movieScores[Int(scoreEntity.id)] = CGFloat(scoreEntity.score)
            }
            print("✅ Loaded \(savedScores.count) scores from CoreData")
        } catch {
            print("❌ Error loading scores from CoreData: \(error)")
        }
    }
    
    
    
    // MARK: - UITableViewDataSource
    /// Tabloda kaç satır olacağını döndürür → filmler dizisinin uzunluğu
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }

    /// Her satır için hücre oluşturur ve yapılandırır
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reuse mekanizması ile özel hücremizi alıyoruz
        let cell = tableView.dequeueReusableCell(
                      withIdentifier: MovieTableViewCell.reuseID,
                      for: indexPath) as! MovieTableViewCell
        // Hücreyi ilgili filmle yapılandır
        let movie = viewModel.movies[indexPath.row]
        let score = movieScores[movie.id] // Score'u al
        cell.configure(with: movie, score: score)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.movies.count - 1 {      // En alttaki hücre gözüktüğünde yeni sayfayı çağırır
            viewModel.loadPage(page: viewModel.currentPage + 1)
        }
    }

    // MARK: - UITableViewDelegate
    /// Bir satıra dokunulduğunda detay ekranına geçiş yapar
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Görsel geri bildirim
        let movie = viewModel.movies[indexPath.row]
        // SwiftUI ekranını UIKit içerisinde barındırıyoruz - Delegate ile
        let detailView = MovieDetailView(movie: movie, delegate: self)
        
        // SwiftUI view'a CoreData context'ini environment olarak geçir
        let detailVC: UIHostingController<AnyView>
        if let context = managedObjectContext {
            detailVC = UIHostingController(rootView: AnyView(detailView.environment(\.managedObjectContext, context)))
        } else {
            detailVC = UIHostingController(rootView: AnyView(detailView))
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: - Özellikler
    /// UserDefaults'ta saklanan favori film ID kümesi
    private var favoriteIDs: Set<Int> {
        // Yeni format: tek dizi altında Int ID'ler
        let stored = UserDefaults.standard.array(forKey: "favoriteIDs") as? [Int] ?? []
        return Set(stored)
    }
    /// Storyboard üzerinden bağlanan tablo görünümü (IBOutlet)
    /// Arama çubuğundaki metin
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

        viewModel.loadPage(page: 1)               // İlk sayfayı getir
        
        // CoreData'dan score'ları yükle
        loadScoresFromCoreData()

        // Delegeler ve veri kaynağı
        MovieListTableView.dataSource = self
        MovieListTableView.delegate   = self
        
        viewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.MovieListTableView.reloadData()
            }
            .store(in: &subscriptions)

    }
    
    override func viewWillAppear(_ animated: Bool) { // detaydan ana sayfaya tekrar döndüğünde listeyi günceller
        super.viewWillAppear(animated)
        viewModel.favoriteIDs = Set(UserDefaults.standard.array(forKey: "favoriteIDs") as? [Int] ?? [])
        viewModel.updateSearchResults(for: navigationItem.searchController!)
        
        // CoreData'dan score'ları yeniden yükle (detay ekranından döndüğünde)
        loadScoresFromCoreData()
        
        // Tabloyu güncelle
        DispatchQueue.main.async {
            self.MovieListTableView.reloadData()
        }
    }
    
    /// movies dizisini showFavoritesOnly, favoriteIDs ve arama metnine göre günceller
    
    @objc private func toggleFavorites() {
        viewModel.toggleFavorites()
        updateFavoriteIcon()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearchResults(for: searchController)
    }
    
    private func updateFavoriteIcon() {
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: viewModel.favoriteIconName)
    }
}
