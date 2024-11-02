import 'package:flutter/material.dart';
import 'package:relayered/template/functions.dart';
import 'dart:convert';
import 'dart:io';
import 'task.dart';
import '../layers/folder_options.dart';
import '../classes/database.dart';
import '../template/tile.dart';
import '../functions.dart';
import '../data.dart';

class Folder {
  String path, raw = '';
  String? color;
  String prefix = '';
  bool pin = false;
  List<Task> tasks = [];
  List<Folder> nodes = [];
  Folder? parent;
  Folder(this.path);

  String get name => formatPath(path);

  Future<void> rename(String newName) async {
    final oldPath = path;
    final directory = Directory(path);
    path = path.substring(0, path.length - name.length) + newName;
    renamePath(oldPath, path);
    await directory.rename(path);
    Database().notify();
  }

  Future<void> loadFromFile(File file) async {
    raw = await file.readAsString();
    try {
      int dividerPos = raw.indexOf(divider);
      load(jsonDecode(raw.substring(0, dividerPos)));
    } catch (e) {
      debugPrint('Cant format folder: $raw');
    }
  }

  void load(Map map) {
    prefix = map['prefix'] ?? '';
    pin = map['pin'] ?? false;
    color = map['color'];
  }

  void renamePath(String from, String to) async {
    path = path.replaceFirst(from, to);
    for (final task in tasks) {
      task.renamePath(from, to);
      debugPrint('New task path: ${task.path}');
    }
    for (final node in nodes) {
      node.renamePath(from, to);
      debugPrint('New node path: ${node.path}');
    }
  }

  Future<void> loadDirectory() async {
    final content = Directory(path).listSync();
    for (var item in content) {
      try {
        if (item is Directory) {
          final folder = Folder(item.path);
          folder.parent = this;
          await folder.loadDirectory();
          nodes.add(folder);
        } else if (item is File) {
          if (formatPath(item.path) == '#') {
            await loadFromFile(item);
          } else {
            tasks.add(await Task.fromFile(item, this));
          }
        }
      } catch (e) {
        debugPrint('Item error: $e');
      }
    }
  }

  Map get map {
    Map result = {};
    if (prefix != '') result.addAll({'prefix': prefix});
    if (color != null) result.addAll({'color': color});
    if (pin) result.addAll({'pin': pin});
    return result;
  }

  Tile toTile(VoidCallback onTap) {
    return Tile.complex(
      name,
      Icons.folder_outlined,
      '',
      onTap,
      onHold: FolderOptions(this).show,
      iconColor: taskColors[color],
    );
  }

  void addSubfoldersToList(List<Folder> list) {
    list.add(this);
    for (final node in nodes) {
      node.addSubfoldersToList(list);
    }
  }

  void addSubtasksToList(List<Task> list) {
    for (final task in tasks) {
      list.add(task);
    }
    for (final node in nodes) {
      node.addSubtasksToList(list);
    }
  }

  Future update() async {
    return Database().write(
      path: '$path/#',
      content: toString(),
    );
  }

  Future delete() async {
    await Directory(path).delete(recursive: true);
    parent?.nodes.remove(this);
    showSnack('Deleted $name', false);
    path = 'DELETED';
    Database().notify();
  }

  @override
  String toString() {
    final meta = jsonEncode(map);
    return '$meta\n$divider';
  }

  Future<void> makeNode(String name) async {
    final directory = Directory('$path/$name');
    await directory.create();
    nodes.add(Folder('$path/$name'));
    Database().notify();
  }

  Future<void> makeTask(String name) async {
    tasks.add(await Task.create(name, this));
    Database().notify();
  }
}
