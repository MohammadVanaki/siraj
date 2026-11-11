import '../models/dua_media_item.dart';

abstract class DuasRepository {
  Future<List<DuaCategoryModel>> getVoiceCategories();
  Future<List<DuaAudioItem>> getVoices({String? categoryId});
  Future<DuaAudioItem?> getVoiceById(String id);

  Future<List<DuaCategoryModel>> getVideoCategories();
  Future<List<DuaVideoItem>> getVideos({String? categoryId});
  Future<DuaVideoItem?> getVideoById(String id);
}
