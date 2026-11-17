import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/transaction_model.dart';

sealed class ReceiptExportResult {
  const ReceiptExportResult();
}

final class ReceiptSaved extends ReceiptExportResult {
  final String path;
  const ReceiptSaved(this.path);
}

final class ReceiptShared extends ReceiptExportResult {
  const ReceiptShared();
}

final class ReceiptCancelled extends ReceiptExportResult {
  const ReceiptCancelled();
}

final class ReceiptExportFailed extends ReceiptExportResult {
  final String message;
  const ReceiptExportFailed(this.message);
}

class ReceiptExporter {
  const ReceiptExporter({this.pixelRatio = 3.0});

  final double pixelRatio;

  String fileNameFor(TransactionModel tx) =>
      'TapPay_Receipt_${tx.referenceNumber}.png';

  Future<Uint8List?> renderPng(RenderRepaintBoundary boundary) async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<ReceiptExportResult> share(
    RenderRepaintBoundary boundary,
    TransactionModel tx,
  ) async {
    try {
      final bytes = await renderPng(boundary);
      if (bytes == null) {
        return const ReceiptExportFailed('Could not generate receipt image');
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${fileNameFor(tx)}');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'TapPay Transaction Receipt (${tx.referenceNumber})',
        subject: 'TapPay Receipt - ${tx.referenceNumber}',
      );
      return const ReceiptShared();
    } catch (_) {
      return const ReceiptExportFailed('Could not share receipt');
    }
  }

  Future<ReceiptExportResult> saveToDevice(
    RenderRepaintBoundary boundary,
    TransactionModel tx,
  ) async {
    try {
      final bytes = await renderPng(boundary);
      if (bytes == null) {
        return const ReceiptExportFailed('Could not generate receipt image');
      }
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save receipt',
        fileName: fileNameFor(tx),
        type: FileType.image,
        bytes: bytes,
      );
      if (path == null) return const ReceiptCancelled();
      return ReceiptSaved(path);
    } catch (_) {
      return const ReceiptExportFailed('Failed to save receipt');
    }
  }
}
