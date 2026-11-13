import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../domain/auth_models.dart';

Future<CountryOption?> showCountryPickerSheet({
  required BuildContext context,
  required String title,
  required CountryOption? selectedCountry,
  required bool showDialCode,
}) {
  return showModalBottomSheet<CountryOption>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final sheetBg = isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground;
      final textPrimary = isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
      final defaultBorder = isDark
          ? const Color(0xFF42544B)
          : const Color(0xFFB5BDC4);

      return Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 39),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            ...CountryOption.supported.map((country) {
              final isSelected = selectedCountry?.name == country.name;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(country),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : defaultBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        FlagIcon(
                          assetPath: country.flagAsset,
                          fallbackEmoji: country.flagEmoji,
                          height: 30,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          showDialCode
                              ? '${country.name} (${country.dialCode})'
                              : country.name,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}
