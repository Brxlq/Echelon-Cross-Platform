class VehicleMake {
  const VehicleMake({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory VehicleMake.fromJson(Map<String, dynamic> json) {
    final idValue =
        json['id'] ??
        json['makeId'] ??
        json['Make_ID'] ??
        json['make_id'] ??
        0;
    final nameValue =
        json['name'] ??
        json['make'] ??
        json['makeName'] ??
        json['Make_Name'] ??
        json['make_display'];

    final resolvedName = (nameValue as String? ?? '').trim();
    final numericId = (idValue as num?)?.toInt();
    final resolvedId =
        numericId ??
        int.tryParse('$idValue') ??
        resolvedName.hashCode.abs();

    return VehicleMake(
      id: resolvedId,
      name: resolvedName,
    );
  }
}

class VehicleCatalogResponse {
  const VehicleCatalogResponse({
    required this.results,
    required this.totalResults,
  });

  final List<VehicleMake> results;
  final int totalResults;

  factory VehicleCatalogResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = _extractResults(json);
    final parsed = rawResults
        .whereType<Map>()
        .map((entry) => VehicleMake.fromJson(Map<String, dynamic>.from(entry)))
        .where((item) => item.name.trim().isNotEmpty)
        .toList();

    return VehicleCatalogResponse(
      results: parsed,
      totalResults:
          (json['Count'] as num?)?.toInt() ??
          (json['totalResults'] as num?)?.toInt() ??
          parsed.length,
    );
  }

  static List<dynamic> _extractResults(Map<String, dynamic> json) {
    final direct =
        json['Results'] ??
        json['results'] ??
        json['data'] ??
        json['Makes'];
    if (direct is List<dynamic>) {
      return direct;
    }

    if (direct is Map<String, dynamic>) {
      final nested = direct['results'] ?? direct['items'] ?? direct['makes'];
      if (nested is List<dynamic>) {
        return nested;
      }
    }

    for (final key in ['makes', 'items', 'vehicles']) {
      final value = json[key];
      if (value is List<dynamic>) {
        return value;
      }
    }

    return const [];
  }
}
