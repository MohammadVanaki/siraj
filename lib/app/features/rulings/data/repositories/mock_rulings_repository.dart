import 'package:mawsueat/app/features/rulings/data/models/marja_model.dart';
import 'package:mawsueat/app/features/rulings/data/models/ruling_category_model.dart';
import 'package:mawsueat/app/features/rulings/data/models/ruling_model.dart';
import 'package:mawsueat/app/features/rulings/data/repositories/rulings_repository.dart';

class MockRulingsRepository implements RulingsRepository {
  final List<MarjaModel> _maraji = [
    MarjaModel(id: 0, name: 'جميع المراجع', title: 'فتاوى مجمعة'),
    MarjaModel(id: 1, name: 'السيد علي السيستاني', title: 'دام ظله الوارف'),
    MarjaModel(id: 2, name: 'السيد علي الخامنئي', title: 'دام ظله الوارف'),
    MarjaModel(id: 3, name: 'السيد محمد باقر الصدر', title: 'قدس سره الشريف'),
  ];

  final List<RulingCategoryModel> _categories = [
    RulingCategoryModel(id: 0, title: 'الكل', count: 8),
    RulingCategoryModel(id: 1, title: 'الصلاة', count: 2),
    RulingCategoryModel(id: 2, title: 'الصوم', count: 2),
    RulingCategoryModel(id: 3, title: 'الخمس والزكاة', count: 1),
    RulingCategoryModel(id: 4, title: 'المعاملات والتجارة', count: 2),
    RulingCategoryModel(id: 5, title: 'مسائل معاصرة', count: 1),
  ];

