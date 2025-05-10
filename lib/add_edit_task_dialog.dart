import 'package:flutter/material.dart';
import 'main_screen.dart';

// Returns a Task if saved, or null if cancelled.
Future<Task?> showAddEditTaskDialog(BuildContext context, {Task? taskToEdit}) {
  final titleController = TextEditingController(text: taskToEdit?.title ?? '');
  final descController = TextEditingController(
    text: taskToEdit?.description ?? '',
  );
  final tagController = TextEditingController();
  DateTime newDueDate = taskToEdit?.dueDate ?? DateTime.now();
  List<String> newTags = List.from(taskToEdit?.tags ?? []);
  TaskPriority newPriority = taskToEdit?.priority ?? TaskPriority.low;

  return showDialog<Task>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(taskToEdit == null ? 'Add Task' : 'Edit Task'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task title',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      hintText: 'Enter description',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Due date: '),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: newDueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) setState(() => newDueDate = date);
                        },
                        child: Text(
                          '${newDueDate.day}/${newDueDate.month}/${newDueDate.year}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<TaskPriority>(
                    value: newPriority,
                    onChanged: (value) {
                      if (value != null) setState(() => newPriority = value);
                    },
                    items:
                        TaskPriority.values
                            .map(
                              (priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                    decoration: const InputDecoration(labelText: 'Priority'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tagController,
                          decoration: const InputDecoration(
                            hintText: 'Add tag',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (tagController.text.isNotEmpty) {
                            setState(() {
                              newTags.add(tagController.text);
                              tagController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (newTags.isNotEmpty)
                    Wrap(
                      spacing: 5,
                      children:
                          newTags
                              .map(
                                (tag) => Chip(
                                  label: Text(tag),
                                  onDeleted:
                                      () => setState(() => newTags.remove(tag)),
                                ),
                              )
                              .toList(),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    Navigator.of(context).pop(
                      Task(
                        title: titleController.text,
                        description: descController.text,
                        dueDate: newDueDate,
                        tags: newTags,
                        priority: newPriority,
                      ),
                    );
                  }
                },
                child: Text(taskToEdit == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
