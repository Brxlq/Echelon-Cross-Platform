import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'query_result.dart';
import 'vehicle_catalog_model.dart';

class VehicleCatalogService {
  VehicleCatalogService({
    http.Client? client,
    this.baseUrl = 'www.carqueryapi.com',
    this.fallbackBaseUrl = 'vpic.nhtsa.dot.gov',
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 8);

  final http.Client _client;
  final String baseUrl;
  final String fallbackBaseUrl;
  final Duration _timeout;

  Future<QueryResult<VehicleCatalogResponse>> getMakes() async {
    final carQueryUri = Uri.http(baseUrl, '/api/0.3/', {
      'cmd': 'getMakes',
      'sold_in_us': '1',
    });
    final nhtsaUri = Uri.https(fallbackBaseUrl, '/api/vehicles/GetAllMakes', {
      'format': 'json',
    });

    try {
      final response = await _client.get(
        carQueryUri,
        headers: {'Accept': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return QueryResult.failure(
          QueryError(
            type: QueryErrorType.server,
            message: 'CarQuery request failed (${response.statusCode}).',
            statusCode: response.statusCode,
          ),
        );
      }

      final decoded = _decodeCarQueryBody(response.body);
      if (decoded is! Map<String, dynamic>) {
        return _tryNhtsaFallback(nhtsaUri);
      }

      return QueryResult.success(VehicleCatalogResponse.fromJson(decoded));
    } on http.ClientException {
      return _tryNhtsaFallback(nhtsaUri);
    } on TimeoutException {
      return _tryNhtsaFallback(nhtsaUri);
    } on SocketException {
      return _tryNhtsaFallback(nhtsaUri);
    } on FormatException {
      return _tryNhtsaFallback(nhtsaUri);
    } catch (_) {
      return _tryNhtsaFallback(nhtsaUri);
    }
  }

  Future<QueryResult<VehicleCatalogResponse>> _tryNhtsaFallback(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return QueryResult.failure(
          QueryError(
            type: QueryErrorType.server,
            message:
                'CarQuery failed and fallback request failed '
                '(${response.statusCode}).',
            statusCode: response.statusCode,
          ),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const QueryResult.failure(
          QueryError(
            type: QueryErrorType.parsing,
            message: 'Unable to parse fallback vehicle response.',
          ),
        );
      }

      return QueryResult.success(VehicleCatalogResponse.fromJson(decoded));
    } on TimeoutException {
      return const QueryResult.failure(
        QueryError(
          type: QueryErrorType.network,
          message: 'CarQuery and fallback requests timed out.',
        ),
      );
    } on SocketException {
      return const QueryResult.failure(
        QueryError(
          type: QueryErrorType.network,
          message: 'No internet connection.',
        ),
      );
    } on FormatException {
      return const QueryResult.failure(
        QueryError(
          type: QueryErrorType.parsing,
          message: 'Unable to parse fallback vehicle response.',
        ),
      );
    } on http.ClientException {
      return const QueryResult.failure(
        QueryError(
          type: QueryErrorType.network,
          message:
              'Browser blocked CarQuery/fallback requests (CORS or TLS issue).',
        ),
      );
    } catch (_) {
      return const QueryResult.failure(
        QueryError(
          type: QueryErrorType.unknown,
          message: 'Unable to load vehicle makes from available providers.',
        ),
      );
    }
  }

  Object _decodeCarQueryBody(String body) {
    final trimmed = body.trim();
    final firstBrace = trimmed.indexOf('{');
    final lastBrace = trimmed.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace > firstBrace) {
      final jsonSlice = trimmed.substring(firstBrace, lastBrace + 1);
      return jsonDecode(jsonSlice);
    }
    return jsonDecode(trimmed);
  }
}
