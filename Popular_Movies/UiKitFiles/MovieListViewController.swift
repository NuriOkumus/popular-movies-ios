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
class MovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
    /// Storyboard üzerinden bağlanan tablo görünümü (IBOutlet)
    @IBOutlet var MovieListTableView: UITableView!

    // MARK: - Yaşam Döngüsü
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigasyon çubuğu başlığı ve büyük başlık tercihi
        navigationItem.title = "Popular Movies"
        navigationController?.navigationBar.prefersLargeTitles = true

        // Özel hücre sınıfını tabloya kaydet
        MovieListTableView.register(MovieTableViewCell.self,
                               forCellReuseIdentifier: MovieTableViewCell.reuseID)

        // Asenkron olarak filmleri indir ve tabloyu yenile
        Task {
            movies = await getMovies()
            MovieListTableView.reloadData()
        }

        // Delegeler ve veri kaynağı
        MovieListTableView.dataSource = self
        MovieListTableView.delegate   = self

        // Otomatik layout kullandığımız için `addSubview` çağrısı gerekmeyebilir,
        // ancak storyboard’dan bağlanan outlet’i manuel olarak eklemek sorun
        // yaratmaz. Önemliyse kaldırılabilir.
        view.addSubview(MovieListTableView)
    }
}
