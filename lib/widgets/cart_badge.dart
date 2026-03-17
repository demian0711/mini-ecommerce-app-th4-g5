import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({
    super.key,
    this.onTap,
    this.iconColor,
    this.badgeColor,
    this.backgroundColor,
  });

  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? badgeColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final count = cart.totalItems;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: backgroundColor == null
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(Icons.shopping_cart_outlined, color: iconColor),
              ),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                        child: child,
                      );
                    },
                    child: _Badge(
                      key: ValueKey<int>(count),
                      count: count,
                      color: badgeColor ?? Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({super.key, required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
