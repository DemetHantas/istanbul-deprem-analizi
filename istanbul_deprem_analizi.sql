-- istanbul deprem risk analizi ve güvenli bölge tespit sistemi
-- tüm sql kodları - başlangıçtan şimdiye kadar

-- 1. adım: veritabanı oluşturma
create database istanbul_deprem_analizi;
use istanbul_deprem_analizi;

-- kontrol - veritabanı oluştu mu?
select "veritabanı başarıyla oluşturuldu!" as mesaj;

-- 2. adım: ilçeler tablosu oluşturma
create table ilceler (
    ilce_id int primary key auto_increment,
    ilce_adi varchar(50) not null,
    nufus int,
    alan_km2 decimal(10,2),
    genel_risk_seviyesi enum('düşük', 'orta', 'yüksek')
);

-- ilçelere veri ekleme
insert into ilceler (ilce_adi, nufus, alan_km2, genel_risk_seviyesi) values
('Beşiktaş', 190000, 18.5, 'orta'),
('Kadıköy', 467000, 25.2, 'düşük'),
('Fatih', 368000, 15.6, 'yüksek'),
('Şişli', 273000, 4.2, 'yüksek'),
('Üsküdar', 545000, 35.4, 'orta');

-- test sorguları
select * from ilceler;
select ilce_adi, nufus from ilceler where genel_risk_seviyesi = 'yüksek';

-- 3. adım: mahalleler tablosu oluşturma (koordinatlarla)
-- önce varsa sil
drop table if exists mahalleler;

-- mahalleler tablosunu oluştur
create table mahalleler (
    mahalle_id int primary key auto_increment,
    ilce_id int,
    mahalle_adi varchar(100) not null,
    enlem decimal(10, 7) not null,
    boylam decimal(10, 7) not null,
    nufus int,
    risk_seviyesi enum('düşük', 'orta', 'yüksek'),
    zemin_tipi enum('kaya', 'sert toprak', 'yumuşak toprak', 'dolgu'),
    foreign key (ilce_id) references ilceler(ilce_id)
);

-- mahalleler tablosuna veri ekleme
insert into mahalleler (ilce_id, mahalle_adi, enlem, boylam, nufus, risk_seviyesi, zemin_tipi) values
-- Beşiktaş (ilce_id = 1)
(1, 'Levent', 41.0766, 29.0142, 15000, 'orta', 'sert toprak'),
(1, 'Etiler', 41.0812, 29.0276, 12000, 'düşük', 'kaya'),
(1, 'Ortaköy', 41.0553, 29.0268, 8000, 'yüksek', 'dolgu'),

-- Kadıköy (ilce_id = 2)  
(2, 'Moda', 40.9859, 29.0324, 18000, 'düşük', 'kaya'),
(2, 'Fenerbahçe', 40.9635, 29.0354, 22000, 'düşük', 'sert toprak'),
(2, 'Bostancı', 40.9447, 29.0943, 35000, 'orta', 'yumuşak toprak'),

-- Fatih (ilce_id = 3)
(3, 'Sultanahmet', 41.0058, 28.9784, 5000, 'yüksek', 'dolgu'),
(3, 'Eminönü', 41.0170, 28.9700, 8000, 'yüksek', 'dolgu'),
(3, 'Beyazıt', 41.0105, 28.9641, 12000, 'yüksek', 'yumuşak toprak');

-- 4. adım: hastaneler tablosu oluşturma
create table hastaneler (
    hastane_id int primary key auto_increment,
    hastane_adi varchar(100) not null,
    ilce_id int,
    enlem decimal(10, 7) not null,
    boylam decimal(10, 7) not null,
    yatak_kapasitesi int,
    tip enum('devlet', 'özel', 'üniversite'),
    acil_servisi boolean default true,
    deprem_dayaniklilik_puani int check (deprem_dayaniklilik_puani between 1 and 10),
    foreign key (ilce_id) references ilceler(ilce_id)
);

