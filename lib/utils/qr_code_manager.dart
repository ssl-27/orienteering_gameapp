import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:typed_data';

class QRCodeManager {
  static Future<String> get _baseDirectory async {
    if (Platform.isAndroid) {
      // Save to Pictures/Orienteering directory on Android
      final directory = Directory('/storage/emulated/0/Pictures/Orienteering');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory.path;
    } else {
      // Save to Documents/Orienteering directory on iOS
      final directory = await getApplicationDocumentsDirectory();
      final qrDirectory = Directory('${directory.path}/Orienteering');
      if (!await qrDirectory.exists()) {
        await qrDirectory.create();
      }
      return qrDirectory.path;
    }
  }

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      if (sdkInt != null && sdkInt >= 33) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // iOS doesn't need explicit permission for app directory
  }

  static Future<String> saveQRCode(Uint8List imageBytes, String gameCode, String location) async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      throw Exception('Storage permission denied');
    }

    final baseDir = await _baseDirectory;
    final fileName = 'qr_${gameCode}_${location.replaceAll(RegExp(r'[^\w\s-]'), '')}.png';
    final filePath = '$baseDir/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    return filePath;
  }

  static Future<List<String>> getAllQRCodes() async {
    final baseDir = await _baseDirectory;
    final directory = Directory(baseDir);
    if (!await directory.exists()) return [];

    return directory
        .listSync()
        .where((entity) => entity.path.endsWith('.png'))
        .map((entity) => entity.path)
        .toList();
  }

  static Future<void> shareQRCode(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }
}