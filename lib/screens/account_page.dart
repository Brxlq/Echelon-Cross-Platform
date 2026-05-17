import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../account/account_profile_repository.dart';
import '../favourites/favourites.dart';
import '../models/models.dart';

typedef LogoutCallback = void Function(bool didLogout);

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
    required this.onLogOut,
    required this.onOpenSupportChat,
    required this.onOpenFavouriteVehicle,
    this.favouriteVehicles = const [],
    this.favouriteError,
    required this.user,
  });

  final User user;
  final LogoutCallback onLogOut;
  final VoidCallback onOpenSupportChat;
  final ValueChanged<String> onOpenFavouriteVehicle;
  final List<FavouriteVehicle> favouriteVehicles;
  final String? favouriteError;

  static const supportTileKey = Key('account_support_tile');
  static const logoutTileKey = Key('account_logout_tile');
  static const favouritesSectionKey = Key('account_favourites_section');

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  static const List<String> _avatarChoices = [
    'assets/profile_pics/person_cesare.jpeg',
    'assets/profile_pics/person_stef.jpeg',
    'assets/profile_pics/person_crispy.png',
    'assets/profile_pics/person_joe.jpeg',
    'assets/profile_pics/person_katz.jpeg',
    'assets/profile_pics/person_kevin.jpeg',
    'assets/profile_pics/person_sandra.jpeg',
  ];

  final AccountProfileRepository _profileRepository =
      AccountProfileRepository();
  final BillingRepository _billingRepository = BillingRepository();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedAvatar;
  Uint8List? _selectedAvatarBytes;

  @override
  void initState() {
    super.initState();
    _loadProfileState();
  }

  Future<void> _loadProfileState() async {
    final avatar = await _profileRepository.loadAvatar();
    if (!mounted) return;
    setState(() {
      _selectedAvatar = avatar.cloudUrl;
      _selectedAvatarBytes = avatar.localBytes;
    });
  }

  Future<void> _changeAvatar(String avatarPath) async {
    setState(() {
      _selectedAvatar = avatarPath;
      _selectedAvatarBytes = null;
    });
    await _profileRepository.saveAvatarPath(avatarPath);
  }

  Future<void> _pickAvatarFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    setState(() {
      _selectedAvatarBytes = bytes;
      _selectedAvatar = null;
    });

    await _profileRepository.saveAvatarBytes(bytes);
    await _loadProfileState();
  }

  Future<void> _openBillingPage() async {
    final initialState = await _billingRepository.loadBilling();
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _BillingPage(
          initialState: initialState,
          repository: _billingRepository,
        ),
      ),
    );
  }

  ImageProvider<Object> _profileImage(String imagePath) {
    if (_selectedAvatarBytes != null) {
      return MemoryImage(_selectedAvatarBytes!);
    }
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }
    return AssetImage(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildProfile(),
          const SizedBox(height: 20),
          buildMembershipCard(),
          const SizedBox(height: 20),
          buildFavouritesSection(),
          const SizedBox(height: 20),
          buildMenu(),
        ],
      ),
    );
  }

  Widget buildMembershipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1220), Color(0xFF1A4F8C)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Echelon Plus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Priority access to performance vehicles, lower hourly '
            'rates, and free extra-driver coverage.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.82)),
          ),
        ],
      ),
    );
  }

  Widget buildMenu() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.credit_card_outlined),
          title: const Text('Billing and passes'),
          subtitle: const Text('Manage payment methods and trip credits'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _openBillingPage,
        ),
        ListTile(
          key: AccountPage.supportTileKey,
          leading: const Icon(Icons.support_agent),
          title: const Text('Support'),
          subtitle: const Text('Roadside help, damage reporting, and FAQs'),
          onTap: widget.onOpenSupportChat,
        ),
        ListTile(
          key: AccountPage.logoutTileKey,
          leading: const Icon(Icons.logout),
          title: const Text('Log out'),
          onTap: () {
            widget.onLogOut(true);
          },
        ),
      ],
    );
  }

  Widget buildFavouritesSection() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      key: AccountPage.favouritesSectionKey,
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Favourite vehicles',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.favouriteError != null)
              Text(
                widget.favouriteError!,
                style: TextStyle(color: colorScheme.error),
              )
            else if (widget.favouriteVehicles.isEmpty)
              const Text('No favourite vehicles yet.')
            else
              ...widget.favouriteVehicles.map(
                (vehicle) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      vehicle.vehicleImageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return ColoredBox(
                          color: colorScheme.surfaceContainerHighest,
                          child: const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.directions_car),
                          ),
                        );
                      },
                    ),
                  ),
                  title: Text(vehicle.vehicleName),
                  subtitle: Text(
                    '${vehicle.vehicleClass} | '
                    '\$${vehicle.hourlyRate.toStringAsFixed(0)}/hr',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    widget.onOpenFavouriteVehicle(vehicle.vehicleId);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildProfile() {
    final avatarPath = _selectedAvatar ?? widget.user.profileImageUrl;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: _profileImage(avatarPath),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: FilledButton.tonalIcon(
                onPressed: () => _showAvatarPicker(),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Avatar'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${widget.user.firstName} ${widget.user.lastName}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        Text(widget.user.role),
        Text('${widget.user.points} member points'),
      ],
    );
  }

  Future<void> _showAvatarPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose profile photo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.upload_outlined),
                title: const Text('Upload from gallery'),
                subtitle: const Text('Pick your own image'),
                onTap: () async {
                  await _pickAvatarFromGallery();
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Or choose a quick preset',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatarChoices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final avatar = _avatarChoices[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () async {
                        await _changeAvatar(avatar);
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        radius: 38,
                        backgroundImage: _profileImage(avatar),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BillingPage extends StatefulWidget {
  const _BillingPage({
    required this.initialState,
    required this.repository,
  });

  final BillingState initialState;
  final BillingRepository repository;

  @override
  State<_BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<_BillingPage> {
  late double _credits;
  late List<String> _paymentMethods;
  final TextEditingController _methodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _credits = widget.initialState.credits;
    _paymentMethods = List<String>.from(widget.initialState.paymentMethods);
  }

  @override
  void dispose() {
    _methodController.dispose();
    super.dispose();
  }

  Future<void> _persist() async {
    await widget.repository.saveBilling(
      BillingState(credits: _credits, paymentMethods: _paymentMethods),
    );
  }

  Future<void> _addMethod() async {
    final raw = _methodController.text.trim();
    if (raw.length < 4) return;
    final tail = raw.substring(raw.length - 4);
    setState(() {
      _paymentMethods.add('Card **** $tail');
      _methodController.clear();
    });
    await _persist();
  }

  Future<void> _addCredits(double amount) async {
    setState(() {
      _credits += amount;
    });
    await _persist();
  }

  Future<void> _removeMethod(int index) async {
    setState(() {
      _paymentMethods.removeAt(index);
    });
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing and passes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip credits',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_credits.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: () => _addCredits(10),
                        child: const Text('+ \$10'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => _addCredits(25),
                        child: const Text('+ \$25'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => _addCredits(50),
                        child: const Text('+ \$50'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment methods',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _methodController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter card number',
                      suffixIcon: IconButton(
                        onPressed: _addMethod,
                        icon: const Icon(Icons.add_card_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_paymentMethods.isEmpty)
                    const Text('No payment methods yet.')
                  else
                    ..._paymentMethods.asMap().entries.map(
                          (entry) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.credit_card),
                            title: Text(entry.value),
                            trailing: IconButton(
                              onPressed: () => _removeMethod(entry.key),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
