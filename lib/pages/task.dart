import 'package:flutter/material.dart';
import '../template/functions.dart';
import '../widgets/frame.dart';
import '../classes/task.dart';
import '../layers/task.dart';

class TaskPage extends StatefulWidget {
  final Task task;

  const TaskPage({super.key, required this.task});
  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  late Task task;
  late TextEditingController controller;

  @override
  void initState() {
    task = widget.task;
    controller = TextEditingController(text: task.desc);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (b, d) => updateNote(),
      child: Frame(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: TaskLayer(task).show,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                updateNote();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.done_rounded),
            ),
          ),
        ],
        title: TextFormField(
          maxLines: 1,
          maxLength: 24,
          key: Key(task.name),
          initialValue: task.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 18,
          ),
          cursorColor: Theme.of(context).appBarTheme.foregroundColor,
          decoration: InputDecoration(
            counterText: "",
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: t('Title'),
          ),
          onFieldSubmitted: (s) => task.rename(s),
        ),
        child: TextField(
          controller: controller,
          maxLines: null,
          cursorColor: Theme.of(context).colorScheme.primary,
          cursorWidth: 3,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            hintText: '...',
          ),
        ),
      ),
    );
  }

  void updateNote() {
    task.desc = controller.text;
    task.update();
  }
}
