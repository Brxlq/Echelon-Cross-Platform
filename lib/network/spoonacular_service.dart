import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'model_response.dart';
import 'query_result.dart';
import 'service_interface.dart';
import 'spoonacular_model.dart';

class SpoonacularService implements RecipeServiceInterface {
  SpoonacularService({
    http.Client? client,
    String? apiKey,
    this.baseUrl = 'api.spoonacular.com',
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('SPOONACULAR_API_KEY'),
        _timeout = timeout ?? const Duration(seconds: 8);

  final http.Client _client;
  final String _apiKey;
  final String baseUrl;
  final Duration _timeout;

  @override
  Future<QueryResult<SpoonacularModelResponse>> searchRecipes(
    RecipeSearchRequest request,
  ) async {
    if (_apiKey.trim().isEmpty) {
      return const QueryResult.failure(
        QueryError(
          type: QueryErrorType.configuration,
          message: 'Missing Spoonacular API key.',
        ),
      );
    }

    final sanitizedQuery = request.query.trim();
    if (sanitizedQuery.isEmpty) {
      return const QueryResult.success(
        SpoonacularModelResponse(results: [], totalResults: 0),
      );
    }

    final uri = Uri.https(baseUrl, '/recipes/complexSearch', {
      'apiKey': _apiKey,
      'query': sanitizedQuery,
      'number': request.number.toString(),
      if (request.cuisine != null && request.cuisine!.isNotEmpty)
        'cuisine': request.cuisine!,
      if (request.diet != null && request.diet!.isNotEmpty) 'diet': request.diet!,
      if (request.addRecipeInformation) 'addRecipeInformation': 'true',
    });

    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return QueryResult.failure(
          QueryError(
            type: QueryErrorType.server,
            message: 'Spoonacular request failed (${response.statusCode}).',
            statusCode: response.statusCode,
          ),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const QueryResult.failure(
          QueryError(
            type: QueryErrorType.parsing,
            message: 'Unexpected response format.',
          ),
        );
      }

      final parsed = SpoonacularModelResponse.fromJson(decoded);
      return QueryResult.success(parsed);
    } on TimeoutException {
      return const QueryResult.failure(
        QueryError(
          type: QueryErrorType.network,
          message: 'Request timed out. Please try again.',
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
          message: 'Unable to parse Spoonacular response.',
        ),
      );
    } on http.ClientException {
      return const QueryResult.failure(
        QueryError(
          type: QueryErrorType.network,
          message: 'HTTP client error.',
        ),
      );
    } catch (_) {
      return const QueryResult.failure(
        QueryError(
          type: QueryErrorType.unknown,
          message: 'Unexpected error while fetching recipes.',
        ),
      );
    }
  }
}

