import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 121, 41, 41)),
        useMaterial3: true,
      ),
      home: const ListTileExample(),
    );
  }
}


//ToDoItem Model 
class TodoItem {
  String task;
  bool isChecked;

  TodoItem({required this.task, this.isChecked=false});

  // Convert ToDoItem to Map for storage
  //Since SharedPreferences only supports primitive data types (String, int, bool, etc.), we need to convert our object (ToDoItem) to a storable format (Map).
  // toMap() → Converts a ToDoItem object into a Map ({ 'task': 'Coding', 'isChecked': false }) so it can be saved as JSON.
  Map<String, dynamic> toMap() {
    return {'task': task, 'isChecked': isChecked};
  }

  //Convert Map back to ToDoItem
  //fromMap() → Converts the stored JSON data back into a ToDoItem object
  //Factory constructors in Dart are flexible alternatives to generative constructors. Unlike generative constructors that always return a new instance, factory constructors allow greater control over the creation of objects. They can return instances of subclasses, new instances, or even existing instances.
  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      task: map['task'],
      isChecked: map['isChecked'] ?? false,
    );
  }
}

class ListTileExample extends StatefulWidget {
  const ListTileExample({super.key});

  @override
  State<ListTileExample> createState() => _ListTileExampleState();
}

class _ListTileExampleState extends State<ListTileExample> {
  // List<Map<String, dynamic>> todo = [
  //   {'task': 'SLEEPING', 'isChecked': false},
  //   {'task': 'CODING', 'isChecked': false},
  //   {'task': 'EATING', 'isChecked': false},
  //   {'task': 'EXERCISE', 'isChecked': false},
  // ];

  // Since the to-do list can change (adding/removing tasks), it must be inside a StatefulWidget.
  List<TodoItem> todo = []; 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadTodoList();  // to load saved tasks when the app starts.
  }

  //Save to shared preferences
  //todo = [ ToDoItem(task: 'Coding', isChecked: false) ];  ===>  ["{\"task\": \"Coding\", \"isChecked\": false}"]
  Future<void> _saveTodoList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();    //SharedPreferences.getInstance() → Gets access to local storage
    List<String> todoJson = todo.map((item) => jsonEncode(item.toMap())).toList();    //Convert todo list to JSON because SharedPreferences cannot store complex objects.
    await prefs.setStringList("todoList", todoJson);    //setStringList() to save the JSON list.
  }

  //load from shared preferences
  Future<void> _loadTodoList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todoJson = prefs.getStringList('todoList');   //getStringList('todoList') → Fetches stored data.
    
    if(todoJson != null) {
      setState(() {
        todo = todoJson.map((item) => TodoItem.fromMap(jsonDecode(item))).toList();
      });
    }
  }

  void _onCheckboxChanged(int index, bool? value) {
    setState(() {
      todo[index].isChecked = value ?? false;
    });
    _saveTodoList();
  }

  void _addTask(String task) {
    setState(() {
      todo.add(TodoItem(task: task));
    });
    _saveTodoList();
  }

  void _deleteTask(int index) {
    setState(() {
      todo.removeAt(index);
    });
    _saveTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To Do List")),
      body: ListView.builder(
        itemCount: todo.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(todo[index].task),
              trailing: Checkbox(
                value: todo[index].isChecked,
                onChanged: (bool? value) {
                  _onCheckboxChanged(index, value);
                }
              ),
              onLongPress: () {
                _deleteTask(index);
              },
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
          _addTask("New Task ${todo.length + 1}");
          },
          child: const Icon(Icons.add),
        ),
    );
  }
}


// Saving Data (_saveToDoList)
// Converts ToDoItem objects into a JSON string list.
// Stores the list in shared_preferences under the key "todoList".

// Loading Data (_loadToDoList)
// Reads the saved data from shared_preferences.
// Converts JSON strings back into ToDoItem objects.

// Checkbox Click (_onCheckboxChanged)
// Updates the task's completion state.
// Saves the updated list.

// Adding & Deleting Tasks
// _addTask: Adds a new task and saves the list.
// _deleteTask: Removes a task and saves the list.