import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:princes/app/theme/color_scheme.dart';
import 'package:princes/features/quotes/domain/entities/quote_entity.dart';
import 'package:princes/features/quotes/presentation/controllers/quote_controller.dart';

/// An interactive, elegant daily inspiration quote card.
class QuoteCard extends ConsumerStatefulWidget {
  const QuoteCard({super.key});

  @override
  ConsumerState<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends ConsumerState<QuoteCard> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final quote = ref.watch(todayQuoteProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9D50BB).withOpacity(0.22),
            const Color(0xFF6E48AA).withOpacity(0.12),
            const Color(0xFF1C1328).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEDB1FF).withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D50BB).withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with category pill and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorScheme.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColorScheme.primaryGold.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: AppColorScheme.primaryGold,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      quote.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColorScheme.primaryGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: _isLiked
                          ? const Color(0xFFFF5252)
                          : const Color(0xFFD1C2D2),
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    onPressed: () {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: Color(0xFFD1C2D2),
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: '"${quote.text}" — ${quote.author}'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Quote copied to clipboard! ✨'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFF9D50BB),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quote Text
          Text(
            '"${quote.text}"',
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Author
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${quote.author}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFEDB1FF).withOpacity(0.85),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
