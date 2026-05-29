import 'package:flutter/material.dart';
import '../database/todo_db_helper.dart';
import '../model/todo.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  Future<void> loadTodos() async {
    _todos = await TodoDbHelper().getTodos();
    notifyListeners();
  }

  Future<void> addTodo(String title, String content) async {
    final todo = Todo(title: title, content: content);
    await TodoDbHelper().insertTodo(todo);
    await loadTodos();
  }

  Future<void> toggleDone(Todo todo) async {
    final updated = todo.copyWith(isDone: !todo.isDone);
    await TodoDbHelper().updateTodo(updated);
    await loadTodos();
  }

  Future<void> deleteTodo(int id) async {
    await TodoDbHelper().deleteTodo(id);
    await loadTodos();
  }
}