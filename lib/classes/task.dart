import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'folder.dart';
import '../template/functions.dart';
import '../classes/database.dart';
import '../template/tile.dart';
import '../pages/task.dart';
import '../functions.dart';
import '../data.dart';

class Task {
  String path, raw = '', desc = '';
  String? color;
  List<DateTime> dues = [];
  Folder folder;
  bool done = false, pin = false;

  Task(this.path, {required this.folder});

  String get name => formatPath(path);

  Future<void> rename(String newName) async {
    final oldPath = path;
    final newPath = path.substring(0, path.length - name.length) + newName;
    await File(oldPath).rename(newPath);
    path = newPath;
    Database().notify();
  }

  static Future<Task> fromFile(File file, Folder folder) async {
    final task = Task(file.path, folder: folder);
    task.raw = await file.readAsString();
    try {
      int dividerPos = task.raw.indexOf(divider);
      if (dividerPos != -1) {
        task.load(jsonDecode(task.raw.substring(0, dividerPos)));
        task.desc = task.raw.substring(dividerPos + divider.length + 1);
      } else {
        task.desc = task.raw;
      }
    } catch (e) {
      debugPrint('Cant format task: ${task.raw}');
    }
    return task;
  }

  void load(Map map) {
    color = map['color'];
    done = map['done'] ?? false;
    pin = map['pin'] ?? false;
  }

  Tile toTile(VoidCallback onTap, {String? title}) {
    title ??= '$name   ${date(false, true)}';
    return Tile.complex(
      title,
      doneIcon,
      '',
      onTap,
      iconColor: taskColors[color],
      secondary: () {
        done = !done;
        update();
      },
      onHold: () => goToPage(TaskPage(task: this)),
    );
  }

  Map get map {
    Map result = {};
    if (color != null) result.addAll({'color': color});
    if (done) result.addAll({'done': done});
    if (pin) result.addAll({'pin': pin});
    if (dues.isNotEmpty) {
      result.addAll({
        'dues': dues.map((e) {
          return e.toIso8601String();
        }).toList()
      });
    }
    return result;
  }

  static Future<Task> create(String name, Folder folder) async {
    final file = File('${folder.path}/$name');
    await file.create();
    return await Task.fromFile(file, folder);
  }

  Future update() async {
    return Database().write(
      path: path,
      content: toString(),
    );
  }

  Future delete() async {
    await File(path).delete();
    folder.tasks.remove(this);
    showSnack('Deleted $name', false);
    path = 'DELETED';
    Database().notify();
  }

  IconData get pinIcon {
    if (pin) return Icons.push_pin_rounded;
    return Icons.push_pin_outlined;
  }

  IconData get doneIcon => checked(done);

  bool get hasDue => dues.isNotEmpty;

  String date([bool showYear = false, bool showMonth = false]) {
    if (!hasDue) {
      return '  ${showYear ? '     ' : ''}${showMonth ? '   ' : ''}';
    } else if (dues.length == 1) {
      return dues[0].prettify(showYear, showMonth);
    } else {
      return '${dues[0].prettify(showYear, showMonth)}...';
    }
  }

  @override
  String toString() {
    final meta = jsonEncode(map);
    return '$meta\n$divider\n$desc';
  }

  void renamePath(String from, String to) {
    path = path.replaceFirst(from, to);
  }
}
