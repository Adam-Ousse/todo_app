import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

class Task {
  String title;
  String description;
  bool isDone;
  DateTime dueDate;
  List<String> tags;
  TaskPriority priority;

  Task({
    required this.title,
    this.description = '',
    this.isDone = false,
    DateTime? dueDate,
    this.tags = const [],
    this.priority = TaskPriority.low,
  }) : dueDate = dueDate ?? DateTime.now();
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3:
            true, // Optional: Enables Material 3 design for a modern look
      ),
      home: const MyHomePage(title: 'To-Do list'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final List<Task> _tasks = [];
  late TabController _tabController;
  String _sortMethod = "none"; // "none", "date", "priority"

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method to add a new task
  void _addTask() {
    _showTaskDialog();
  }

  // Method to edit a task
  void _editTask(int index) {
    _showTaskDialog(taskToEdit: _tasks[index], taskIndex: index);
  }

  void _showTaskDialog({Task? taskToEdit, int? taskIndex}) {
    showDialog(
      context: context,
      builder: (context) {
        String newTaskTitle = taskToEdit?.title ?? '';
        String newTaskDescription = taskToEdit?.description ?? '';
        DateTime newDueDate = taskToEdit?.dueDate ?? DateTime.now();
        List<String> newTags = List.from(taskToEdit?.tags ?? []);
        TaskPriority newPriority = taskToEdit?.priority ?? TaskPriority.low;
        String tagInput = '';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(taskToEdit == null ? 'Add Task' : 'Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: TextEditingController(text: newTaskTitle),
                      onChanged: (value) {
                        newTaskTitle = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter task title',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(
                        text: newTaskDescription,
                      ),
                      onChanged: (value) {
                        newTaskDescription = value;
                      },
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
                            if (date != null) {
                              setState(() => newDueDate = date);
                            }
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
                        if (value != null) {
                          setState(() => newPriority = value);
                        }
                      },
                      items:
                          TaskPriority.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(priority.name.toUpperCase()),
                            );
                          }).toList(),
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: tagInput),
                            onChanged: (value) {
                              tagInput = value;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Add tag',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (tagInput.isNotEmpty) {
                              setState(() {
                                newTags.add(tagInput);
                                tagInput = '';
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
                                    onDeleted: () {
                                      setState(() {
                                        newTags.remove(tag);
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (newTaskTitle.isNotEmpty) {
                      this.setState(() {
                        if (taskToEdit == null) {
                          // Add new task
                          _tasks.add(
                            Task(
                              title: newTaskTitle,
                              description: newTaskDescription,
                              dueDate: newDueDate,
                              tags: newTags,
                              priority: newPriority,
                            ),
                          );
                        } else {
                          // Update existing task
                          _tasks[taskIndex!].title = newTaskTitle;
                          _tasks[taskIndex].description = newTaskDescription;
                          _tasks[taskIndex].dueDate = newDueDate;
                          _tasks[taskIndex].tags = newTags;
                          _tasks[taskIndex].priority = newPriority;
                        }
                        _sortTasks();
                      });
                      Navigator.of(context).pop();
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

  void _sortTasks() {
    setState(() {
      switch (_sortMethod) {
        case "date":
          _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          break;
        case "priority":
          _tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
          break;
      }
    });
  }

  List<Task> _getFilteredTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    switch (_tabController.index) {
      case 0: // All tasks
        return _tasks;
      case 1: // Today
        return _tasks.where((task) {
          final taskDate = DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
          );
          return taskDate.isAtSameMomentAs(today);
        }).toList();
      case 2: // Tomorrow
        return _tasks.where((task) {
          final taskDate = DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
          );
          return taskDate.isAtSameMomentAs(tomorrow);
        }).toList();
      case 3: // Next 7 days
        return _tasks.where((task) {
          final taskDate = DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
          );
          return taskDate.isAfter(today.subtract(const Duration(days: 1))) &&
              taskDate.isBefore(nextWeek.add(const Duration(days: 1)));
        }).toList();
      default:
        return _tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortMethod = value;
                _sortTasks();
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: "none", child: Text("No sorting")),
                  const PopupMenuItem(
                    value: "date",
                    child: Text("Sort by date"),
                  ),
                  const PopupMenuItem(
                    value: "priority",
                    child: Text("Sort by priority"),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Today"),
            Tab(text: "Tomorrow"),
            Tab(text: "Next 7 Days"),
          ],
        ),
      ),
      body:
          filteredTasks.isEmpty
              ? const Center(child: Text('No tasks in this category'))
              : ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];

                  // Common text decoration for all elements when task is done
                  final decoration =
                      task.isDone ? TextDecoration.lineThrough : null;
                  final textColor = task.isDone ? Colors.grey : null;

                  return Dismissible(
                    key: Key('task_${_tasks.indexOf(task)}'),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      setState(() {
                        _tasks.remove(task);
                      });
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: InkWell(
                        onTap: () => _editTask(_tasks.indexOf(task)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Checkbox on the left
                              Checkbox(
                                value: task.isDone,
                                onChanged: (bool? value) {
                                  setState(() {
                                    task.isDone = value ?? false;
                                  });
                                },
                              ),

                              // Title and description in the middle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: decoration,
                                        color: textColor ?? Colors.black,
                                      ),
                                    ),
                                    if (task.description.isNotEmpty)
                                      Text(
                                        task.description,
                                        style: TextStyle(
                                          decoration: decoration,
                                          color: textColor ?? Colors.black54,
                                        ),
                                      ),
                                    // Tags centered below title/description
                                    if (task.tags.isNotEmpty)
                                      Center(
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 4,
                                          children:
                                              task.tags
                                                  .map(
                                                    (tag) => Chip(
                                                      label: Text(
                                                        tag,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          decoration:
                                                              decoration,
                                                          color:
                                                              textColor ??
                                                              Colors.black,
                                                        ),
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Due date and priority on the right
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 12,
                                        color:
                                            task.isDone
                                                ? Colors.grey
                                                : _getDueDateColor(
                                                  task.dueDate,
                                                ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          decoration: decoration,
                                          color: textColor ?? Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  _getPriorityIndicator(
                                    task.priority,
                                    task.isDone,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getDueDateColor(DateTime dueDate) {
    final today = DateTime.now();
    final difference = dueDate.difference(today).inDays;

    if (difference < 0) return Colors.red;
    if (difference < 2) return Colors.orange;
    return Colors.green;
  }

  Widget _getPriorityIndicator(TaskPriority priority, bool isDone) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.low:
        color = Colors.green;
        break;
    }

    if (isDone) {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}
