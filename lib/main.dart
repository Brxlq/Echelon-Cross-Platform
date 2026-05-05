import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import '../models/models.dart';
import '../screens/screens.dart';
import 'constants.dart';
import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  final appCache = AppCache();
  final cachedThemeMode = await appCache.getThemeMode();
  final cachedColorSelection = await appCache.getColorSelection();
  final cachedTab = await appCache.getLastTab();
  final savedOrders = await OrderManager.loadSavedOrders();

  final initialThemeMode = cachedThemeMode == 'dark'
      ? ThemeMode.dark
      : ThemeMode.light;
  final safeColorIndex = cachedColorSelection.clamp(
    0,
    ColorSelection.values.length - 1,
  );
  final safeTab = cachedTab.clamp(0, EchelonTab.values.length - 1);

  runApp(
    EchelonApp(
      appCache: appCache,
      initialThemeMode: initialThemeMode,
      initialColorSelection: ColorSelection.values[safeColorIndex],
      initialTab: safeTab,
      initialOrders: savedOrders,
    ),
  );
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase is optional during local development until configured.
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class EchelonApp extends StatefulWidget {
  const EchelonApp({
    super.key,
    required this.appCache,
    required this.initialThemeMode,
    required this.initialColorSelection,
    required this.initialTab,
    required this.initialOrders,
  });

  final AppCache appCache;
  final ThemeMode initialThemeMode;
  final ColorSelection initialColorSelection;
  final int initialTab;
  final List<Order> initialOrders;

  @override
  State<EchelonApp> createState() => _EchelonAppState();
}

class _EchelonAppState extends State<EchelonApp> {
  late ThemeMode themeMode;
  late ColorSelection colorSelected;
  late int lastSelectedTab;
  late final OrderManager _orderManager;

  final YummyAuth _auth = YummyAuth();
  final CartManager _cartManager = CartManager();

  @override
  void initState() {
    super.initState();
    themeMode = widget.initialThemeMode;
    colorSelected = widget.initialColorSelection;
    lastSelectedTab = widget.initialTab;
    _orderManager = OrderManager(initialOrders: widget.initialOrders);
  }

  Restaurant? _findVehicleById(String? id) {
    if (id == null) {
      return null;
    }

    for (final restaurant in restaurants) {
      if (restaurant.id == id) {
        return restaurant;
      }
    }

    return null;
  }

  late final _router = GoRouter(
    initialLocation: '/${widget.initialTab}',
    redirect: _appRedirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(
          onLogIn: (Credentials credentials) async {
            try {
              await _auth.signIn(credentials.username, credentials.password);
            } on FirebaseAuthException catch (e) {
              throw Exception(_friendlyAuthError(e));
            }
            if (!context.mounted) return;
            context.go('/$lastSelectedTab');
          },
          onSignUp: (Credentials credentials) async {
            try {
              await _auth.signUp(credentials.username, credentials.password);
            } on FirebaseAuthException catch (e) {
              throw Exception(_friendlyAuthError(e));
            }
            if (!context.mounted) return;
            context.go('/$lastSelectedTab');
          },
        ),
      ),
      GoRoute(
        path: '/:tab',
        builder: (context, state) {
          return Home(
            auth: _auth,
            cartManager: _cartManager,
            ordersManager: _orderManager,
            changeTheme: changeThemeMode,
            changeColor: changeColor,
            colorSelected: colorSelected,
            onTabSelected: updateLastTab,
            tab: int.tryParse(state.pathParameters['tab'] ?? '') ?? 0,
          );
        },
        routes: [
          GoRoute(
            path: 'vehicle/:id',
            builder: (context, state) {
              final restaurant = _findVehicleById(state.pathParameters['id']);
              if (restaurant == null) {
                return const _VehicleNotFoundPage();
              }
              return RestaurantPage(
                restaurant: restaurant,
                cartManager: _cartManager,
                ordersManager: _orderManager,
              );
            },
          ),
          GoRoute(
            path: 'support-chat',
            builder: (context, state) => const SupportChatPage(),
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: const _VehicleNotFoundPage(),
    ),
  );

  Future<String?> _appRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final loggedIn = await _auth.loggedIn;
    final isOnLoginPage = state.matchedLocation == '/login';

    if (!loggedIn) {
      return '/login';
    } else if (loggedIn && isOnLoginPage) {
      return '/$lastSelectedTab';
    }

    return null;
  }

  Future<void> changeThemeMode(bool useLightMode) async {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
    await widget.appCache.cacheThemeMode(useLightMode ? 'light' : 'dark');
  }

  Future<void> changeColor(int value) async {
    if (value < 0 || value >= ColorSelection.values.length) {
      return;
    }
    setState(() {
      colorSelected = ColorSelection.values[value];
    });
    await widget.appCache.cacheColorSelection(value);
  }

  Future<void> updateLastTab(int tab) async {
    if (tab < 0 || tab >= EchelonTab.values.length) {
      return;
    }
    setState(() {
      lastSelectedTab = tab;
    });
    await widget.appCache.cacheLastTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Echelon',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      scrollBehavior: CustomScrollBehavior(),
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF3F7FB),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.dark,
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ),
      ),
    );
  }
}

String _friendlyAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-not-found':
      return 'No account found for this email.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'email-already-in-use':
      return 'This email is already registered.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'invalid-credential':
      return 'Email or password is invalid.';
    default:
      return e.message ?? 'Authentication failed. Please try again.';
  }
}

class _VehicleNotFoundPage extends StatelessWidget {
  const _VehicleNotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.no_crash_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'That vehicle is no longer available.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Return to Discover to choose another Echelon car.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/${EchelonTab.discover.value}'),
                child: const Text('Back to Discover'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
