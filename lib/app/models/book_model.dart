class BookModel {
  final int id;
  final String title;

  BookModel({
    required this.id,
    required this.title,
  });

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      title: map['title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }
}

class BookTextModel {
  final int id;
  final int bid;
  final int gid;
  final String title;
  final String text;
  final bool fav;

  BookTextModel({
    required this.id,
    required this.bid,
    required this.gid,
    required this.title,
    required this.text,
    this.fav = false,
  });

  factory BookTextModel.fromMap(Map<String, dynamic> map) {
    bool isFav = false;
    final favVal = map['fav'];
    if (favVal is bool) {
      isFav = favVal;
    } else if (favVal is int) {
      isFav = favVal == 1;
    } else if (favVal is String) {
      isFav = favVal == '1' || favVal.toLowerCase() == 'true';
    }

    return BookTextModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      bid: map['bid'] is int ? map['bid'] : int.tryParse(map['bid']?.toString() ?? '0') ?? 0,
      gid: map['gid'] is int ? map['gid'] : int.tryParse(map['gid']?.toString() ?? '0') ?? 0,
      title: map['title']?.toString() ?? '',
      text: map['_text']?.toString() ?? map['text']?.toString() ?? '',
      fav: isFav,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bid': bid,
      'gid': gid,
      'title': title,
      '_text': text,
      'fav': fav ? 1 : 0,
    };
  }
}
