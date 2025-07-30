# 🌍 İstanbul Deprem Risk Analizi ve Güvenli Bölge Tespit Sistemi

Bu proje, İstanbul'daki deprem risklerini analiz etmek ve güvenli bölgeleri tespit etmek için geliştirilmiş bir MySQL veritabanı sistemidir.

## 📋 Proje Özeti

- **Amaç:** İstanbul'daki mahalleler için deprem risk analizi
- **Teknoloji:** MySQL, SQL
- **Veri:** Gerçek İstanbul koordinatları ve demografik bilgiler
- **Çıktı:** Risk raporları, mesafe hesaplamaları, güvenli alan tespiti

## 🗄️ Veritabanı Yapısı

### Tablolar:
1. **ilceler** - İlçe bilgileri ve genel risk seviyeleri
2. **mahalleler** - Mahalle detayları, koordinatları ve zemin bilgileri  
3. **hastaneler** - Hastane lokasyonları ve kapasiteleri
4. **guvenli_alanlar** - Güvenli toplanma alanları ve kapasiteleri

### Özellikler:
- **Coğrafi hesaplamalar** (Haversine formülü ile mesafe)
- **Risk seviyesi analizi** (Düşük/Orta/Yüksek)
- **Zemin tipi analizi** (Kaya/Sert Toprak/Yumuşak Toprak/Dolgu)
- **Kapasite hesaplamaları**

## 🚀 Kurulum

1. MySQL'i bilgisayarınıza kurun
2. Bu repository'yi klonlayın
3. `database/complete_setup.sql` dosyasını MySQL'de çalıştırın

```sql
-- Veritabanını oluştur ve verileri yükle
source database/complete_setup.sql;
```

## 📊 Örnek Sorgular

### En Riskli Mahalleler
```sql
select mahalle_adi, risk_seviyesi, zemin_tipi, nufus 
from mahalleler 
where risk_seviyesi = 'yüksek' 
order by nufus desc;
```

### En Yakın Hastane Bulma
```sql
select m.mahalle_adi, h.hastane_adi, 
       mesafe_hesapla(m.enlem, m.boylam, h.enlem, h.boylam) as mesafe_km
from mahalleler m
cross join hastaneler h
where m.mahalle_adi = 'sultanahmet'
order by mesafe_km limit 3;
```

### İlçe Bazında Risk Raporu
```sql
select ilce_adi, genel_risk_seviyesi, nufus
from ilceler 
order by case 
    when genel_risk_seviyesi = 'yüksek' then 3
    when genel_risk_seviyesi = 'orta' then 2
    else 1 
end desc;
```

## 📈 Analiz Sonuçları

### Önemli Bulgular:
- **En riskli bölge:** Fatih ilçesi (Dolgu zemin + Yüksek risk)
- **En güvenli bölge:** Kadıköy ilçesi (Kaya zemin + Düşük risk)
- **Kritik eksiklik:** Sultanahmet'te yetersiz hastane kapasitesi

### Öneriler:
1. Dolgu zemin üzerindeki binaların güçlendirilmesi
2. Yüksek riskli bölgelerde hastane kapasitesinin artırılması
3. Güvenli toplanma alanlarının genişletilmesi

## 🛠️ Teknik Detaylar

**Kullanılan SQL Özellikleri:**
- FOREIGN KEY ilişkileri
- Haversine mesafe hesaplama fonksiyonu
- VIEW'lar (sanal tablolar)
- JOIN operasyonları
- Agregat fonksiyonlar (COUNT, SUM, AVG)
- Subquery'ler

**Koordinat Sistemi:** WGS84 (Latitude/Longitude)

## 📝 Dosya Yapısı

```
├── database/
│   ├── complete_setup.sql    # Tüm veritabanı kodu
│   ├── schema_only.sql       # Sadece tablo yapıları
│   └── sample_queries.sql    # Örnek analiz sorguları
├── docs/
│   └── README.md            # Bu dosya
└── reports/
    └── analysis_results.md   # Analiz sonuçları
```

## 🎯 Kullanım Alanları

- **Afet yönetimi** planlaması
- **Şehir planlama** çalışmaları  
- **Acil durum** rotası belirleme
- **Sigorta şirketleri** risk değerlendirmesi
- **Araştırma** ve akademik çalışmalar

---

**Not:** Bu projede kullanılan veriler örnek amaçlıdır. Gerçek afet planlaması için resmi kaynaklara başvurun.
