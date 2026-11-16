import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../domain/kyc_models.dart';
import '../kyc_controller.dart';

/// Figma KYC step chrome: back arrow, 32px title, 16px subtitle, form,
/// and a pinned primary button ("Next").
class KycStepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;
  final String buttonText;
  final VoidCallback? onContinue;
  final bool isLoading;
  final String? footerHint;

  const KycStepScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.onContinue,
    this.buttonText = 'Next',
    this.isLoading = false,
    this.footerHint,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SettingsPageScaffold(
        bottomAction: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (footerHint != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  footerHint!,
                  key: const ValueKey('kyc_footer_hint'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 12,
                    color: palette.body,
                  ),
                ),
              ),
            AppButton(
              key: const ValueKey('kyc_next_btn'),
              text: buttonText,
              isLoading: isLoading,
              onPressed: onContinue,
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KycHeading(title: title, subtitle: subtitle),
            const SizedBox(height: 46),
            body,
          ],
        ),
      ),
    );
  }
}

class KycHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextAlign textAlign;

  const KycHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 32,
            height: 1.19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: palette.heading,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: textAlign,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 16,
            height: 1.4,
            color: palette.body,
          ),
        ),
      ],
    );
  }
}

/// Label + tappable read-only field with a trailing icon (dropdowns and
/// date pickers).
class KycSelectField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final VoidCallback onTap;
  final IconData icon;
  final String? errorText;

  const KycSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.hint = 'Select',
    this.icon = Icons.keyboard_arrow_down_rounded,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KycFieldLabel(label),
        Semantics(
          button: true,
          label: '$label, ${value ?? hint}',
          excludeSemantics: true,
          child: Material(
            color: palette.card,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 53,
                padding: const EdgeInsets.only(left: 16, right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasError ? AppColors.accentRed : palette.fieldBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value ?? hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 14,
                          color: value == null ? palette.body : palette.title,
                        ),
                      ),
                    ),
                    Icon(icon, size: 24, color: palette.icon),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError) KycHelperText(errorText!, isError: true),
      ],
    );
  }
}

class KycFieldLabel extends StatelessWidget {
  final String text;

  const KycFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Gordita',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: palette.heading,
        ),
      ),
    );
  }
}

class KycHelperText extends StatelessWidget {
  final String text;
  final bool isError;

  const KycHelperText(this.text, {super.key, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Gordita',
          fontSize: 12,
          height: 1.4,
          color: isError ? AppColors.accentRed : palette.body,
        ),
      ),
    );
  }
}

/// Dashed "Upload file" drop zone. Shows a preview once a file is attached.
class KycUploadBox extends StatelessWidget {
  final String? label;
  final String? caption;
  final double height;
  final KycDocument? document;
  final ViewState<KycDocument>? state;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const KycUploadBox({
    super.key,
    required this.height,
    required this.document,
    required this.state,
    required this.onTap,
    required this.onRemove,
    this.label,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final doc = document;
    final isBusy = state is Loading;
    final error = state is Failure<KycDocument>
        ? (state as Failure<KycDocument>).message
        : null;

    Widget content;
    if (isBusy) {
      content = const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.primaryGreen,
          ),
        ),
      );
    } else if (doc == null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppAssets.iconExport,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(palette.icon, BlendMode.srcIn),
            ),
            const SizedBox(height: 10),
            Text(
              'Upload file',
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: palette.heading,
              ),
            ),
          ],
        ),
      );
    } else {
      content = Stack(
        fit: StackFit.expand,
        children: [
          if (doc.isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.file(
                File(doc.path),
                fit: BoxFit.cover,
                cacheWidth: 900,
                errorBuilder: (_, _, _) => _FileSummary(doc: doc),
              ),
            )
          else
            _FileSummary(doc: doc),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              child: IconButton(
                key: const ValueKey('kyc_remove_file_btn'),
                tooltip: 'Remove file',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: onRemove,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) KycFieldLabel(label!),
        Semantics(
          button: true,
          label: doc == null
              ? '${label ?? caption ?? 'Document'}, upload file'
              : '${doc.name} attached, tap to replace',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isBusy ? null : onTap,
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: error != null ? AppColors.accentRed : palette.muted,
              ),
              child: Container(
                height: height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: content,
              ),
            ),
          ),
        ),
        if (error != null)
          KycHelperText(error, isError: true)
        else if (caption != null)
          KycHelperText(caption!),
      ],
    );
  }
}

class _FileSummary extends StatelessWidget {
  final KycDocument doc;

  const _FileSummary({required this.doc});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.description_rounded,
              size: 36,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 10),
            Text(
              doc.name,
              key: const ValueKey('kyc_attached_file_name'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: palette.heading,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${doc.readableSize} • Tap to replace',
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 12,
                color: palette.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()..addRRect(rrect);
    for (final ui.PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

/// Figma option list sheets (Employment status, Income band, Means of ID).
Future<T?> showKycOptionSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  T? selected,
}) {
  return showAppBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    title: title,
    padding: const EdgeInsets.fromLTRB(42, 12, 42, 28),
    builder: (sheetContext) {
      final palette = SettingsPalette.of(sheetContext);
      return Flexible(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: options.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (_, i) {
            final option = options[i];
            final isSelected = option == selected;
            return Material(
              color: isSelected ? AppColors.successTint : palette.card,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                key: ValueKey('kyc_option_${labelOf(option)}'),
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.of(sheetContext).pop(option),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.successText
                          : palette.divider,
                    ),
                  ),
                  child: Text(
                    labelOf(option),
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.successText
                          : palette.heading,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

/// Lets the user choose where an attachment comes from.
Future<KycMediaOrigin?> showKycMediaOriginSheet(
  BuildContext context, {
  bool allowFiles = true,
}) {
  return showAppBottomSheet<KycMediaOrigin>(
    context: context,
    useRootNavigator: true,
    title: 'Add file',
    builder: (sheetContext) {
      Widget tile(KycMediaOrigin origin, IconData icon, String label) {
        final palette = SettingsPalette.of(sheetContext);
        return ListTile(
          key: ValueKey('kyc_origin_${origin.name}'),
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: palette.icon),
          title: Text(
            label,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: palette.heading,
            ),
          ),
          onTap: () => Navigator.of(sheetContext).pop(origin),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile(
            KycMediaOrigin.camera,
            Icons.photo_camera_outlined,
            'Take a photo',
          ),
          tile(
            KycMediaOrigin.gallery,
            Icons.photo_library_outlined,
            'Choose from gallery',
          ),
          if (allowFiles)
            tile(
              KycMediaOrigin.files,
              Icons.folder_open_rounded,
              'Browse files (PDF or image)',
            ),
        ],
      );
    },
  );
}
