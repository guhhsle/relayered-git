import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:relayered/classes/folder.dart';
import 'dart:io';
import '../data.dart';
import 'git.dart';

class Database extends ChangeNotifier {
  Database.internal();
  static final Database instance = Database.internal();
  factory Database() => instance;

  void notify() => notifyListeners();

  Future<void> init() async {
    String path = Pref.path.value;
    if (path == '') {
      final cache = await getApplicationCacheDirectory();
      Pref.path.set(cache.path);
    }
    final rootDirectory = Directory('$path/Root');
    root = Folder(rootDirectory.path);
    if (!await rootDirectory.exists()) {
      await rootDirectory.create();
    }
    await root.loadDirectory();
    await Git().init();
  }

  Future<void> write({
    required String path,
    required String content,
  }) async {
    final file = File(path);
    await file.writeAsString(content);
    debugPrint('Writing at $path: $content');
    notify();
  }
}
