class ApiConstants {
  static const String baseUrl = 'https://albasha.org';
  static const String rawafid = '/api/rawafid';

  // Dijlah API Base URL
  static const String dijlahBaseUrl = 'https://alsiraj-api.dijlah.org';

  // Istikhara API (Dijlah)
  static const String istikharaBaseUrl = dijlahBaseUrl;
  static const String istikharaResult = '$dijlahBaseUrl/api/v1/istikhara/result';
  static const String istikharaEntries = '$dijlahBaseUrl/api/v1/istikhara/entries';

  // Library API (Dijlah)
  static const String libraryBaseUrl = 'https://library.dijlah.org/api/v1';
  static const String libraryBooks = '$libraryBaseUrl/books';
  static const String libraryDownloadBook = '$libraryBaseUrl/book/download/';
  static const String libraryApiKey = 'gwZE4PcVO4HuuNCYvlJxXN8mw4XHtWwy';
  static const Map<String, String> libraryHeaders = {
    'x-api-key': libraryApiKey,
  };

  // Encyclopedia API (Dijlah)
  static const String encyclopediaBooks = '$dijlahBaseUrl/api/v1/encyclopedia/books';
  static String encyclopediaBookEntries(int bookId) =>
      '$dijlahBaseUrl/api/v1/encyclopedia/books/$bookId/entries';
  static String encyclopediaEntryDetail(int entryId) =>
      '$dijlahBaseUrl/api/v1/encyclopedia/entries/$entryId';
  static const String encyclopediaSearch =
      '$dijlahBaseUrl/api/v1/encyclopedia/search';

  // Voices API (Dijlah)
  static const String voicesCategories = '$dijlahBaseUrl/api/v1/voices/categories';
  static const String voices = '$dijlahBaseUrl/api/v1/voices';
  static String voiceDetail(String id) => '$dijlahBaseUrl/api/v1/voices/$id';

  // Videos API (Dijlah)
  static const String videosCategories = '$dijlahBaseUrl/api/v1/videos/categories';
  static const String videos = '$dijlahBaseUrl/api/v1/videos';
  static String videoDetail(String id) => '$dijlahBaseUrl/api/v1/videos/$id';

  // Photo Albums API (Dijlah)
  static const String photoAlbumsCategories = '$dijlahBaseUrl/api/v1/photo-albums/categories';
  static const String photoAlbums = '$dijlahBaseUrl/api/v1/photo-albums';
  static String photoAlbumDetail(String albumId) => '$dijlahBaseUrl/api/v1/photo-albums/$albumId';

  // Remote Ziyarah API (Dijlah)
  static const String remoteZiyarahLocations = '$dijlahBaseUrl/api/v1/remote-ziyarah/locations';
  static String remoteZiyarahLocationDetail(String locationId) =>
      '$dijlahBaseUrl/api/v1/remote-ziyarah/locations/$locationId';
  static String remoteZiyarahReadings(String locationId) =>
      '$dijlahBaseUrl/api/v1/remote-ziyarah/locations/$locationId/readings';
  static String remoteZiyarahReadingDetail(String readingId) =>
      '$dijlahBaseUrl/api/v1/remote-ziyarah/readings/$readingId';
  static String remoteZiyarahDirection(String locationId) =>
      '$dijlahBaseUrl/api/v1/remote-ziyarah/locations/$locationId/direction';

  // Sahifa Sajjadiya API (Dijlah)
  static const String sahifaSajjadiya = '$dijlahBaseUrl/api/v1/sahifa-sajjadiya';
  static String sahifaSajjadiyaDetail(String id) =>
      '$dijlahBaseUrl/api/v1/sahifa-sajjadiya/$id';

  // Mafatih al-Jinan API (Dijlah)
  static const String mafatihAlJinan = '$dijlahBaseUrl/api/v1/mafatih-al-jinan';
  static String mafatihAlJinanDetail(String id) =>
      '$dijlahBaseUrl/api/v1/mafatih-al-jinan/$id';

  // Arbaeen Adhkar API (Dijlah)
  static const String arbaeenAdhkar = '$dijlahBaseUrl/api/v1/arbaeen/adhkar';

  // Nahj al-Balagha API (Dijlah)
  static const String nahjBaseUrl = '$dijlahBaseUrl/api/v1/nahj';
  static const String nahjCategories = '$nahjBaseUrl/categories';
  static const String nahjCommentators = '$nahjBaseUrl/commentators';
  static String nahjEntries({
    String? category,
    int page = 1,
    int limit = 20,
    String? q,
  }) {
    final params = <String>[];
    if (category != null && category.isNotEmpty) {
      params.add('category=$category');
    }
    params.add('page=$page');
    params.add('limit=$limit');
    if (q != null && q.trim().isNotEmpty) {
      params.add('q=${Uri.encodeComponent(q.trim())}');
    }
    return '$nahjBaseUrl/entries?${params.join('&')}';
  }

  static String nahjEntryDetail(String id) => '$nahjBaseUrl/entries/$id';

  static String nahjCommentaries({
    String? category,
    String? commentatorId,
    int page = 1,
    int limit = 20,
  }) {
    final params = <String>[];
    if (category != null && category.isNotEmpty) {
      params.add('category=$category');
    }
    if (commentatorId != null && commentatorId.isNotEmpty) {
      params.add('commentatorId=$commentatorId');
    }
    params.add('page=$page');
    params.add('limit=$limit');
    return '$nahjBaseUrl/commentaries?${params.join('&')}';
  }

  static String nahjCommentaryDetail(String id) =>
      '$nahjBaseUrl/commentaries/$id';

  // Quran API (Dijlah)
  static const String quranSurahs = '$dijlahBaseUrl/api/v1/quran/surahs';
  static String quranSurahDetail(int surahNumber) =>
      '$dijlahBaseUrl/api/v1/quran/surahs/$surahNumber';
  static String quranAyahDetail(int surahNumber, int ayahNumber) =>
      '$dijlahBaseUrl/api/v1/quran/surahs/$surahNumber/ayahs/$ayahNumber';
  static String quranPage(int pageNumber) =>
      '$dijlahBaseUrl/api/v1/quran/pages/$pageNumber';
  static String quranJuz(int juzNumber) =>
      '$dijlahBaseUrl/api/v1/quran/juzs/$juzNumber';

  // Quran Audio (Dijlah)
  static const String quranReciters = '$dijlahBaseUrl/api/v1/quran/reciters';
  static String quranAyahAudio(int surahNumber, int ayahNumber, String reciterId) =>
      '$dijlahBaseUrl/api/v1/quran/surahs/$surahNumber/ayahs/$ayahNumber/audio/$reciterId';

  // Quran Tafsir (Dijlah)
  static const String quranTafsirs = '$dijlahBaseUrl/api/v1/quran/tafsirs';
  static String quranAyahTafsir(int surahNumber, int ayahNumber, String tafsirId) =>
      '$dijlahBaseUrl/api/v1/quran/surahs/$surahNumber/ayahs/$ayahNumber/tafsir/$tafsirId';

  // Privacy Policy
  static const String privacyPolicyUrl = 'https://seraj.net/privacy_seraj.html';
}



