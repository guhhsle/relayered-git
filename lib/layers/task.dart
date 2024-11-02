import 'package:flutter/material.dart';
import 'task_date.dart';
import 'folder.dart';
import '../template/functions.dart';
import '../classes/database.dart';
import '../template/layer.dart';
import '../template/tile.dart';
import '../classes/task.dart';
import '../pages/task.dart';
import '../functions.dart';
import '../data.dart';

class TaskLayer extends Layer {
  Task task;
  TaskLayer(this.task);

  @override
  void construct() {
    listenTo(Database());
    action = Tile(task.name, Icons.notes_rounded, '', () {
      goToPage(TaskPage(task: task));
    });
    trailing = [
      IconButton(
        icon: Icon(task.doneIcon),
        onPressed: () => (task..done = !task.done).update(),
      ),
    ];
    list = [
      Tile.complex(
        '',
        Icons.colorize_rounded,
        task.color,
        () async {
          final layer = ColorLayer(task.color);
          task.color = await layer.completer.future;
          task.update();
        },
        iconColor: taskColors[task.color],
      ),
      Tile('', Icons.calendar_today_rounded, task.date(true, true), () {
        TaskDate(task).show();
      }),
      Tile('', task.pinIcon, 'Pin${task.pin ? 'ned' : ''}', () {
        task.pin = !task.pin;
        task.update();
      }),
      Tile.complex(
        '',
        Icons.folder_outlined,
        task.folder.name,
        () {
          Navigator.of(context).pop();
          FolderLayer(task.folder).show();
        },
      ),
      Tile('', Icons.delete_forever_rounded, 'Delete', () => task.delete()),
    ];
  }
}