  final List<RulingModel> _allRulings = [
    RulingModel(
      id: 1,
      title: 'حكم الشك في عدد ركعات الصلاة الرباعية',
      question: 'إذا شك المصلي بين الركعة الثالثة والرابعة في صلاة الظهر أو العصر أو العشاء بعد السجدتين، فما هو حكم صلاته؟',
      answer: 'يبني على الرابعة ويتم صلاته، ثم يحتاط بعد التسليم بركعة واحدة من قيام أو ركعتين من جلوس، والأحوط استحباباً اختيار الركعة من قيام.',
      marjaId: 1,
      marjaName: 'السيد علي السيستاني',
      categoryId: 1,
      categoryTitle: 'الصلاة',
      rulingNumber: 'م-١٠٤',
      isFavorite: true,
    ),
    RulingModel(
      id: 2,
      title: 'استعمال بخاخ الربو ومفطرات الصوم',
      question: 'هل يبطل الصوم باستعمال البخاخ الطبي المخصص لمرضى الربو وضيق التنفس أثناء النهار؟',
      answer: 'إذا كان البخاخ يوصل الدواء إلى مجرى التنفس والرئة فقط على شكل غاز أو رذاذ خفيف ولا ينزل منه شيء معتنى به إلى المريء والمعدة فلا يضر بصحة الصوم.',
      marjaId: 1,
      marjaName: 'السيد علي السيستاني',
      categoryId: 2,
      categoryTitle: 'الصوم',
      rulingNumber: 'م-٢١٥',
      isFavorite: false,
    ),
    RulingModel(
      id: 3,
      title: 'التداول بالعملات الرقمية المشفرة',
      question: 'ما هو الموقف الشرعي من التداول وشراء وبيع العملات الرقمية الإلكترونية (البتكوين وما شابهها)؟',
      answer: 'يجب مراعاة القوانين والضوابط الرسمية في البلد، وفيما عدا ذلك إذا لم تكن مقترنة بما يخالف الشريعة وكانت ذات مالية عقلائية معتبرة فلا مانع منها في حد ذاتها.',
      marjaId: 2,
      marjaName: 'السيد علي الخامنئي',
      categoryId: 4,
      categoryTitle: 'المعاملات والتجارة',
      rulingNumber: 'م-٣٨٠',
      isFavorite: true,
    ),
    RulingModel(
      id: 4,
      title: 'حكم السفر بعد الزوال في شهر رمضان',
      question: 'إذا سافر الصائم بعد أذان الظهر (الزوال)، فهل يجوز له الإفطار في سفره؟ وما حكم صيامه؟',
      answer: 'إذا كان السفر بعد الزوال وجب عليه إتمام صيام ذلك اليوم وصيامه صحيح ومجزٍ ولا قضاء عليه.',
      marjaId: 2,
      marjaName: 'السيد علي الخامنئي',
      categoryId: 2,
      categoryTitle: 'الصوم',
      rulingNumber: 'م-١٩٢',
      isFavorite: false,
    ),
    RulingModel(
      id: 5,
      title: 'حساب رأس السنة الخمسية والمؤونة',
      question: 'كيف يحدد المكلف رأس سنته الخمسية؟ وهل يجب الخمس في الراتب المدخر قبل حلول رأس السنة؟',
      answer: 'رأس السنة الخمسية للموظف والأجير هو يوم شروعه في العمل أو قبض أول راتب، فما زاد عن مؤونة سنته وصرفه الشخصي حتى حلول ذلك اليوم وجب فيه الخمس بنسبة الخمس (٢٠٪).',
      marjaId: 1,
      marjaName: 'السيد علي السيستاني',
      categoryId: 3,
      categoryTitle: 'الخمس والزكاة',
      rulingNumber: 'م-٥٠١',
      isFavorite: false,
    ),
    RulingModel(
      id: 6,
      title: 'حكم الصلاة باللباس المشكوك في طهارته',
      question: 'إذا وجد المصلي بقعة على ثوبه بعد الفراغ من الصلاة واحتمل أنها نجاسة سابقة، فهل تبطل صلاته؟',
      answer: 'إذا كان جاهلاً بوجود النجاسة أصلاً أو شك في حدوثها قبل الصلاة أو بعدها، فصلاته محكومة بالصحة ولا تجب إعادتها.',
      marjaId: 3,
      marjaName: 'السيد محمد باقر الصدر',
      categoryId: 1,
      categoryTitle: 'الصلاة',
      rulingNumber: 'م-٨٨',
      isFavorite: false,
    ),
    RulingModel(
      id: 7,
      title: 'بيع العربون وفسخ العقد التجاري',
      question: 'ما حكم أخذ البائع للعربون إذا تراجع المشتري عن إتمام الصفقة دون مبرر شرعي؟',
      answer: 'إذا كان اشتراط الاحتفاظ بالعربون جزءاً من العقد المتفق عليه بين الطرفين كشرط جزائي فذلك نافذ وصحيح شرعاً.',
      marjaId: 1,
      marjaName: 'السيد علي السيستاني',
      categoryId: 4,
      categoryTitle: 'المعاملات والتجارة',
      rulingNumber: 'م-٤٤٠',
      isFavorite: false,
    ),
    RulingModel(
      id: 8,
      title: 'حكم عمليات التجميل الجراحية والوشم المؤقت',
      question: 'هل تجوز العمليات التجميلية أو عمل الوشم الذي لا يمنع وصول ماء الوضوء والغسل للبشرة؟',
      answer: 'العمليات التجميلية والوشم جائزان في حد ذاتهما إذا لم يترتب عليهما ضرر معتد به أو محرم آخر ولم يمنعا من وصول الماء إلى البشرة في الوضوء والغسل.',
      marjaId: 2,
      marjaName: 'السيد علي الخامنئي',
      categoryId: 5,
      categoryTitle: 'مسائل معاصرة',
      rulingNumber: 'م-٦١٢',
      isFavorite: false,
    ),
  ];

  @override
  Future<List<MarjaModel>> getMaraji() async {
    return _maraji;
  }

  @override
  Future<List<RulingCategoryModel>> getCategories() async {
    return _categories;
  }

  @override
  Future<List<RulingModel>> getRulings({
    int? marjaId,
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    var list = List<RulingModel>.from(_allRulings);

    if (marjaId != null && marjaId != 0) {
      list = list.where((item) => item.marjaId == marjaId).toList();
    }

    if (categoryId != null && categoryId != 0) {
      list = list.where((item) => item.categoryId == categoryId).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((item) {
        return item.title.toLowerCase().contains(q) ||
            item.question.toLowerCase().contains(q) ||
            item.answer.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Future<bool> submitQuestion({
    required int marjaId,
    required int categoryId,
    required String question,
    String? contactInfo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> toggleBookmark(int rulingId) async {
    final index = _allRulings.indexWhere((item) => item.id == rulingId);
    if (index != -1) {
      final current = _allRulings[index];
      _allRulings[index] = current.copyWith(isFavorite: !current.isFavorite);
      return _allRulings[index].isFavorite;
    }
    return false;
  }
}
