import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/mock_yummy_service.dart';
import '../components/components.dart';
import '../constants.dart';
import '../learn/recipes/recipe_search_history_stream.dart';
import '../learn/vehicle/vehicle_discovery_manager.dart';
import '../models/models.dart';
import '../network/vehicle_catalog_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({
    super.key,
    required this.cartManager,
    required this.orderManager,
  });

  final CartManager cartManager;
  final OrderManager orderManager;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  static const List<String> _categoryOrder = [
    economyClass,
    comfortClass,
    premiumClass,
    electricClass,
  ];

  final mockService = MockYummyService();
  final SearchController _searchController = SearchController();
  final TextEditingController _recipeQueryController = TextEditingController();
  late final Future<ExploreData> _exploreDataFuture;
  late final TabController _tabController;
  late final VehicleDiscoveryManager _vehicleDiscoveryManager;
  String searchQuery = '';
  String quickFilter = 'all';

  @override
  void initState() {
    super.initState();
    _exploreDataFuture = mockService.getExploreData();
    _tabController = TabController(length: _categoryOrder.length, vsync: this);
    _vehicleDiscoveryManager = VehicleDiscoveryManager(
      service: VehicleCatalogService(),
      historyStream: RecipeSearchHistoryStream(),
    );
    _vehicleDiscoveryManager.loadCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _recipeQueryController.dispose();
    _tabController.dispose();
    _vehicleDiscoveryManager.dispose();
    super.dispose();
  }

  bool _matchesQuery(Restaurant restaurant, String query) {
    if (query.trim().isEmpty) {
      return true;
    }

    final normalizedQuery = query.toLowerCase().trim();
    return restaurant.name.toLowerCase().contains(normalizedQuery) ||
        restaurant.address.toLowerCase().contains(normalizedQuery) ||
        restaurant.attributes.toLowerCase().contains(normalizedQuery) ||
        restaurant.vehicleClass.toLowerCase().contains(normalizedQuery);
  }

  bool _matchesQuickFilter(Restaurant restaurant) {
    switch (quickFilter) {
      case 'budget':
        return restaurant.hourlyRate <= 18;
      case 'topRated':
        return restaurant.rating >= 4.8;
      case 'nearby':
        return restaurant.distance <= 1.2;
      default:
        return true;
    }
  }

  List<Restaurant> _searchResults(
    List<Restaurant> allRestaurants,
    String query,
  ) {
    return allRestaurants
        .where((restaurant) => _matchesQuery(restaurant, query))
        .take(6)
        .toList();
  }

  void _selectCategory(String category) {
    final index = _categoryOrder.indexOf(category);
    if (index == -1) {
      return;
    }
    _tabController.animateTo(index);
  }

  void _openVehicleFromSearch(Restaurant restaurant) {
    _searchController.closeView(restaurant.name);
    setState(() {
      searchQuery = restaurant.name;
    });
    _selectCategory(restaurant.vehicleClass);
    context.go('/${EchelonTab.discover.value}/vehicle/${restaurant.id}');
  }

  Widget _buildSearchField(List<Restaurant> allRestaurants) {
    return SearchAnchor(
      searchController: _searchController,
      builder: (context, controller) {
        return SearchBar(
          controller: controller,
          hintText: 'Search cars, classes, or Astana hubs',
          leading: const Icon(Icons.search),
          trailing: [
            if (searchQuery.isNotEmpty)
              IconButton(
                onPressed: () {
                  controller.clear();
                  setState(() {
                    searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close),
              ),
          ],
          onTap: controller.openView,
          onChanged: (value) {
            if (!controller.isOpen) {
              controller.openView();
            }
            setState(() {
              searchQuery = value;
            });
          },
        );
      },
      suggestionsBuilder: (context, controller) {
        final matches = _searchResults(allRestaurants, controller.text);
        if (matches.isEmpty) {
          return [
            const ListTile(
              title: Text('No matching cars found'),
              subtitle: Text('Try a model name, class, or pickup hub.'),
            ),
          ];
        }

        return matches.map(
          (restaurant) => ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                restaurant.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(restaurant.name),
            subtitle: Text(
              '${restaurant.vehicleClass} | ${restaurant.address}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(restaurant.priceLabel),
            onTap: () => _openVehicleFromSearch(restaurant),
          ),
        );
      },
      viewOnChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      viewOnSubmitted: (value) {
        final matches = _searchResults(allRestaurants, value);
        setState(() {
          searchQuery = value;
        });
        if (matches.isNotEmpty) {
          _openVehicleFromSearch(matches.first);
        } else {
          _searchController.closeView(value);
        }
      },
    );
  }

  Widget _buildExploreBody(
    BuildContext context,
    List<Restaurant> allRestaurants,
    List<Post> posts,
  ) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            toolbarHeight: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: const FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: _DiscoverHero(),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                alignment: Alignment.centerLeft,
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: economyClass),
                    Tab(text: comfortClass),
                    Tab(text: premiumClass),
                    Tab(text: electricClass),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchField(allRestaurants),
                  const SizedBox(height: 14),
                  _QuickFilterRow(
                    selectedFilter: quickFilter,
                    onSelected: (value) {
                      setState(() {
                        quickFilter = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: _categoryOrder.map((category) {
          final restaurants = allRestaurants
              .where((restaurant) => restaurant.vehicleClass == category)
              .where((restaurant) => _matchesQuery(restaurant, searchQuery))
              .where(_matchesQuickFilter)
              .toList();

          return ListView(
            key: PageStorageKey<String>('fleet-$category'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              RestaurantSection(
                restaurants: restaurants,
                cartManager: widget.cartManager,
                orderManager: widget.orderManager,
                selectedCategory: category,
              ),
              const SizedBox(height: 20),
              PostSection(posts: posts),
              const SizedBox(height: 20),
              _FleetFinderSection(
                manager: _vehicleDiscoveryManager,
                queryController: _recipeQueryController,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _exploreDataFuture,
      builder: (context, AsyncSnapshot<ExploreData> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRestaurants = snapshot.data?.restaurants ?? [];
        final posts = snapshot.data?.friendPosts ?? [];

        return _buildExploreBody(context, allRestaurants, posts);
      },
    );
  }
}

class _FleetFinderSection extends StatelessWidget {
  const _FleetFinderSection({
    required this.manager,
    required this.queryController,
  });

  final VehicleDiscoveryManager manager;
  final TextEditingController queryController;

  Uri _sourceUriForMake(String makeName) {
    return Uri.https(
      'commons.wikimedia.org',
      '/w/index.php',
      {
        'title': 'Special:MediaSearch',
        'type': 'image',
        'search': '$makeName car',
      },
    );
  }

  Future<void> _openSourceLink(String makeName) async {
    final uri = _sourceUriForMake(makeName);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch source URL: $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: manager,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CarQuery API Assistant',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Search live vehicle makes via CarQuery to plan fleet '
                  'additions and member requests.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: queryController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: manager.search,
                  decoration: InputDecoration(
                    hintText: 'Try: Tesla, Toyota, BMW',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Search makes',
                      onPressed: manager.isLoading
                          ? null
                          : () => manager.search(queryController.text),
                      icon: const Icon(Icons.send),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<String>>(
                  stream: manager.recentQueries,
                  initialData: manager.currentRecentQueries,
                  builder: (context, snapshot) {
                    final recent = snapshot.data ?? const <String>[];
                    if (recent.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recent
                          .map(
                            (query) => ActionChip(
                              label: Text(query),
                              onPressed: () {
                                queryController.text = query;
                                manager.search(query);
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 12),
                if (manager.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (manager.error != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.error_outline),
                    title: Text(manager.error!.message),
                    trailing: IconButton(
                      tooltip: 'Retry',
                      onPressed: manager.retry,
                      icon: const Icon(Icons.refresh),
                    ),
                  )
                else if (manager.makes.isEmpty)
                  const Text('No matching makes. Try another vehicle brand.')
                else
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: manager.makes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final make = manager.makes[index];
                        return SizedBox(
                          width: 200,
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    make.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    0,
                                    10,
                                    10,
                                  ),
                                  child: Text(
                                    'Catalog ID: ${make.id}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    0,
                                    10,
                                    10,
                                  ),
                                  child: InkWell(
                                    onTap: () => _openSourceLink(make.name),
                                    child: Text(
                                      'Open source link',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DiscoverHero extends StatelessWidget {
  const _DiscoverHero();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1220), Color(0xFF123B72)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick a class, search in seconds, and unlock a car fast.',
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Echelon keeps every Astana-ready vehicle in one clean flow, '
            'from fleet browsing to booking and return planning.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const Spacer(),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(value: '3 min', label: 'average unlock time'),
              _MetricCard(value: '20', label: 'cars across the fleet'),
              _MetricCard(value: '24/7', label: 'support available'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _QuickFilterRow extends StatelessWidget {
  const _QuickFilterRow({
    required this.selectedFilter,
    required this.onSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilterChip(
          label: const Text('All cars'),
          selected: selectedFilter == 'all',
          onSelected: (_) => onSelected('all'),
        ),
        FilterChip(
          label: const Text('Budget picks'),
          selected: selectedFilter == 'budget',
          onSelected: (_) => onSelected('budget'),
        ),
        FilterChip(
          label: const Text('Top rated'),
          selected: selectedFilter == 'topRated',
          onSelected: (_) => onSelected('topRated'),
        ),
        FilterChip(
          label: const Text('Near center'),
          selected: selectedFilter == 'nearby',
          onSelected: (_) => onSelected('nearby'),
        ),
      ],
    );
  }
}
