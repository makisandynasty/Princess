import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/quotes_database.dart';
import '../../domain/entities/quote_entity.dart';

// ─── Providers ─────────────────────────────────────────────────────────────

/// Provides today's quote using deterministic day-of-year rotation (FR-5.2).
/// Synchronous provider for zero loading lag on startup.
final todayQuoteProvider = Provider<QuoteEntity>((ref) {
  final dayOfYear = DateTime.now().difference(
    DateTime(DateTime.now().year),
  ).inDays;

  final quotes = QuotesDatabase.allQuotes;
  final index = dayOfYear % quotes.length;
  return quotes[index];
});

/// Provides a quote by category.
final quoteByCategoryProvider =
    Provider.family<QuoteEntity, String>((ref, category) {
  final quotes = QuotesDatabase.allQuotes
      .where((q) => q.category == category)
      .toList();
  if (quotes.isEmpty) {
    return QuotesDatabase.allQuotes.first;
  }
  final dayOfYear = DateTime.now().difference(
    DateTime(DateTime.now().year),
  ).inDays;
  return quotes[dayOfYear % quotes.length];
});