-- hastane verilerini ekleme
insert into hastaneler (hastane_adi, ilce_id, enlem, boylam, yatak_kapasitesi, tip, acil_servisi, deprem_dayaniklilik_puani) values
('Acıbadem Hastanesi Levent', 1, 41.0780, 29.0160, 300, 'özel', true, 8),
('Florence Nightingale Hastanesi', 1, 41.0720, 29.0180, 250, 'özel', true, 7),
('Kadıköy Şifa Hastanesi', 2, 40.9820, 29.0300, 150, 'özel', true, 6),
('Haydarpaşa Numune Hastanesi', 2, 40.9950, 29.0220, 400, 'devlet', true, 5),
('Fatih Sultan Mehmet Hastanesi', 3, 41.0100, 28.9700, 350, 'devlet', true, 4),
('İstanbul Üniversitesi Tıp Fakültesi', 3, 41.0080, 28.9650, 500, 'üniversite', true, 6),
('Şişli Hamidiye Etfal Hastanesi', 4, 41.0650, 28.9950, 280, 'devlet', true, 5);

-- 5. adım: güvenli toplanma alanları tablosu
create table guvenli_alanlar (
    alan_id int primary key auto_increment,
    alan_adi varchar(100) not null,
    ilce_id int,
    enlem decimal(10, 7) not null,
    boylam decimal(10, 7) not null,
    kapasite int,
    alan_tipi enum('park', 'meydan', 'stadyum', 'okul bahçesi', 'açık alan'),
    ulaşım_durumu enum('kolay', 'orta', 'zor'),
    foreign key (ilce_id) references ilceler(ilce_id)
);

-- güvenli alan verilerini ekleme
insert into guvenli_alanlar (alan_adi, ilce_id, enlem, boylam, kapasite, alan_tipi, ulaşım_durumu) values
('Maçka Parkı', 1, 41.0420, 29.0050, 5000, 'park', 'kolay'),
('Bebek Parkı', 1, 41.0830, 29.0430, 2000, 'park', 'orta'),
('Fenerbahçe Parkı', 2, 40.9620, 29.0370, 3000, 'park', 'kolay'),
('Moda Sahili', 2, 40.9850, 29.0350, 8000, 'açık alan', 'kolay'),
('Sultanahmet Meydanı', 3, 41.0060, 28.9760, 4000, 'meydan', 'kolay'),
('Gülhane Parkı', 3, 41.0130, 28.9820, 6000, 'park', 'kolay'),
('Taksim Meydanı', 1, 41.0370, 28.9850, 10000, 'meydan', 'kolay');

-- 6. adım: mesafe hesaplama fonksiyonu (haversine formülü)
delimiter //
create function mesafe_hesapla(
    enlem1 decimal(10,7), 
    boylam1 decimal(10,7), 
    enlem2 decimal(10,7), 
    boylam2 decimal(10,7)
) returns decimal(10,3)
reads sql data
deterministic
begin
    declare r decimal(10,3) default 6371; -- dünya yarıçapı km
    declare dlat decimal(10,7);
    declare dlon decimal(10,7);
    declare a decimal(10,7);
    declare c decimal(10,7);
    declare mesafe decimal(10,3);
    
    set dlat = radians(enlem2 - enlem1);
    set dlon = radians(boylam2 - boylam1);
    set a = sin(dlat/2) * sin(dlat/2) + cos(radians(enlem1)) * cos(radians(enlem2)) * sin(dlon/2) * sin(dlon/2);
    set c = 2 * atan2(sqrt(a), sqrt(1-a));
    set mesafe = r * c;
    
    return mesafe;
end//
delimiter ;

-- 7. adım: analiz sorguları

-- temel kontroller
select * from hastaneler;
select * from guvenli_alanlar;

