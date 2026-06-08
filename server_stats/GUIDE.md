# 📘 macOS Server Performance Stats - Kişisel Geliştirici Kılavuzu

Bu dosya, `server-stats.sh` scriptini yazarken hangi mantığı kurduğumuzu, hangi Mac komutlarını neden seçtiğimizi ve karşılaştığımız sinsi hataları nasıl çözdüğümüzü adım adım hatırlamam için yazılmış **Türkçe rehberdir**.

---

## 🛠️ Fonksiyon Fonksiyon Kodun Anatomisi

### 1. `print_marquee()` (Görsel Düzenleyici)

- **Ne işe yarıyor?:** Rapordaki şık `=====` çizgilerini ve başlıkları basıyor.
- **Neden kullandık?:** Her fonksiyonun altına ve üstüne tek tek çizgi yazmak yerine, başlığı bu fonksiyona parametre (`$1`) olarak gönderip kod tekrarını önledik.

### 2. `get_cpu_usage()` (Toplam CPU Kullanımı)

- **Kullanılan Ana Komut:** `top -l 1 | grep "CPU usage"`
- **Neden Mac Farkı Var?:** Linux'taki `top -b` (batch mode) Mac'te çalışmaz. Mac'te anlık tek bir ekran görüntüsü (sample) almak için `-l 1` (loop 1) parametresini kullandık.
- **`awk` Sihri:** `top` komutundan gelen satır şöyledir: `CPU usage: 8.5% user, 2.0% sys, 89.5% idle`.
  `awk` ile boşluklara göre saydığımızda 3. kolon (`$3`) user, 5. kolon (`$5`) sys değeridir. Kodda bunları matematiksel olarak toplayıp (`$3 + $5`) toplam aktif CPU kullanımını bulduk.

### 3. `get_memory_usage()` (Toplam RAM İzleme - En Zor Kısım! 🤯)

- **Kullanılan Komutlar:** `sysctl hw.memsize` ve `vm_stat`
- **Neden Mac Farkı Var?:** Mac'te Linux'taki gibi `free -m` komutu yoktur. RAM bilgisini kernel'dan (çekirdekten) tırmıklamamız gerekti.
- **Adım Adım Mantık:**
  1. `sysctl hw.memsize` ile bilgisayarın toplam fiziksel RAM'ini **Byte** cinsinden aldık (Örn: 36 GB RAM için devasa bir sayı).
  2. Mac, boş RAM'i doğrudan söylemez; "Pages free" (Boş Sayfalar) olarak verir. `vm_stat` ile bu sayfa sayısını aldık, sonundaki inatçı noktayı `tr -d '.'` ile sildik.
  3. Mac mimarisinde 1 sayfa = **4096 Byte** demektir. Boş sayfa sayısını 4096 ile çarparak boş RAM'imizi Byte'a çevirdik.
  4. Toplam RAM'i Byte'tan Gigabayt'a (GB) çevirmek için normalde `(1024 * 1024 * 1024)` yapıyorduk ama `awk` parantezlerde syntax hatası verince, doğrudan bu çarpımın sonucu olan **`1073741824`** sayısına böldük.
  5. **Büyük Çözüm:** `awk` içinde yüzde hesaplarken parantez kullandığımızda Mac hata veriyordu. Parantezleri çöpe atıp formülü düz matematik düzlemine çektik: `free_percent = free_bytes * 100 / total`. Böylece hata çözüldü.

### 4. `get_disk_usage()` (Disk Alanı Analizi)

- **Kullanılan Ana Komut:** `df -h /`
- **Mantık:** `-h` parametresi (human-readable) sayesinde disk boyutları doğrudan `Gi` (Gigabyte) cinsinden gelir. `/` işareti ise sadece ana sistemi inceler.
- **`awk 'NR==2'` Sihri:** `df` komutu ilk satırda başlıkları basar. `awk 'NR==2'` (Number of Record == 2) diyerek ilk satırı çöpe attık, doğrudan verilerin olduğu 2. satıra odaklandık. Oradan da sırasıyla Boyut (`$2`), Kullanılan (`$3`), Boş (`$4`) ve Yüzde (`$5`) kolonlarını çektik.

### 5. `get_top_cpu_processes()` & `get_top_mem_processes()` (En Çok Tutan İlk 5 Süreç)

