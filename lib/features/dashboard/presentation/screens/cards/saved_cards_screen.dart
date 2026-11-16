import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../domain/dashboard_models.dart';
import '../../dashboard_controller.dart';
import 'add_new_card_screen.dart';

class SavedCardsScreen extends StatelessWidget {
  final bool selectMode;

  const SavedCardsScreen({
    super.key,
    this.selectMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final cardBorder = isDark
        ? const Color(0xFF1E352B)
        : const Color(0xFFE2E8F0);
    final cardBg = isDark
        ? AppColors.darkSurface
        : const Color(0xFFF8FAFC);
    final emptyTextColor = isDark
        ? const Color(0xFF6B7280)
        : const Color(0xFF64748B);

    final dashboard = context.watch<DashboardController>();
    final cards = dashboard.savedCards;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                key: const ValueKey('saved_cards_back_btn'),
                icon: Icon(
                  Icons.arrow_back,
                  size: 26,
                  color: textPrimary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 20),
              Text(
                'Saved cards',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: cards.isEmpty
                    ? Center(
                        child: Text(
                          'You currently don’t have any\nsaved cards',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 16,
                            height: 1.4,
                            color: emptyTextColor,
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: cards.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          final isSelected =
                              dashboard.selectedCard?.id == card.id;

                          return InkWell(
                            onTap: () {
                              dashboard.selectCard(card);
                              if (selectMode) {
                                Navigator.of(context).pop(card);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : cardBorder,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurfaceVariant
                                          : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.credit_card_rounded,
                                      color: textPrimary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          card.maskedNumber,
                                          style: TextStyle(
                                            fontFamily: 'Gordita',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${card.holderName} • Exp ${card.expiryDate}',
                                          style: TextStyle(
                                            fontFamily: 'Gordita',
                                            fontSize: 12,
                                            color: emptyTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppButton(
                  text: 'Add card',
                  onPressed: () async {
                    final newCard = await Navigator.of(context)
                        .push<PaymentCard>(
                      MaterialPageRoute(
                        builder: (_) => const AddNewCardScreen(),
                      ),
                    );
                    if (newCard != null && selectMode && context.mounted) {
                      Navigator.of(context).pop(newCard);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
