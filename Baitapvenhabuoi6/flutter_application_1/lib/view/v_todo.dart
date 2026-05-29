import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/todo_provider.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final content = contentCtrl.text.trim();
              if (title.isEmpty) return;

              final provider = context.read<TodoProvider>();
              Navigator.pop(ctx);
              provider.addTodo(title, content);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          final list = provider.todos;

          if (list.isEmpty) {
            return const Center(child: Text('Chưa có công việc nào'));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final todo = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: ListTile(
                  // Tên công việc màu xanh
                  title: Text(
                    todo.title,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Trạng thái hoàn thành
                  subtitle: Row(
                    children: [
                      Icon(
                        todo.isDone
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: todo.isDone ? Colors.green : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        todo.isDone ? 'Hoàn thành' : 'Chưa hoàn thành',
                        style: TextStyle(
                          color: todo.isDone ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  // Nhấn vào → toggle hoàn thành
                  onTap: () {
                    context.read<TodoProvider>().toggleDone(todo);
                  },
                  // Nút xóa
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<TodoProvider>().deleteTodo(todo.id!);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}