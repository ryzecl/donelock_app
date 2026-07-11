# Design System — DoneLock Brutalist Theme

## Filosofi
Brutalist design: bold, raw, functional. Tidak ada elemen dekoratif yang tidak perlu. Setiap elemen harus punya tujuan.

---

## Color Palette

### Primary
| Token | Color | Hex | Usage |
|-------|-------|-----|-------|
| `primary` | Hitam pekat | `#0D0D0D` | Text, border, header |
| `primaryLight` | Abu gelap | `#2B2B2B` | Card background, button |
| `accent` | Kuning DoneLock | `#FFCA16` | Tombol aksi, highlight, header |

### Background
| Token | Color | Hex | Usage |
|-------|-------|-----|-------|
| `bg` | Putih krem | `#F5F5F0` | Scaffold background |
| `surface` | Putih bersih | `#FFFFFF` | Card, container |
| `surfaceDark` | Hitam soft | `#1A1A1A` | Dark mode surface |

### Semantic
| Token | Color | Hex | Usage |
|-------|-------|-----|-------|
| `productive` | Hijau | `#22C55E` | Productive day, success |
| `notProductive` | Merah | `#EF4444` | Not productive, error |
| `neutral` | Abu-abu | `#9CA3AF` | No data, disabled |
| `warning` | Kuning | `#F59E0B` | Warning |

### Heatmap Scale
| Level | Color | Hex | Meaning |
|-------|-------|-----|---------|
| 0 | Abu muda | `#E5E7EB` | No journal |
| 1 | Hijau muda | `#BBF7D0` | Productive |
| 2 | Hijau sedang | `#4ADE80` | Productive streak |
| 3 | Hijau tua | `#16A34A` | Productive streak panjang |

> **Catatan**: Warna masih bisa didiskusikan. Palette di atas adalah saran awal.

---

## Typography

| Element | Font | Size | Weight | Letter Spacing |
|---------|------|------|--------|----------------|
| Display | Monospace | 32px | Bold | -1 |
| Heading 1 | Monospace | 24px | Bold | 0 |
| Heading 2 | Monospace | 20px | SemiBold | 0 |
| Body | Monospace | 14px | Regular | 0.5 |
| Caption | Monospace | 12px | Medium | 1 |
| Button | Monospace | 16px | Bold | 2 |

### Font Family
```dart
// Gunakan Google Fonts atau system monospace
fontFamily: 'JetBrains Mono' // atau 'Courier New', 'SF Mono'
```

---

## Spacing System

| Token | Size | Usage |
|-------|------|-------|
| `xs` | 4px | Icons, padding kecil |
| `sm` | 8px | Gap antar elemen |
| `md` | 16px | Padding card |
| `lg` | 24px | Padding section |
| `xl` | 32px | Margin antar section |
| `xxl` | 48px | Spasi halaman |

---

## Border & Shape

| Token | Value | Usage |
|-------|-------|-------|
| `borderWidth` | 2px | Semua border |
| `cardBorder` | 3px | Card, container |
| `buttonBorder` | 3px | Tombol |
| `borderRadius` | 0 (squared) | Brutalist: kotak tajam |
| `buttonRadius` | 0 | Tombol kotak |

> **Catatan**: Brutalist identity bisa menggunakan border 2-4px tebal dengan sudut siku-siku (radius = 0).

---

## Component Styles

### Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    side: const BorderSide(color: Colors.black, width: 3),
    shape: const RoundedRectangleBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  ),
  child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)),
)
```

### Card
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.black, width: 2),
  ),
  padding: const EdgeInsets.all(16),
)
```

### Input Field
```dart
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black, width: 2),
      borderRadius: BorderRadius.zero,
    ),
    labelStyle: const TextStyle(fontFamily: 'monospace'),
  ),
)
```

### Heatmap Cell
```dart
Container(
  width: 14,
  height: 14,
  decoration: BoxDecoration(
    color: color, // hijau/merah/abu sesuai data
    border: Border.all(color: Colors.black, width: 0.5),
  ),
)
```

### Bottom Navigation Bar

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.white,
  selectedItemColor: Colors.black,
  unselectedItemColor: Colors.grey.shade400,
  selectedLabelStyle: const TextStyle(
    fontFamily: 'monospace',
    fontWeight: FontWeight.bold,
    fontSize: 12,
  ),
  unselectedLabelStyle: const TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
  ),
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "HOME"),
    BottomNavigationBarItem(icon: Icon(Icons.edit_outlined), activeIcon: Icon(Icons.edit), label: "JOURNAL"),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: "CALENDAR"),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: "STATS"),
    BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: "PROFILE"),
  ],
)
```

Style:
- Warna putih, border hitam 2px di atas
- Text monospace, uppercase
- Icon filled untuk active, outlined untuk inactive
- Fixed type (tidak bergerak saat ada 5 item)

---

## Dark Mode (Optional)

Belum diimplementasikan. Jika ditambahkan:
- Gunakan `surfaceDark` sebagai background
- Gunakan teks putih pada background gelap
- Ikon dan border tetap terlihat jelas

---

## Catatan
- Design system ini masih bisa berkembang
- Utamakan konsistensi dibandingkan kreativitas
- Setiap komponen baru harus mengikuti pattern yang sudah ada
