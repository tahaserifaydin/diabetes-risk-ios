import CoreML

// Kullanıcının slider'larla girdiği değerler.
// Varsayılan değerler veri setindeki ortalama bir kişiye yakın.
struct HealthInput {
    var pregnancies: Double = 1
    var glucose: Double = 117
    var diastolic: Double = 72
    var bmi: Double = 32
    var age: Double = 29
}

// 3 risk seviyesi. Her seviyenin "10 kişiden kaçı" bilgisi
// notebook'taki Hücre 9'dan geliyor (0.12, 0.36, 0.70).
enum RiskLevel {
    case low, medium, high

    var title: String {
        switch self {
        case .low: return "Düşük risk"
        case .medium: return "Orta risk"
        case .high: return "Yüksek risk"
        }
    }

    var outOfTen: Int {
        switch self {
        case .low: return 1
        case .medium: return 4
        case .high: return 7
        }
    }

    
    var suffix: String {
        switch self {
        case .low: return "'inde"
        case .medium: return "'ünde"
        case .high: return "'sinde"
        }
    }
}


// Core ML modelini (DiabetesRF.mlmodel) çalıştıran yapı.
struct RiskPredictor {
    private let model: DiabetesRF

    init() throws {
        model = try DiabetesRF(configuration: MLModelConfiguration())
    }

    func predict(_ input: HealthInput) throws -> RiskLevel {
        let output = try model.prediction(
            pregnancies: input.pregnancies,
            glucose: input.glucose,
            diastolic: input.diastolic,
            bmi: input.bmi,
            age: input.age
        )
        let probability = output.classProbability[1] ?? 0

        switch probability {
        case ..<0.3: return .low
        case ..<0.6: return .medium
        default: return .high
        }
    }
}

// import CoreML: Apple'ın makine öğrenmesi kütüphanesi.
// struct: birkaç değeri bir arada tutan yapı. Python'daki basit bir class gibi düşünebilirsin.
// var ... : Double = 117 → değiştirilebilir, ondalıklı bir değişken ve başlangıç değeri.
// enum RiskLevel: sadece belirli seçenekleri olan bir tür. Burada sadece low, medium ve high olabilir.
// var title: String { switch self ... }: her seviye için ekranda görünecek yazı.
// DiabetesRF: Xcode, .mlmodel dosyasından bu sınıfı OTOMATİK üretir. Biz yazmadık, Xcode yazdı.
// init() throws: model yüklenirken hata çıkabilir. "throws" = "bu fonksiyon hata fırlatabilir" demek.
// try: hata fırlatabilen bir fonksiyonu çağırırken başına yazılır.
// model.prediction(...): modele 5 değeri verip tahmin ister. Python'daki rf.predict_proba gibi.
// output.classProbability[1]: sözlükten "1" (diyabet var) anahtarının olasılığını alır.
// ?? 0: değer yoksa 0 kullan. Swift'te "nil ise şunu kullan" demek.
// case ..<0.3: olasılık 0.3'ten küçükse → Düşük. Notebook'taki bins=[0, 0.3, 0.6, 1.0] ile aynı sınırlar.
// ÖZET: Modele 5 değeri verip diyabet olasılığını alıyoruz ve bunu notebook'ta seçtiğimiz sınırlarla Düşük/Orta/Yüksek seviyesine çeviriyoruz.

