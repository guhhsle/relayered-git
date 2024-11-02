import 'package:flutter/material.dart';
import '../../template/functions.dart';
import '../../template/layer.dart';
import '../../template/tile.dart';
import '../../classes/git.dart';

class GitLayer extends Layer {
  @override
  void construct() {
    list = [
      Tile('Clone', Icons.web_rounded, '', () async {
        final url = await getInput('', 'Git url');
        await Git().clone(url);
      }),
    ];
  }
}
