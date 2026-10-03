import SwiftUI

struct ContentView: View {
    @State private var input = HealthInput()
    @State private var result: RiskLevel?

    private let predictor = try? RiskPredictor()

    var body: some View {
        NavigationStack {
            Form {
                Section("Değerlerin") {
                    ValueRow(title: "Yaş", unit: "yıl", value: $input.age, range: 21...81, step: 1)
                    ValueRow(title: "Glikoz", unit: "mg/dL", value: $input.glucose, range: 44...199, step: 1)
                    ValueRow(title: "Tansiyon (küçük)", unit: "mm Hg", value: $input.diastolic, range: 24...122, step: 1)
                    ValueRow(title: "Vücut kitle indeksi", unit: "kg/m²", value: $input.bmi, range: 18...67, step: 0.5)
                    ValueRow(title: "Gebelik sayısı", unit: "", value: $input.pregnancies, range: 0...17, step: 1)
                }

                Section {
                    Button("Riskimi hesapla") {
                        withAnimation { result = try? predictor?.predict(input) }
                    }
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                }

                if let result {
                    Section("Sonuç") {
                        ResultCard(level: result)
                    }
                }

                Section("Hakkında") {
                    Text("Pima veri setiyle (768 kişi) eğitilmiş bir Random Forest modeli. Tahmin tamamen telefonunda yapılır, veri hiçbir yere gönderilmez.")
                    Text("Bu bir öğrenci projesidir, tıbbi tavsiye değildir. Sağlığınla ilgili kararlar için doktoruna danış.")
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
            }
            .navigationTitle("Diyabet Riski")
            .onChange(of: input.age) { result = nil }
            .onChange(of: input.glucose) { result = nil }
            .onChange(of: input.diastolic) { result = nil }
            .onChange(of: input.bmi) { result = nil }
            .onChange(of: input.pregnancies) { result = nil }
        }
    }
}

// Bir değer satırı: başlık, değer ve slider.
struct ValueRow: View {
    let title: String
    let unit: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(step < 1 ? String(format: "%.1f %@", value, unit) : "\(Int(value)) \(unit)")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}

// Sonuç kartı: seviye, renk ve "10 kişiden X'i" görseli.
struct ResultCard: View {
    let level: RiskLevel

    var color: Color {
        switch level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(level.title)
                .font(.title2.bold())
                .foregroundStyle(color)

            HStack(spacing: 4) {
                ForEach(0..<10, id: \.self) { i in
                    Image(systemName: "person.fill")
                        .foregroundStyle(i < level.outOfTen ? color : Color.gray.opacity(0.3))
                }
            }
            .font(.title3)

            Text("Veri setinde senin gibi değerlere sahip 10 kişiden yaklaşık \(level.outOfTen)\(level.suffix) diyabet vardı.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ContentView()
}

// @State: değeri değişince ekran OTOMATİK yenilenir. Jupyter'da hücreyi tekrar çalıştırmak gibi, ama kendiliğinden.
// RiskLevel? → soru işareti "boş (nil) olabilir" demek. Henüz hesaplanmadıysa result boştur.
// try? RiskPredictor(): model yüklenemezse çökmek yerine nil döner.
// Form / Section: iOS Ayarlar uygulamasındaki gibi gruplu liste.
// range: 21...81 → slider'ın aralığı. Veri setindeki min ve max değerler. Model görmediği değerleri tahmin etmesin diye.
// $input.age: "$" işareti, slider'ın değeri hem okuyup hem değiştirebilmesi için bağlantı (Binding) oluşturur.
// withAnimation: sonuç kartı yumuşak bir animasyonla görünür.
// if let result: result boş değilse kartı göster.
// .onChange(of:): bir slider değişince eski sonucu sil. Kullanıcı eski sonucu yeni değerlerle karıştırmasın.
// ForEach(0..<10): 10 tane insan ikonu çizer. İlk outOfTen tanesi renkli, kalanı gri.
// #Preview: Xcode'da sağdaki önizleme ekranı.
// ÖZET: Slider'larla değerleri alan, butona basınca modeli çalıştıran ve sonucu renkli bir kartta "10 kişiden X'i" şeklinde gösteren ekranı yazdık.

