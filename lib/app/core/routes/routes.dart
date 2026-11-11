import 'package:get/get.dart';
import 'package:mawsueat/app/features/about/view/screens/about_page.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/screens/favorite_page.dart';
import 'package:mawsueat/app/features/home/view/screens/home_dashboard_page.dart';
import 'package:mawsueat/app/features/home/view/screens/home_page.dart';
import 'package:mawsueat/app/features/occasions/view/screens/occasions_page.dart';
import 'package:mawsueat/app/features/qibla/view/screens/qibla_page.dart';
import 'package:mawsueat/app/features/search/view/screens/search_page.dart';
import 'package:mawsueat/app/features/setting/view/screens/setting_page.dart';
import 'package:mawsueat/app/features/splash/view/screens/splash_page.dart';

import 'package:mawsueat/app/features/prayer_times/view/screens/prayer_times_page.dart';
import 'package:mawsueat/app/features/misbaha/view/screens/misbaha_page.dart';
import 'package:mawsueat/app/features/chelleh/view/screens/chelleh_page.dart';
import 'package:mawsueat/app/features/chelleh/view/screens/create_chelleh_page.dart';
import 'package:mawsueat/app/features/chelleh/view/screens/track_chelleh_page.dart';
import 'package:mawsueat/app/features/istikhara/binding/istikhara_binding.dart';
import 'package:mawsueat/app/features/istikhara/view/screens/istikhara_page.dart';
import 'package:mawsueat/app/features/gallery/binding/gallery_binding.dart';
import 'package:mawsueat/app/features/gallery/view/screens/gallery_page.dart';
import 'package:mawsueat/app/features/rulings/binding/rulings_binding.dart';
import 'package:mawsueat/app/features/rulings/view/screens/rulings_page.dart';

import 'package:mawsueat/app/features/library/binding/library_binding.dart';
import 'package:mawsueat/app/features/library/view/screens/library_page.dart';
import 'package:mawsueat/app/features/quran/binding/quran_binding.dart';
import 'package:mawsueat/app/features/quran/view/screens/quran_page.dart';
import 'package:mawsueat/app/features/duas_and_ziyarat/binding/duas_binding.dart';
import 'package:mawsueat/app/features/duas_and_ziyarat/view/screens/duas_and_ziyarat_page.dart';
import 'package:mawsueat/app/features/sahifa_sajjadiyya/binding/sahifa_binding.dart';
import 'package:mawsueat/app/features/sahifa_sajjadiyya/view/screens/sahifa_page.dart';
import 'package:mawsueat/app/features/sahifa_sajjadiyya/view/screens/sahifa_reader_page.dart';
import 'package:mawsueat/app/features/mafatih_al_jinan/binding/mafatih_binding.dart';
import 'package:mawsueat/app/features/mafatih_al_jinan/view/screens/mafatih_page.dart';
import 'package:mawsueat/app/features/mafatih_al_jinan/view/screens/mafatih_reader_page.dart';
import 'package:mawsueat/app/features/nahj_al_balagha/binding/nahj_binding.dart';
import 'package:mawsueat/app/features/nahj_al_balagha/view/screens/nahj_page.dart';
import 'package:mawsueat/app/features/nahj_al_balagha/view/screens/nahj_reader_page.dart';

class Routes {
  static const String home = '/';
  static const String splash = '/splash';
  static const String mawsueat = '/mawsueat';
  static const String rawafid = '/rawafid';
  static const String news = '/news';
  static const String search = '/search';
  static const String setting = '/setting';
  static const String about = '/about';
  static const String favorites = '/favorites';
  static const String onBording = '/onBording';
  static const String subjectsPage = '/subjectsPage';
  static const String qibla = '/qibla';
  static const String occasions = '/occasions';
  static const String prayerTimes = '/prayerTimes';
  static const String misbaha = '/misbaha';
  static const String chelleh = '/chelleh';
  static const String chellehCreate = '/chelleh/create';
  static const String chellehTrack = '/chelleh/track';
  static const String istikhara = '/istikhara';
  static const String gallery = '/gallery';
  static const String rulings = '/rulings';
  static const String library = '/library';
  static const String quran = '/quran';
  static const String duasAndZiyarat = '/duasAndZiyarat';
  static const String sahifaSajjadiyya = '/sahifaSajjadiyya';
  static const String sahifaReader = '/sahifaReader';
  static const String mafatihAlJinan = '/mafatihAlJinan';
  static const String mafatihReader = '/mafatihReader';
  static const String nahj = '/nahj';
  static const String nahjReader = '/nahjReader';

  static final List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: home, page: () => HomeDashboardPage()),
    GetPage(name: mawsueat, page: () => HomePage()),
    GetPage(name: search, page: () => const SearchPage()),
    GetPage(name: setting, page: () => SettingPage(isDrawer: true)),
    GetPage(name: about, page: () => const AboutPage(isDrawer: true)),
    GetPage(name: favorites, page: () => FavoritePage(isDrawer: true)),
    GetPage(name: qibla, page: () => const QiblaPage()),
    GetPage(name: occasions, page: () => const OccasionsPage()),
    GetPage(name: prayerTimes, page: () => const PrayerTimesPage()),
    GetPage(name: misbaha, page: () => const MisbahaPage()),
    GetPage(name: chelleh, page: () => const ChellehPage()),
    GetPage(name: chellehCreate, page: () => const CreateChellehPage()),
    GetPage(name: chellehTrack, page: () => const TrackChellehPage()),
    GetPage(
      name: istikhara,
      page: () => const IstikharaPage(),
      binding: IstikharaBinding(),
    ),
    GetPage(
      name: gallery,
      page: () => const GalleryPage(),
      binding: GalleryBinding(),
    ),
    GetPage(
      name: rulings,
      page: () => const RulingsPage(),
      binding: RulingsBinding(),
    ),
    GetPage(
      name: library,
      page: () => const LibraryPage(),
      binding: LibraryBinding(),
    ),
    GetPage(
      name: quran,
      page: () => const QuranPage(),
      binding: QuranBinding(),
    ),
    GetPage(
      name: duasAndZiyarat,
      page: () => const DuasAndZiyaratPage(),
      binding: DuasBinding(),
    ),
    GetPage(
      name: sahifaSajjadiyya,
      page: () => const SahifaPage(),
      binding: SahifaBinding(),
    ),
    GetPage(
      name: sahifaReader,
      page: () => const SahifaReaderPage(),
      binding: SahifaBinding(),
    ),
    GetPage(
      name: mafatihAlJinan,
      page: () => const MafatihPage(),
      binding: MafatihBinding(),
    ),
    GetPage(
      name: mafatihReader,
      page: () => const MafatihReaderPage(),
      binding: MafatihBinding(),
    ),
    GetPage(
      name: nahj,
      page: () => const NahjPage(),
      binding: NahjBinding(),
    ),
    GetPage(
      name: nahjReader,
      page: () => const NahjReaderPage(),
      binding: NahjBinding(),
    ),
  ];
}


