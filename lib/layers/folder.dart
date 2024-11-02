import 'package:flutter/material.dart';
import 'package:relayered/classes/task.dart';
import 'package:relayered/template/functions.dart';
import 'folder_options.dart';
import 'task.dart';
import '../classes/database.dart';
import '../classes/folder.dart';
import '../template/layer.dart';
import '../template/tile.dart';

class FolderLayer extends Layer {
  Folder folder;
  FolderLayer(this.folder);
  @override
  void construct() {
    listenTo(Database());
    action = Tile(folder.name, Icons.folder_rounded, ' ', () {
      FolderOptions(folder).show();
    });
    final pendingTasks = folder.tasks.where((task) => !task.done).map((task) {
      return task.toTile(() {
        Navigator.of(context).pop();
        TaskLayer(task).show();
      });
    });
    final subfolders = folder.nodes.map((folder) {
      return folder.toTile(() {
        Navigator.of(context).pop();
        FolderLayer(folder).show();
      });
    });
    final doneTasks = folder.tasks.where((task) => task.done).map((task) {
      return task.toTile(() {
        Navigator.of(context).pop();
        TaskLayer(task).show();
      });
    });
    list = [...pendingTasks, ...subfolders, ...doneTasks];
    trailing = [
      IconButton(
        icon: const Icon(Icons.create_new_folder_rounded),
        onPressed: () async {
          final name = await getInput('', 'Folder');
          folder.makeNode(name);
        },
      ),
      IconButton(
        icon: const Icon(Icons.add_rounded),
        onPressed: () async {
          final name = await getInput('', 'Task');
          folder.makeTask(name);
        },
      ),
    ];
  }
}
