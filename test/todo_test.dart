import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_testing/main.dart';

void main() {
  test('ToDoItem can be converted to and from Map', () {
    TodoItem item = TodoItem(task: "Test Task", isChecked: true);
    Map<String, dynamic> map = item.toMap();

    expect(map['task'], 'Test Task');
    expect(map['isChecked'], true);

    TodoItem newItem = TodoItem.fromMap(map);
    expect(newItem.task, 'Test Task');
    expect(newItem.isChecked, true);
  });

  test("Saving and Loading todo List", () async {
    SharedPreferences.setMockInitialValues({});   //setMockInitialValues({}): Clears previous stored data and sets up a fresh mock storage.
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<TodoItem> todoList = [
      TodoItem(task: 'Task 1'),
      TodoItem(task: 'Task 2', isChecked: true),
    ];

    List<String> todoJson = todoList.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList('todoList', todoJson);

    List<String>? loadedJson = prefs.getStringList('todoList');
    expect(loadedJson, isNotNull);

    List<TodoItem> loadedList = loadedJson!.map((item) => TodoItem.fromMap(jsonDecode(item))).toList();
    expect(loadedList.length, 2);
    expect(loadedList[0].task, 'Task 1');
    expect(loadedList[1].isChecked, true);
  });

}