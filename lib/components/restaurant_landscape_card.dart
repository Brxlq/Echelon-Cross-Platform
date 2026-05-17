import 'package:flutter/material.dart';

import '../models/models.dart';

class RestaurantLandscapeCard extends StatefulWidget {
  const RestaurantLandscapeCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.isFavourite = false,
    this.onFavouriteToggle,
  });

  final Restaurant restaurant;
  final Function() onTap;
  final bool isFavourite;
  final Future<void> Function()? onFavouriteToggle;

  @override
  State<RestaurantLandscapeCard> createState() =>
      _RestaurantLandscapeCardState();
}

class _RestaurantLandscapeCardState extends State<RestaurantLandscapeCard> {
  String get _heroTag => 'vehicle-image-${widget.restaurant.id}';
  bool _favouritePressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: _heroTag,
                    child: Image.network(
                      widget.restaurant.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return ColoredBox(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.directions_car, size: 48),
                          ),
                        );
                      },
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xAA08111E)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.92),
                      child: GestureDetector(
                        onTapDown: (_) {
                          if (widget.onFavouriteToggle != null) {
                            setState(() {
                              _favouritePressed = true;
                            });
                          }
                        },
                        onTapUp: (_) {
                          setState(() {
                            _favouritePressed = false;
                          });
                        },
                        onTapCancel: () {
                          setState(() {
                            _favouritePressed = false;
                          });
                        },
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOutBack,
                          scale: _favouritePressed ? 0.88 : 1,
                          child: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                widget.isFavourite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey<bool>(widget.isFavourite),
                              ),
                            ),
                            iconSize: 20,
                            color: Colors.red[400],
                            onPressed: widget.onFavouriteToggle == null
                                ? null
                                : () {
                                    widget.onFavouriteToggle!();
                                  },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurant.name,
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.restaurant.attributes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurant.vehicleClass,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.restaurant.priceLabel} | '
                          '${widget.restaurant.getRatingAndDistance()}',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
