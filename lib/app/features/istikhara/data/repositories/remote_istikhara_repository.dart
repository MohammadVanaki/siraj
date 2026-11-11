import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import 'package:mawsueat/app/features/istikhara/data/models/istikhara_model.dart';
import 'package:mawsueat/app/features/istikhara/data/repositories/istikhara_repository.dart';

class RemoteIstikharaRepository implements IstikharaRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  @override
  Future<IstikharaResultModel> performIstikhara() async {
    try {
      final response = await _apiClient.get(ApiConstants.istikharaResult);

      if (response['data'] != null) {
        return IstikharaResultModel.fromJson(response['data']);
      }
      return IstikharaResultModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب نتيجة الاستخارة من الخادم: $e');
    }
  }

  @override
  Future<IstikharaResultModel?> getIstikharaById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.istikharaEntries}/$id');

      if (response['data'] != null) {
        return IstikharaResultModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<String>> getIstikharaEtiquettes() async {
    try {
      final response = await _apiClient.get('/api/istikhara/etiquettes');
      final List list = response['data'] ?? response['etiquettes'] ?? [];
      if (list.isNotEmpty) {
        return list.map((e) => e.toString()).toList();
      }
      return _defaultEtiquettes;
    } catch (_) {
      return _defaultEtiquettes;
    }
  }

  @override
  Future<String> getIstikharaDuaa() async {
    try {
      final response = await _apiClient.get('/api/istikhara/duaa');
      final duaa = response['data']?['duaa'] ?? response['duaa'];
      if (duaa != null && duaa.toString().isNotEmpty) {
        return duaa.toString();
      }
      return _defaultDuaa;
    } catch (_) {
      return _defaultDuaa;
    }
  }

  static const List<String> _defaultEtiquettes = [
    'أن يكون على طهارة ووضوء تام.',
    'التوجه إلى القبلة الشريفة بخشوع.',
    'الصلاة على محمد وآل محمد ثلاث مرات.',
    'قراءة سورة الإخلاص ثلاث مرات.',
    'عقد النية الصادقة لله تعالى.',
  ];

  static const String _defaultDuaa =
      '«اللَّهُمَّ إِنِّي تَفَأَّلْتُ بِكِتَابِكَ، وَتَوَكَّلْتُ عَلَيْكَ، فَأَرِنِي مِنْ كِتَابِكَ مَا هُوَ مَكْتُومٌ مِنْ سِرِّكَ الْمَكْنُونِ فِي غَيْبِكَ، بِرَحْمَتِكَ يَا أَرْحَمَ الرَّاحِمِينَ»';
}

