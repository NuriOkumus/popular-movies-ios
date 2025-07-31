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
import CoreData

struct MovieDetailView: View {
    @StateObject var viewModel: MovieDetailViewModel
    @State var rating : CGFloat = 0
    @Environment(\.managedObjectContext) private var viewContext
    weak var delegate : MyDelegate?
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \MovieScores.score, ascending: true)],
            animation: .default)
        private var Scores: FetchedResults<MovieScores>
    
    
    
    init(movie: MovieBrief, delegate: MyDelegate? = nil) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
        self.delegate = delegate
    }
    
    /// Mevcut rating'i CoreData'dan yükler
    private func loadExistingRating() {
        let request: NSFetchRequest<MovieScores> = MovieScores.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", viewModel.movie.id)
        
        do {
            let existingScores = try viewContext.fetch(request)
            if let existing = existingScores.first {
                rating = CGFloat(existing.score)
                print("📖 Loaded existing rating: \(rating) for movie ID: \(viewModel.movie.id)")
            }
        } catch {
            print("❌ Error loading existing rating: \(error)")
        }
    }
    
    private func addItem() {
        withAnimation {
            // Önce aynı film ID'si ile kayıt var mı kontrol et
            let request: NSFetchRequest<MovieScores> = MovieScores.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", viewModel.movie.id)
            
            do {
                let existingScores = try viewContext.fetch(request)
                
                let movieScore: MovieScores
                if let existing = existingScores.first {
                    // Mevcut kaydı güncelle
                    movieScore = existing
                    print("📝 Updating existing score for movie ID: \(viewModel.movie.id)")
                } else {
                    // Yeni kayıt oluştur
                    movieScore = MovieScores(context: viewContext)
                    movieScore.id = Int32(viewModel.movie.id)
                    print("✨ Creating new score for movie ID: \(viewModel.movie.id)")
                }
                
                movieScore.score = Double(rating)
                
                try viewContext.save()
                print("✅ Score saved: \(rating) for movie ID: \(viewModel.movie.id)")
                
            } catch {
                print("❌ Error saving score: \(error)")
            }
        }
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
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rate this movie:")
                        .font(.headline)
                    
                    HStack {
                        StarsView(rating: $rating, maxRating: 5)
                            .frame(height: 30)
                        
                        Text("\(rating, specifier: "%.1f")/5")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Save Rating") {
                            delegate?.sendScore(movieID: viewModel.movie.id, score: rating)
                            addItem()
                        }
                        .buttonStyle(GrowingButton())
                        .disabled(rating == 0)
                        
                    }
                }
                
                

                Spacer(minLength: 20)
            }
            .padding()
        }
        .onAppear {
            loadExistingRating()
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

protocol MyDelegate : AnyObject{
    func sendScore(movieID: Int, score: CGFloat)
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.3), value: configuration.isPressed)
    }
}