- **Kullanılan Ana Komut:** `ps -eo pid,%cpu,command` (veya `%mem`)
- **Mantık:** Sistemdeki tüm süreçlerin PID'sini, kaynak tüketimini ve hangi komutla çalıştıklarını listeler.
- **Mac'teki Sıralama Tuzağı (The Float Trap):** Mac'teki CPU değerleri `12.4`, `1.5` gibi ondalıklıdır. Düz `sort` komutu bunu alfabetik sıralar ve `9.0`'ı `12.0`'dan büyük sanır. Bunu engellemek için sayısal sıralama flag'i olan `-n` parametresini ekledik: **`sort -rnk 2`** (Tersine, Sayısal, 2. kolona göre sırala).
- **Neden `head -n 6`?:** En üstte `PID %CPU COMMAND` başlık satırı olduğu için, gerçek 5 süreci yakalamak adına listeyi en üstten 6 satır olacak şekilde kırptık.

### 6. `get_extra_stats()` (Stretch Goals - Ekstra İstatistikler)

- **Neler Kullandık?:** \* `sw_vers -productVersion`: Mac'in tam işletim sistemi sürümünü verir (Örn: `15.0`).
  - `uptime`: Bilgisayarın kaç gündür/saattir kesintisiz açık olduğunu ve yük ortalamasını söyler.
  - `users`: O an terminalde veya sistemde aktif olan kullanıcı adını basar.

---

## ⚠️ Unutmaman Gereken Altın Notlar (Troubleshooting)

1. **Yorum Satırı Tuzağı:** `awk 'BEGIN { ... }'` bloğunun içerisine sakın Türkçe karakter içeren `# yorum satırı` yazma. Mac'teki `awk` derleyicisi içerideki diyezleri ve Türkçe karakterleri yutamaz, alakasız yerlerde `syntax error` fırlatır. (RAM fonksiyonunda bunu yaşadık ve yorumları silerek çözdük).
2. **Kapatma Parantezleri:** Bir fonksiyon yazdıktan sonra fonksiyonun süslü parantezini (`}`) kapatmayı unutursan, Bash altındaki diğer fonksiyonları da onun içine almaya çalışır ve satır numaraları kayık hatalar verir.
3. **Çalıştırma İzni:** Yeni bir Mac'e geçtiğinde veya dosyayı sıfırdan oluşturduğunda `chmod +x server-stats.sh` komutunu çalıştırmazsan script kesinlikle başlamaz (`Permission Denied` hatası verir).

# 📘 macOS Server Performance Stats - Kişisel Geliştirici Kılavuzu

Bu dosya, `server-stats.sh` scriptini yazarken hangi mantığı kurduğumuzu, hangi Mac komutlarını neden seçtiğimizi ve karşılaştığımız sinsi hataları nasıl çözdüğümüzü adım adım hatırlamam için yazılmış **Türkçe rehberdir**.

---

## 🛠️ Fonksiyon Fonksiyon Kodun Anatomisi

### 1. `print_marquee()` (Görsel Düzenleyici)

- **Ne işe yarıyor?:** Rapordaki şık `=====` çizgilerini ve başlıkları basıyor.
- **Neden kullandık?:** Her fonksiyonun altına ve üstüne tek tek çizgi yazmak yerine, başlığı bu fonksiyona parametre (`$1`) olarak gönderip kod tekrarını önledik.

### 2. `get_cpu_usage()` (Toplam CPU Kullanımı)

- **Kullanılan Ana Komut:** `top -l 1 | grep "CPU usage"`
- **Neden Mac Farkı Var?:** Linux'taki `top -b` (batch mode) Mac'te çalışmaz. Mac'te anlık tek bir ekran görüntüsü (sample) almak için `-l 1` (loop 1) parametresini kullandık.
- **`awk` Sihri:** `top` komutundan gelen satır şöyledir: `CPU usage: 8.5% user, 2.0% sys, 89.5% idle`.
  `awk` ile boşluklara göre saydığımızda 3. kolon (`$3`) user, 5. kolon (`$5`) sys değeridir. Kodda bunları matematiksel olarak toplayıp (`$3 + $5`) toplam aktif CPU kullanımını bulduk.

### 3. `get_memory_usage()` (Toplam RAM İzleme)

