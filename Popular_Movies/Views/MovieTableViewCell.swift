//
//  MovieTableViewCell.swift
//  Popular_Movies
//
//  18.07.2025 tarihinde Nuri Okumuş tarafından oluşturuldu.
//
//  Bu özel UITableViewCell, popüler bir filmin afişini ve başlığını listede
//  göstermek üzere tasarlanmıştır. **Auto Layout** ile manuel kısıtlamalar
//  kurulur; Interface Builder kullanılmaz. Hücre düzeyindeki basit bir resim
//  önbelleği (NSCache) ile ağ istekleri en aza indirilir.
//
//────────────────────────────────────────────────────────────
// MARK: - Sınıf Tanımı  
//────────────────────────────────────────────────────────────

import UIKit
import Kingfisher
import Foundation

final class MovieTableViewCell: UITableViewCell {
    // MARK: - Static
    /// Tablo görünümünde hücre yeniden kullanımı için kimlik.
    static let reuseID = "MovieCell"

    // MARK: - UI Bileşenleri
    private let poster = UIImageView()
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()

    // MARK: - Yaşam Döngüsü
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI() // Arayüz elemanlarını yapılandır
    }

    /// Storyboard / XIB üzerinden kullanım desteklenmiyor.
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Arayüz Kurulumu
    private func setupUI() {
        // Görsel ayarları
        poster.contentMode = .scaleAspectFill
        poster.clipsToBounds = true
        poster.layer.cornerRadius = 4

        // Başlık etiketi
        titleLabel.numberOfLines = 2
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        
        // Score Etiketi
        
        scoreLabel.textColor = .systemGray
        scoreLabel.font = .systemFont(ofSize: 13, weight: .regular)
        scoreLabel.text =  "Score"		
        
        // Alt görünümleri ekle
        contentView.addSubview(poster)
        contentView.addSubview(titleLabel)
        contentView.addSubview(scoreLabel)
        poster.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        // Auto Layout kısıtlamaları
        NSLayoutConstraint.activate([
            // Afiş konumu ve boyutu
            poster.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            poster.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            poster.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            poster.widthAnchor.constraint(equalToConstant: 150),
            poster.heightAnchor.constraint(equalToConstant: 225),

            // Başlık konumu
            titleLabel.leadingAnchor.constraint(equalTo: poster.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            // Score konumu
            scoreLabel.leadingAnchor.constraint(equalTo: poster.trailingAnchor, constant: 12),
            scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])
    }

    // MARK: - Hücre Yapılandırması
    /// Hücreyi verilen `MovieBrief` modeli ile doldurur.
    func configure(with movie: MovieBrief, score: CGFloat? = 0) {
        titleLabel.text = movie.title
        
        // Score gösterimi
        if let score = score, score > 0 {
            let starEmoji = String(repeating: "⭐", count: Int(score))
            let emptyStars = String(repeating: "☆", count: max(0, 5 - Int(score)))
            let scorevalue = String(format: "%.1f", arguments: [score])
            scoreLabel.text = "\(starEmoji)\(emptyStars) (\(scorevalue))"
            scoreLabel.textColor = .systemOrange
        } else {
            scoreLabel.text = "☆☆☆☆☆ No rating yet"
            scoreLabel.textColor = .systemGray
        }
        // Favori durumu: UserDefaults'tan oku 
        let favIDs = UserDefaults.standard.array(forKey: "favoriteIDs") as? [Int] ?? []
        let isFav  = favIDs.contains(movie.id)

        // Yıldız sembolü ve görünümü
        let symbolName = isFav ? "star.fill" : "star"
        let starImage  = UIImage(systemName: symbolName)
        let starView   = UIImageView(image: starImage)
        starView.tintColor = isFav ? UIColor.systemYellow : UIColor.systemGray
        starView.contentMode = .scaleAspectFit

        // Hücrenin sağ tarafına (accessory view) ata
        accessoryView = starView
        poster.image = UIImage(systemName: "film") // Placeholder

        if let url = movie.posterURL500 {
            poster.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "film"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ])
        }
    }
}