-- her ilçede kaç hastane var?
select i.ilce_adi, count(h.hastane_id) as hastane_sayisi
from ilceler i
left join hastaneler h on i.ilce_id = h.ilce_id
group by i.ilce_id, i.ilce_adi
order by hastane_sayisi desc;

-- en yüksek kapasiteli güvenli alanlar
select ga.alan_adi, i.ilce_adi, ga.kapasite, ga.alan_tipi
from guvenli_alanlar ga
join ilceler i on ga.ilce_id = i.ilce_id
order by ga.kapasite desc
limit 5;

-- risk seviyesi yüksek mahallelere en yakın hastaneler
select 
    m.mahalle_adi,
    h.hastane_adi,
    mesafe_hesapla(m.enlem, m.boylam, h.enlem, h.boylam) as mesafe_km
from mahalleler m
cross join hastaneler h
where m.risk_seviyesi = 'yüksek'
order by m.mahalle_adi, mesafe_km
limit 15;

-- her mahalle için en yakın güvenli alan
select 
    m.mahalle_adi,
    ga.alan_adi,
    mesafe_hesapla(m.enlem, m.boylam, ga.enlem, ga.boylam) as mesafe_km,
    ga.kapasite
from mahalleler m
cross join guvenli_alanlar ga
where mesafe_hesapla(m.enlem, m.boylam, ga.enlem, ga.boylam) = (
    select min(mesafe_hesapla(m.enlem, m.boylam, ga2.enlem, ga2.boylam))
    from guvenli_alanlar ga2
)
order by m.mahalle_adi;

-- 8. adım: özet raporlar

-- ilçe bazında risk raporu
select 
    i.ilce_adi,
    i.nufus as toplam_nufus,
    i.genel_risk_seviyesi,
    count(distinct m.mahalle_id) as mahalle_sayisi,
    count(distinct h.hastane_id) as hastane_sayisi,
    count(distinct ga.alan_id) as guvenli_alan_sayisi,
    sum(ga.kapasite) as toplam_guvenli_kapasite
from ilceler i
left join mahalleler m on i.ilce_id = m.ilce_id
left join hastaneler h on i.ilce_id = h.ilce_id  
left join guvenli_alanlar ga on i.ilce_id = ga.ilce_id
group by i.ilce_id, i.ilce_adi, i.nufus, i.genel_risk_seviyesi
order by i.genel_risk_seviyesi desc, i.nufus desc;

-- hastane yeterlilik analizi
select 
    i.ilce_adi,
    sum(h.yatak_kapasitesi) as toplam_yatak,
    i.nufus,
    round((sum(h.yatak_kapasitesi) / i.nufus) * 1000, 2) as yatak_per_1000_kisi
from ilceler i
left join hastaneler h on i.ilce_id = h.ilce_id
group by i.ilce_id, i.ilce_adi, i.nufus
order by yatak_per_1000_kisi desc;

-- en kritik mahalleler (yüksek risk + yüksek nüfus + az hastane)
select 
    m.mahalle_adi,
    i.ilce_adi,
    m.nufus,
    m.risk_seviyesi,
    m.zemin_tipi,
    count(h.hastane_id) as yakin_hastane_sayisi
from mahalleler m
join ilceler i on m.ilce_id = i.ilce_id
left join hastaneler h on mesafe_hesapla(m.enlem, m.boylam, h.enlem, h.boylam) < 2
where m.risk_seviyesi = 'yüksek'
group by m.mahalle_id, m.mahalle_adi, i.ilce_adi, m.nufus, m.risk_seviyesi, m.zemin_tipi
having yakin_hastane_sayisi < 2
order by m.nufus desc;

-- 9. adım: view'lar (sanal tablolar) oluşturma

-- mahalle detay view
create view mahalle_detay as
select 
    m.mahalle_adi,
    i.ilce_adi,
    m.enlem,
    m.boylam,
    m.nufus,
    m.risk_seviyesi,
    m.zemin_tipi,
    count(distinct h.hastane_id) as yakin_hastane_sayisi,
    count(distinct ga.alan_id) as yakin_guvenli_alan_sayisi
