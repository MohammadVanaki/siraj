import 'package:mawsueat/app/features/rulings/data/models/marja_model.dart';
import 'package:mawsueat/app/features/rulings/data/models/ruling_category_model.dart';
import 'package:mawsueat/app/features/rulings/data/models/ruling_model.dart';

abstract class RulingsRepository {
  /// دریافت لیست مراجع تقلید
  Future<List<MarjaModel>> getMaraji();

  /// دریافت لیست ابواب و دسته‌بندی‌های فقهی
  Future<List<RulingCategoryModel>> getCategories();

  /// جستجو و دریافت مسائل و استفتاءات
  Future<List<RulingModel>> getRulings({
    int? marjaId,
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  /// ارسال سوال یا استفتاء جدید
  Future<bool> submitQuestion({
    required int marjaId,
    required int categoryId,
    required String question,
    String? contactInfo,
  });

  /// تغییر وضعیت نشانه‌گذاری / علاقه‌مندی مسأله
  Future<bool> toggleBookmark(int rulingId);
}
