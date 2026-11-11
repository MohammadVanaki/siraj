import 'package:mawsueat/app/features/istikhara/data/models/istikhara_model.dart';

abstract class IstikharaRepository {
  /// انجام استخاره و دریافت نتیجه تصادفی
  Future<IstikharaResultModel> performIstikhara();

  /// دریافت نتیجه استخاره بر اساس شناسه ورودی (در صورت نیاز)
  Future<IstikharaResultModel?> getIstikharaById(int id);

  /// دریافت آداب و شرایط استخاره
  Future<List<String>> getIstikharaEtiquettes();

  /// دریافت دعای مأثور استخاره
  Future<String> getIstikharaDuaa();
}

