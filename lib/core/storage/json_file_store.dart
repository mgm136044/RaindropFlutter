import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:raindrop_flutter/core/utils/app_constants.dart';

class JsonFileStore {
  JsonFileStore();

  Future<T> load<T>(
    String filename,
    T Function(dynamic json) fromJson, {
    required T Function() orElse,
  }) async {
    final file = await _file(filename);
    if (!await file.exists()) {
      return orElse();
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return orElse();
    }

    final decoded = jsonDecode(content);
    return fromJson(decoded);
  }

  Future<void> save(String filename, dynamic value) async {
    final file = await _file(filename);
    final directory = file.parent;
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final encoder = const JsonEncoder.withIndent('  ');
    final content = encoder.convert(value);
    await file.writeAsString(content, flush: true);
  }

  Future<File> _file(String filename) async {
    final appSupport = await getApplicationSupportDirectory();
    final directory = Directory(
      '${appSupport.path}/${AppConstants.appDirectoryName}',
    );
    return File('${directory.path}/$filename');
  }
}
