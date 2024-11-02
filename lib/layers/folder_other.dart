import 'package:flutter/material.dart';
import 'folder_browser.dart';
import 'folder.dart';
import 'task.dart';
import '../classes/database.dart';
import '../classes/folder.dart';
import '../template/layer.dart';
import '../template/tile.dart';
import '../data.dart';

class PinnedFolders extends Layer {
  @override
  void construct() {
    listenTo(Database());
    action = Tile('Pinned', Icons.push_pin_rounded, ' ');
    final pinnedFolders = [...root.nodes.where((e) => e.pin), root];
    final folders = pinnedFolders.map((e) {
      return e.toTile(() {
        Navigator.of(context).pop();
        FolderLayer(e).show();
      });
    });
    final tasks = root.nodes.map((f) {
      return f.tasks;
    }).expand((task) {
      return task;
    }).where((task) {
      return task.pin;
    }).map((task) {
      return task.toTile(() {
        Navigator.of(context).pop();
        TaskLayer(task).show();
      });
    });
    list = [...folders, ...tasks];
    trailing = [
      IconButton(
        icon: const Icon(Icons.line_style_rounded),
        onPressed: () {
          Navigator.of(context).pop();
          AllFolders().show();
        },
      ),
    ];
  }
}

class AllFolders extends FolderBrowser {
  @override
  void onSelected(Folder chosen) {
    FolderLayer(chosen).show();
  }

  @override
  void construct() {
    action = Tile('New', Icons.add_rounded, '', () async {
      //New folder
    });
    list = root.nodes.map(
      (e) => e.toTile(() {
        Navigator.of(context).pop();
        FolderLayer(e).show();
      }),
    );
  }
}