- **Kullanılan Komutlar:** `sysctl hw.memsize` ve `vm_stat`
- **Neden Mac Farkı Var?:** Mac'te Linux'taki gibi `free -m` komutu yoktur. RAM bilgisini kernel'dan (çekirdekten) tırmıklamamız gerekti.
- **Adım Adım Mantık:**
  1. `sysctl hw.memsize` ile bilgisayarın toplam fiziksel RAM'ini **Byte** cinsinden aldık (Örn: 36 GB RAM için devasa bir sayı).
  2. Mac, boş RAM'i doğrudan söylemez; "Pages free" (Boş Sayfalar) olarak verir. `vm_stat` ile bu sayfa sayısını aldık, sonundaki inatçı noktayı `tr -d '.'` ile sildik.
  3. Mac mimarisinde 1 sayfa = **4096 Byte** demektir. Boş sayfa sayısını 4096 ile çarparak boş RAM'imizi Byte'a çevirdik.
  4. Toplam RAM'i Byte'tan Gigabayt'a (GB) çevirmek için normalde `(1024 * 1024 * 1024)` yapıyorduk ama `awk` parantezlerde syntax hatası verince, doğrudan bu çarpımın sonucu olan **`1073741824`** sayısına böldük.
  5. **Büyük Çözüm:** `awk` içinde yüzde hesaplarken parantez kullandığımızda Mac hata veriyordu. Parantezleri çöpe atıp formülü düz matematik düzlemine çektik: `free_percent = free_bytes * 100 / total`. Böylece hata çözüldü.

### 4. `get_disk_usage()` (Disk Alanı Analizi)

- **Kullanılan Ana Komut:** `df -h /`
- **Mantık:** `-h` parametresi (human-readable) sayesinde disk boyutları doğrudan `Gi` (Gigabyte) cinsinden gelir. `/` işareti ise sadece ana sistemi inceler.
- **`awk 'NR==2'` Sihri:** `df` komutu ilk satırda başlıkları basar. `awk 'NR==2'` (Number of Record == 2) diyerek ilk satırı çöpe attık, doğrudan verilerin olduğu 2. satıra odaklandık. Oradan da sırasıyla Boyut (`$2`), Kullanılan (`$3`), Boş (`$4`) ve Yüzde (`$5`) kolonlarını çektik.

### 5. `get_top_cpu_processes()` & `get_top_mem_processes()` (En Çok Tutan İlk 5 Süreç)

- **Kullanılan Ana Komut:** `ps -eo pid,%cpu,command` (veya `%mem`)
- **Mantık:** Sistemdeki tüm süreçlerin PID'sini, kaynak tüketimini ve hangi komutla çalıştıklarını listeler.
- **Mac'teki Sıralama Tuzağı (The Float Trap):** Mac'teki CPU değerleri `12.4`, `1.5` gibi ondalıklıdır. Düz `sort` komutu bunu alfabetik sıralar ve `9.0`'ı `12.0`'dan büyük sanır. Bunu engellemek için sayısal sıralama flag'i olan `-n` parametresini ekledik: **`sort -rnk 2`** (Tersine, Sayısal, 2. kolona göre sırala).
- **Neden `head -n 6`?:** En üstte `PID %CPU COMMAND` başlık satırı olduğu için, gerçek 5 süreci yakalamak adına listeyi en üstten 6 satır olacak şekilde kırptık.

### 6. `get_extra_stats()` (Stretch Goals - Ekstra İstatistikler)

- **Neler Kullandık?:** \* `sw_vers -productVersion`: Mac'in tam işletim sistemi sürümünü verir (Örn: `15.0`).
  - `uptime`: Bilgisayarın kaç gündür/saattir kesintisiz açık olduğunu ve yük ortalamasını söyler.
  - `users`: O an terminalde veya sistemde aktif olan kullanıcı adını basar.

---

## ⚠️ Unutmaman Gereken Altın Notlar (Troubleshooting)

1. **Yorum Satırı Tuzağı:** `awk 'BEGIN { ... }'` bloğunun içerisine sakın Türkçe karakter içeren `# yorum satırı` yazma. Mac'teki `awk` derleyicisi içerideki diyezleri ve Türkçe karakterleri yutamaz, alakasız yerlerde `syntax error` fırlatır. (RAM fonksiyonunda bunu yaşadık ve yorumları silerek çözdük).
2. **Kapatma Parantezleri:** Bir fonksiyon yazdıktan sonra fonksiyonun süslü parantezini (`}`) kapatmayı unutursan, Bash altındaki diğer fonksiyonları da onun içine almaya çalışır ve satır numaraları kayık hatalar verir.
3. **Çalıştırma İzni:** Yeni bir Mac'e geçtiğinde veya dosyayı sıfırdan oluşturduğunda `chmod +x server-stats.sh` komutunu çalıştırmazsan script kesinlikle başlamaz (`Permission Denied` hatası verir).
