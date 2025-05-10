import 'package:flutter/material.dart';
import 'add_edit_task_dialog.dart';

// --- Models & Enums ---
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

// --- Main Screen ---
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Task> _tasks = [];
  int _selectedTab = 0;
  String _sortMethod = "none"; // "none", "date", "priority"

  // --- Drawer Info ---
  String userName = "Adam";
  int get totalTasks => _tasks.length;
  int get doneTasks => _tasks.where((t) => t.isDone).length;

  Drawer _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DrawerHeader(
              child: CircleAvatar(
                radius: 36,
                child: Icon(Icons.person, size: 48),
              ),
            ),
            ListTile(
              title: Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("User"),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Total Tasks"),
              trailing: Text("$totalTasks"),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text("Tasks Done"),
              trailing: Text("$doneTasks"),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
      title: Text(widget.title, textAlign: TextAlign.center),
      centerTitle: true,
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
                const PopupMenuItem(value: "date", child: Text("Sort by date")),
                const PopupMenuItem(
                  value: "priority",
                  child: Text("Sort by priority"),
                ),
              ],
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedTab,
      onTap: (index) => setState(() => _selectedTab = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.inbox), label: "All"),
        BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Tomorrow",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.date_range),
          label: "Next 7 Days",
        ),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }

  void _addTask() => _showTaskDialog();
  void _editTask(int index) =>
      _showTaskDialog(taskToEdit: _tasks[index], taskIndex: index);

  void _showTaskDialog({Task? taskToEdit, int? taskIndex}) async {
    final result = await showAddEditTaskDialog(context, taskToEdit: taskToEdit);
    if (result != null) {
      setState(() {
        if (taskToEdit == null) {
          _tasks.add(result);
        } else {
          _tasks[taskIndex!] = result;
        }
        _sortTasks();
      });
    }
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
    switch (_selectedTab) {
      case 0: // All
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

  Widget _buildTaskList(List<Task> filteredTasks) {
    if (filteredTasks.isEmpty) {
      return const Center(child: Text('No tasks in this category'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        final decoration = task.isDone ? TextDecoration.lineThrough : null;
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
            setState(() => _tasks.remove(task));
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: InkWell(
              onTap: () => _editTask(_tasks.indexOf(task)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: task.isDone,
                      onChanged: (bool? value) {
                        setState(() => task.isDone = value ?? false);
                      },
                    ),
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
                                                decoration: decoration,
                                                color:
                                                    textColor ?? Colors.black,
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
                                      : _getDueDateColor(task.dueDate),
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
                        _getPriorityIndicator(task.priority, task.isDone),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
    if (isDone) color = Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: _buildTaskList(filteredTasks),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
