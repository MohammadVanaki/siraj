import 'dart:math' as math;

class QiblaMathService {
  // إحداثيات الكعبة المشرفة في مكة المكرمة
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;

  /// حساب اتجاه القبلة (بالدرجات من 0 إلى 360 بالنسبة للشمال الحقيقي)
  static double calculateQiblaBearing(double userLat, double userLng) {
    return calculateTargetBearing(userLat, userLng, kaabaLatitude, kaabaLongitude);
  }

  /// حساب اتجاه أي هدف جغرافي (بالدرجات من 0 إلى 360 بالنسبة للشمال الحقيقي)
  static double calculateTargetBearing(
    double userLat,
    double userLng,
    double targetLat,
    double targetLng,
  ) {
    final double phi1 = _degreesToRadians(userLat);
    final double phi2 = _degreesToRadians(targetLat);
    final double deltaLambda = _degreesToRadians(targetLng - userLng);

    final double y = math.sin(deltaLambda) * math.cos(phi2);
    final double x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final double bearingRadians = math.atan2(y, x);
    final double bearingDegrees = _radiansToDegrees(bearingRadians);

    return (bearingDegrees + 360.0) % 360.0;
  }

  /// حساب المسافة بالكيلومترات إلى أي هدف جغرافي
  static double calculateTargetDistance(
    double userLat,
    double userLng,
    double targetLat,
    double targetLng,
  ) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(targetLat - userLat);
    final double dLng = _degreesToRadians(targetLng - userLng);

    final double lat1 = _degreesToRadians(userLat);
    final double lat2 = _degreesToRadians(targetLat);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// حساب المسافة بالكيلومترات إلى الكعبة المشرفة باستخدام معادلة هافرسين
  static double calculateDistanceToKaaba(double userLat, double userLng) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(kaabaLatitude - userLat);
    final double dLng = _degreesToRadians(kaabaLongitude - userLng);

    final double lat1 = _degreesToRadians(userLat);
    final double lat2 = _degreesToRadians(kaabaLatitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// حساب الفارق الزاوي بين اتجاه القبلة واتجاه الهاتف الحالي
  /// الناتج يتراوح بين -180 إلى +180:
  /// موجب (> 0): القبلة في اليمين (يجب تدوير الهاتف لليمين)
  /// سالب (< 0): القبلة في اليسار (يجب تدوير الهاتف لليسار)
  static double getAngleDifference(double qiblaBearing, double currentHeading) {
    double diff = (qiblaBearing - currentHeading) % 360.0;
    if (diff > 180.0) {
      diff -= 360.0;
    } else if (diff < -180.0) {
      diff += 360.0;
    }
    return diff;
  }

  /// تنعيم حركة زوايا البوصلة (Circular Low-pass filter) لمنع الاهتزاز المفاجئ
  static double smoothAngle(double currentSmoothed, double newAngle, {double factor = 0.2}) {
    double diff = (newAngle - currentSmoothed) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;

    double result = (currentSmoothed + diff * factor) % 360.0;
    if (result < 0) result += 360.0;
    return result;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  static double _radiansToDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }
}
