import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/quote_controller.dart';

/// Beautiful daily quote card widget used on Dashboard and Alarm screens.
class DailyQuoteCard extends ConsumerWidget {
  const DailyQuoteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quote = ref.watch(todayQuoteProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.tertiaryContainer.withAlpha(100),
            theme.colorScheme.secondaryContainer.withAlpha(60),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote icon
          Icon(
            Icons.format_quote_rounded,
            size: 28,
            color: theme.colorScheme.tertiary.withAlpha(160),
          ),
          const SizedBox(height: 8),

          // Quote text
          Text(
            quote.text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Author and category
          Row(
            children: [
              Text(
                '— ${quote.author}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  quote.category,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