from mahalleler m
join ilceler i on m.ilce_id = i.ilce_id
left join hastaneler h on mesafe_hesapla(m.enlem, m.boylam, h.enlem, h.boylam) < 3
left join guvenli_alanlar ga on mesafe_hesapla(m.enlem, m.boylam, ga.enlem, ga.boylam) < 2
group by m.mahalle_id, m.mahalle_adi, i.ilce_adi, m.enlem, m.boylam, m.nufus, m.risk_seviyesi, m.zemin_tipi;

-- view'ı kullanma
select * from mahalle_detay where risk_seviyesi = 'yüksek';

-- 10. adım: faydalı kontrol sorguları
show tables;
select count(*) as toplam_mahalle from mahalleler;
select count(*) as toplam_hastane from hastaneler;
select count(*) as toplam_guvenli_alan from guvenli_alanlar;

-- mesafe fonksiyonu test
select mesafe_hesapla(41.0766, 29.0142, 41.0780, 29.0160) as test_mesafe_km;


-- tabloların yapısını göster
describe ilceler;
describe mahalleler;

-- temel analiz sorguları
-- 1. tüm mahalleleri göster
select * from mahalleler;

-- 2. en kalabalık 5 mahalle
select mahalle_adi, nufus 
from mahalleler 
order by nufus desc 
limit 5;

-- 3. risk seviyesine göre mahalle sayısı
select risk_seviyesi, count(*) as mahalle_sayisi
from mahalleler 
group by risk_seviyesi;

-- 11. adım: join sorguları (tabloları birleştirme)
-- ilçe ve mahalle bilgilerini birleştir
select 
    i.ilce_adi,
    m.mahalle_adi, 
    m.nufus, 
    m.risk_seviyesi,
    m.zemin_tipi
from ilceler i
join mahalleler m on i.ilce_id = m.ilce_id
order by i.ilce_adi, m.nufus desc;

-- en riskli mahalleleri bul
select m.mahalle_adi, i.ilce_adi, m.risk_seviyesi, m.zemin_tipi
from mahalleler m
join ilceler i on m.ilce_id = i.ilce_id
where m.risk_seviyesi = 'yüksek'
order by m.nufus desc;

-- en tehlikeli kombinasyon: yüksek risk + dolgu zemin
select 
    i.ilce_adi,
    m.mahalle_adi,
    m.nufus,
    m.risk_seviyesi,
    m.zemin_tipi
from ilceler i
join mahalleler m on i.ilce_id = m.ilce_id
where m.risk_seviyesi = 'yüksek' and m.zemin_tipi = 'dolgu'
order by m.nufus desc;

-- 12. adım: faydalı kontrol sorguları
-- veritabanlarını listele
show databases;

-- aktif veritabanını öğren
select database() as aktif_veritabani;

-- ilçeler tablosunda kaç kayıt var?
select count(*) as ilce_sayisi from ilceler;

-- mahalleler tablosunda kaç kayıt var?
select count(*) as mahalle_sayisi from mahalleler;

-- ortalama nüfus
select avg(nufus) as ortalama_nufus from mahalleler;

-- en yüksek ve en düşük nüfus
select max(nufus) as en_yuksek_nufus, min(nufus) as en_dusuk_nufus from mahalleler;

-- zemin tipine göre risk dağılımı
select zemin_tipi, risk_seviyesi, count(*) as sayi
from mahalleler 
group by zemin_tipi, risk_seviyesi
order by zemin_tipi, risk_seviyesi;

-- 13. adım: temizlik komutları (gerekirse)
-- veritabanını sil (dikkatli kullan!)
-- drop database istanbul_deprem_analizi;

-- sadece tabloları sil
-- drop table mahalleler;
-- drop table ilceler;