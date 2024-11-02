import 'package:flutter/material.dart';
import '../classes/database.dart';
import '../classes/folder.dart';
import '../template/layer.dart';
import '../template/tile.dart';
import '../data.dart';

abstract class FolderBrowser extends Layer {
  @override
  void construct() {
    listenTo(Database());
    action = Tile('New', Icons.add_rounded, '', () async {
      //TODO new folder & select
    });
    list = root.nodes.map((e) {
      return e.toTile(() {
        Navigator.of(context).pop();
        onSelected(e);
      });
    });
  }

  void onSelected(Folder chosen);
  bool isSelected(Folder chosen) => false;
}
