import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ui_todolist/models/constGlobal.dart';

class Task {
  int id;
  String name;
  bool isFinished;
  int todoId;

  Task({required this.id, required this.name, required this.isFinished, required this.todoId});

  // static method
  factory Task.fromJson(Map<String, dynamic> json){
    return Task(
        id: json["id"],
        name: json["name"],
        isFinished: json["isFinished"],
        todoId: json["todoId"]
    );
  }

  factory Task.fromTask(Task anotherTask){
    return Task(
      id: anotherTask.id,
      name: anotherTask.name,
      isFinished: anotherTask.isFinished,
      todoId: anotherTask.todoId
    );
  }

}

Future<List<Task>> fetchTasksByIdTodo(http.Client client, int idTodo) async {
  final response = await client.get(Uri.parse("$URL_TASKS/GetAll/?idTodo=$idTodo"));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    print('gọi lại nè');
    print(data);
    print(response);
    if (data is List) {
      final tasks = data.map((json) => Task.fromJson(json)).toList();
      return tasks;
    } else {
      throw Exception('Invalid data format from the API');
    }
  } else {
    throw Exception('Failed to connect to the API');
  }
}

Future<Task> fetchTaskById(http.Client client, int id) async {
  final response = await client.get(Uri.parse("$URL_TASKS/GetOne/?id=$id"));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (data != null) {
      final task = Task.fromJson(data);
      return task;
    } else {
      throw Exception('Invalid data format from the API');
    }
  } else {
    throw Exception('Failed to connect to the API');
  }
}

// update task
Future<bool> update(http.Client client,  params) async {
  final response = await client.put(Uri.parse("$URL_TASKS/Update?i=${params['i']}&Name=${params['Name']}&IsFinished=${params['IsFinished']}&TodoId=${params['TodoId']}"));
  print("i=${params['i']}&Name=${params['Name']}&IsFinished=${params['IsFinished']}&TodoId=${params['TodoId']}");
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
    throw Exception('Failed to connect to the API');
  }
}

//delete
Future<String> deleteTask(http.Client client, int idTask) async {

  final response = await client.delete(Uri.parse("$URL_TASKS/Delete?id=$idTask"));
  if (response.statusCode == 200) {
    return response.body;
  }
  else {
    throw Exception('Invalid data format from the API');
  }
}

// create
Future<bool> createTask(http.Client client,  String name, int idTodo) async {
  final response = await client.post(Uri.parse("$URL_TASKS/Post?Name=$name&TodoId=$idTodo"));
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
    throw Exception('Failed to connect to the API');
  }
}

