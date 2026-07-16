# Design System — DoneLock Neo-Brutalist Theme

## Filosofi
Neo-Brutalism: perpaduan antara keberanian brutalism (bold, raw) dengan elemen modern yang *playful*. Ciri khasnya adalah penggunaan warna yang sangat cerah (vibrant), border hitam yang tebal, bayangan hitam padat (solid drop shadow) yang memiliki *offset*, dan sudut yang sedikit melengkung (rounded).

---

## Color Palette

### Primary & Monocrome
| Token | Color | Hex | Usage |
|-------|-------|-----|-------|
| `primary` | Hitam pekat | `#000000` | Text, border, shadow, header |
| `bg` | Off-white/Krem | `#F4F4F0` | Scaffold background utama |
| `surface` | Putih bersih | `#FFFFFF` | Background dari Cards/Containers |

### Vibrant Accents (Neo Colors)
| Token | Color | Hex | Usage |
|-------|-------|-----|-------|
| `neoYellow` | Kuning Terang | `#FFD073` | Highlight, badge, primary action |
| `neoPink` | Pink Permen | `#FF90E8` | Aksen sekunder, error / missed |
| `neoCyan` | Biru Muda/Teal| `#23A094` | Info, stat cards, chill mode |
| `neoPurple` | Ungu Cerah | `#90A8ED` | Elemen unik, variasi kartu |
| `neoGreen` | Hijau Terang | `#4ADE80` | Success, productive, go |
| `neoRed` | Merah Terang | `#EF4444` | Danger, stop |

---

## Typography

| Element | Font | Size | Weight | Letter Spacing |
|---------|------|------|--------|----------------|
| Display | Monospace | 32px | Bold | -1 |
| Heading 1 | Monospace | 24px | Bold | 0 |
| Heading 2 | Monospace | 20px | SemiBold | 0 |
| Body | Monospace | 14px | Regular | 0.5 |
| Caption | Monospace | 12px | Medium | 1 |
| Button | Monospace | 16px | Bold | 1 |

> **Catatan**: Tetap menggunakan `monospace` agar karakter raw dari aplikasi sebelumnya tetap terjaga, namun dipadukan dengan style yang lebih modern.

---

## Shape & Shadow (Neo-Brutalism Core)

Di Neo-Brutalism, komponen UI memiliki kedalaman fisik yang palsu (faux-3D) melalui penggunaan shadow solid.

| Token | Value | Usage |
|-------|-------|-------|
| `borderWidth` | 3px - 4px | Semua border (Cards, Buttons, Inputs) |
| `borderRadius`| 12px | Sudut kotak melengkung (playful) |
| `shadowOffset`| x: 4, y: 4 | Bayangan jatuh ke kanan bawah |
| `shadowColor` | `#000000` | Warna bayangan murni hitam, tanpa blur |

### Helper Component (UIUtils.neoBox)
Gunakan fungsi helper ini untuk membuat Container berdesain Neo-Brutalism:
```dart
static BoxDecoration neoBox({
  Color color = Colors.white,
  double borderRadius = 12,
  double borderWidth = 3,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: Colors.black, width: borderWidth),
    boxShadow: const [
      BoxShadow(
        color: Colors.black,
        offset: Offset(4, 4),
        blurRadius: 0,
      ),
    ],
  );
}
```

---

## Component Styles

### Button
Neo-brutalism button menggunakan `ElevatedButton` yang di-*styling* agar mirip dengan *neoBox*.
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white, // atau warna terang lainnya
    foregroundColor: Colors.black,
    elevation: 0, // Matikan default shadow Flutter
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Colors.black, width: 3),
    ),
  ),
  child: const Text("TOMBOL"),
)
```
*(Catatan: karena ElevatedButton Flutter menggunakan blur pada default elevation-nya, shadow hitam pekat bisa di-apply pada parent Container atau melalui custom widget jika dibutuhkan shadow pada tombol).*

### Input Field
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black, width: 3),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

---

## Catatan Tambahan
- Hindari penggunaan warna abu-abu gelap (dark grey) untuk elemen UI; gunakan hitam pekat untuk garis dan teks.
- Pastikan warna kontras sangat jelas (teks hitam di atas warna pastel/vibrant).
