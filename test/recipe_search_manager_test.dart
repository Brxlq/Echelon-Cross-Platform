import 'package:flutter_test/flutter_test.dart';
import 'package:yummy/learn/recipes/recipe_search_history_stream.dart';
import 'package:yummy/learn/recipes/recipe_search_manager.dart';
import 'package:yummy/network/model_response.dart';
import 'package:yummy/network/query_result.dart';
import 'package:yummy/network/service_interface.dart';
import 'package:yummy/network/spoonacular_model.dart';

class _FakeRecipeServiceSuccess implements RecipeServiceInterface {
  @override
  Future<QueryResult<SpoonacularModelResponse>> searchRecipes(
    RecipeSearchRequest request,
  ) async {
    return const QueryResult.success(
      SpoonacularModelResponse(
        results: [
          SpoonacularRecipe(
            id: 1,
            title: 'Soup',
            imageUrl: 'https://example.com/soup.jpg',
          ),
        ],
        totalResults: 1,
      ),
    );
  }
}

class _FakeRecipeServiceFailure implements RecipeServiceInterface {
  @override
  Future<QueryResult<SpoonacularModelResponse>> searchRecipes(
    RecipeSearchRequest request,
  ) async {
    return const QueryResult.failure(
      QueryError(
        type: QueryErrorType.server,
        message: 'Server error',
        statusCode: 500,
      ),
    );
  }
}

void main() {
  test('idle -> loading -> success updates recipes and history', () async {
    final manager = RecipeSearchManager(
      service: _FakeRecipeServiceSuccess(),
      historyStream: RecipeSearchHistoryStream(),
    );

    final events = <bool>[];
    manager.addListener(() {
      events.add(manager.isLoading);
    });

    await manager.search('soup');

    expect(events.first, isTrue);
    expect(events.last, isFalse);
    expect(manager.recipes.length, 1);
    expect(manager.error, isNull);
    expect(manager.currentRecentQueries.first, 'soup');
    manager.dispose();
  });

  test('error and retry behavior notifies listeners', () async {
    final manager = RecipeSearchManager(
      service: _FakeRecipeServiceFailure(),
      historyStream: RecipeSearchHistoryStream(),
    );
    var notifications = 0;
    manager.addListener(() => notifications++);

    await manager.search('pizza');
    expect(manager.error, isNotNull);
    expect(manager.recipes, isEmpty);

    await manager.retry();
    expect(manager.error, isNotNull);
    expect(notifications, greaterThan(1));
    manager.dispose();
  });
}
