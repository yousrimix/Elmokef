const fs = require('fs');
const path = 'E:\\charika\\almawqef\\lib\\features\\client\\presentation\\screens\\map_screen.dart';
let c = fs.readFileSync(path, 'utf8');

c = c.replaceAll(
  "Text('${_mockArtisans.length} حرفي',",
  "Text('${_artisans.length} حرفي',"
);
c = c.replaceAll(
  "final a = _mockArtisans.firstWhere((a) => a.id == _selectedArtisanId);",
  "final a = _artisans.firstWhere((a) => a.id == _selectedArtisanId);"
);
c = c.replaceAll(
  "  final String price;",
  "  final String artisanId;"
);
c = c.replaceAll(
  "  const _ArtisanMarker(this.id, this.name, this.lat, this.lng, this.rating, this.profession, this.price, this.image);",
  "  const _ArtisanMarker(this.id, this.name, this.lat, this.lng, this.rating, this.profession, this.image, this.artisanId);"
);
c = c.replaceAll(
  "Text(a.price, style: const TextStyle(fontSize: 12",
  "Text('${a.rating.toInt()}+', style: const TextStyle(fontSize: 12"
);
c = c.replaceAll(
  "context.go('/artisan/art-uuid-00${a.id}')",
  "context.go('/artisan/${a.artisanId}')"
);
c = c.replaceAll(
  "if (a.id == 1)",
  "if (a.rating >= 4.8)"
);

fs.writeFileSync(path, c, 'utf8');
console.log('✅ Fixed');
