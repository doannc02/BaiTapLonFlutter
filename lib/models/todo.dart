import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './constGlobal.dart';

class Todo{
  final int id;
  final String name;
  final int priority;
  final String description;
  final String dueDate;
  // constructor Todo
  Todo({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.description,
    required this.priority
});

  // static method
factory Todo.fromJson(Map<String, dynamic> json){
  return Todo(
    id: json["id"],
    name: json["name"],
    dueDate: json["dueDate"],
    description: json["description"],
    priority: json["priority"]
  );
}

}

class TodoResponse {
  final List<Todo> todos;
  final int remainingTime;

  TodoResponse({
    required this.todos,
    required this.remainingTime,
  });

  factory TodoResponse.fromJson(Map<String, dynamic> json) {
    return TodoResponse(
      todos: List<Todo>.from(json['todos'].map((todo) => Todo.fromJson(todo))),
      remainingTime: json['remainingTime'],
    );
  }
}

// fetch list todo UnFinished from API
Future<TodoResponse> fetchTodoUnFinished(http.Client client) async {
  final response = await client.get(Uri.parse("$URL_TODOS/get-todos-un-finished"));
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = json.decode(response.body);
    TodoResponse todoResponse = TodoResponse.fromJson(jsonData);
    print(response);
    return todoResponse;
  } else {
    throw Exception('Failed to connect to the API');
  }
}

// fetch list todo isFinished from API
Future<TodoResponse> fetchTodoFinished(http.Client client) async {
  final response = await client.get(Uri.parse("$URL_TODOS/get-todos-finished"));
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = json.decode(response.body);
    TodoResponse todoResponse = TodoResponse.fromJson(jsonData);
    print(response);
    return todoResponse;
  } else {
    throw Exception('Failed to connect to the API');
  }
}

// fetch data from API
Future<List<Todo>> fetchListTodos(http.Client client) async {
  final response = await client.get(Uri.parse("$URL_TODOS/GetAll"));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
  print(data);
  print(response);
    if (data is List) {
      final todos = data.map((json) => Todo.fromJson(json)).toList();
      return todos;
    } else {
      throw Exception('Invalid data format from the API');
    }
  } else {
    throw Exception('Failed to connect to the API');
  }
}

// fetch data from API
Future<String> updatePriorityTodo(http.Client client, int priority, int idTodo) async {
  final response = await client.put(Uri.parse("$URL_TODOS/update-finished-status?priority=$priority&idTodo=$idTodo"));
  if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Invalid data format from the API');
    }
}

// search
Future<List<Todo>> searchItems(http.Client client, String keyWord) async {
  final Uri uri = Uri.parse("$URL_TODOS/search?keyWord=$keyWord");

  try {
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      if (data is List) {
        final todos = data.map((json) => Todo.fromJson(json)).toList();
        return todos;
      } else {
        throw Exception('Invalid data format from the API');
      }
    } else {
      throw Exception('Failed to connect to the API');
    }
  } catch (e) {
    throw Exception('An error occurred: $e');
  }
}
//delete
Future<String> deleteItem(http.Client client, int idTodo) async {
  print(idTodo);
  final response = await client.delete(Uri.parse("$URL_TODOS/Delete?id=$idTodo"));
  if (response.statusCode == 200) {
    return response.body;
  }
  else {
    throw Exception('Invalid data format from the API');
  }
}

// create a new todo
Future<bool> create(http.Client client, Map<String, dynamic> params) async {
  print(params);
  final response = await client.post(Uri.parse("$URL_TODOS/Post"), headers: {"Content-Type": "application/json"},
      body: jsonEncode(params));
  if (response.statusCode == 200) {
    final responseText = response.body.toLowerCase();
    if (responseText == "success") {
      // Nếu response là "success", cập nhật thành công
      return true;
    } else {
      // Nếu response là "error" hoặc bất kỳ giá trị khác, xem như cập nhật không thành công
      return false;
    }
  } else {
    // Xử lý trường hợp lỗi kết nối hoặc lỗi server
    print(response.statusCode);
    throw Exception('Failed to connect to the API');
  }
}

