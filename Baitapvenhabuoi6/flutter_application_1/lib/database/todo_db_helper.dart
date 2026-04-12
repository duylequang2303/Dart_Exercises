import 'package:hive_flutter/hive_flutter.dart';
import '../model/todo.dart';

class TodoDbHelper {
  static final TodoDbHelper _instance = TodoDbHelper._internal();
  factory TodoDbHelper() => _instance;
  TodoDbHelper._internal();

  static const String boxName = 'todos';

  Future<void> initDB() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  Box get box => Hive.box(boxName);

  int _nextId() {
    if (box.isEmpty) return 1;
    return box.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<int> insertTodo(Todo todo) async {
    final id = _nextId();
    await box.put(id, {
      'id': id,
      'title': todo.title,
      'content': todo.content,
      'isDone': todo.isDone ? 1 : 0,
    });
    return id;
  }

  Future<List<Todo>> getTodos() async {
    return box.values
        .map((e) => Todo.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> updateTodo(Todo todo) async {
    await box.put(todo.id, {
      'id': todo.id,
      'title': todo.title,
      'content': todo.content,
      'isDone': todo.isDone ? 1 : 0,
    });
  }

  Future<void> deleteTodo(int id) async {
    await box.delete(id);
  }
}