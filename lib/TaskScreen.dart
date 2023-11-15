import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ui_todolist/DetailTaskScreen.dart';
import 'package:ui_todolist/models/todo.dart';
import './models/task.dart';

class TaskScreen extends StatefulWidget {
  final int todoId;
  final int? currentIndexPage;
  final String todoName;
  int priority;

  TaskScreen(
      {required this.todoId,
      required this.todoName,
      required this.priority,
      this.currentIndexPage})
      : super();

  @override
  State<StatefulWidget> createState() {
    return _TaskScreenState();
  }
}

class _TaskScreenState extends State<TaskScreen> {
  List<Task> tasks = [];
  final _taskEditing = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initFunc();
  }

  void _initFunc() async {
    final res = await fetchTasksByIdTodo(http.Client(), widget.todoId);
    if (res.isEmpty) {
      widget.priority = 1;
      updatePriorityTodo(http.Client(), widget.priority, widget.todoId);
    } else {
      setState(() {
        tasks = res;
      });
    }
  }

  void updatePriority(List<Task> task) async {
    if (tasks.every((task) => task.isFinished == true)) {
      widget.priority = 2;
      await updatePriorityTodo(http.Client(), widget.priority, widget.todoId);
    } else {
      widget.priority = 1;
      await updatePriorityTodo(http.Client(), widget.priority, widget.todoId);
    }
  }

  void _showAddTaskModal(BuildContext context) {
    String taskText = '';
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  width: double.infinity,
                  height: 200,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Add a new task item',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            taskText = value;
                          });
                        },
                        controller: _taskEditing,
                        decoration:
                            InputDecoration(hintText: 'Name of task...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),

                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                padding: EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepPurple,
                              padding: EdgeInsets.only(top: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () async {
                              if (_taskEditing.text == "") {
                                Fluttertoast.showToast(
                                    msg: "Tên item không được để trống!",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.TOP,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    timeInSecForIosWeb: 2,
                                    fontSize: 18);
                              } else {
                                String taskText = _taskEditing.text;
                                final response = await createTask(
                                    http.Client(), taskText, widget.todoId);
                                if (response) {
                                  Fluttertoast.showToast(
                                      msg: "Tạo mới task thành công!!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.TOP,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      timeInSecForIosWeb: 2,
                                      fontSize: 18);
                                  _taskEditing.text = '';
                                  final res = await fetchTasksByIdTodo(
                                      http.Client(), widget.todoId);
                                  print(res.toList());
                                  setState(() {
                                    tasks = res.toList();
                                    updateTaskList(tasks);
                                  });
                                }
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ))
                        ],
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Task: ${widget.todoName} ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              print(widget.currentIndexPage);
              print('dây này');
              if (widget.currentIndexPage == 1) {
                final res = await fetchTodoUnFinished(http.Client());
                Navigator.of(context).pop({'todos': res.todos, 'priority': widget.currentIndexPage});

              } else if (widget.currentIndexPage != 1) {
                final res = await fetchTodoFinished(http.Client());
                Navigator.of(context).pop({'todos': res.todos, 'priority': widget.currentIndexPage});
              }
            },
          ),
          actions: <Widget>[
            IconButton(
              color: widget.priority == 1 ? Colors.yellowAccent : Colors.white,
              icon: Icon(Icons.star), // Icon ngôi sao
              onPressed: () async {
                print(widget.currentIndexPage);
                // Xử lý khi nhấn vào biểu tượng sao
                if (widget.currentIndexPage == 1) {
                  final res = await fetchTodoUnFinished(http.Client());
                  Navigator.of(context).pop(res.todos);
                } else if (widget.currentIndexPage != 1) {
                  final res = await fetchTodoFinished(http.Client());
                  Navigator.of(context).pop(res.todos);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Xử lý khi nhấn vào biểu tượng thêm
                _showAddTaskModal(context);
              },
            ),
          ],
        ),
        body: Container(
          margin: EdgeInsets.only(top: 14),
          child: TaskList(tasks: tasks, updateTaskList: updateTaskList),
        ));
  }

  void updateTaskList(List<Task> updatedTasks) {
    setState(() {
      tasks = updatedTasks;
      updatePriority(tasks);
    });
  }
}

class TaskList extends StatelessWidget {
  List<Task> tasks;
  final Function(List<Task>) updateTaskList;

  TaskList({Key? key, required this.tasks, required this.updateTaskList})
      : super(key: key);

//method xac nhan xoa
  Future<bool> _confirmDelete(
      BuildContext context, int id, int todoId, String name) async {
    // Hiển thị hộp thoại xác nhận và chờ người dùng xác nhận
    bool userConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa?"),
          content: Text('Bạn có chắc chắn muốn xóa task "$name" không?'),
          actions: <Widget>[
            TextButton(
              child: Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop(false); // Không xóa
              },
            ),
            TextButton(
              child: Text("Xóa"),
              onPressed: () async {
                // Thực hiện xóa tại đây nếu người dùng đã xác nhận
                final del = await deleteTask(http.Client(), id);
                Fluttertoast.showToast(
                    msg: 'Xóa task "$del" thành công!',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    timeInSecForIosWeb: 2,
                    fontSize: 18);
                final res = await fetchTasksByIdTodo(http.Client(), todoId);
                updateTaskList(res.toList());
                Navigator.of(context).pop(true); // Đã xóa
              },
            ),
          ],
        );
      },
    );

    return userConfirmed;
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
          padding: EdgeInsets.only(left: 20.0),
          child: (Text('Chưa triển khai nhiệm vụ nào.',
              style: TextStyle(fontSize: 15.0, color: Colors.amber))));
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5),
                decoration: BoxDecoration(
                  color: tasks[index].isFinished == true
                      ? Color.fromRGBO(230, 230, 250, 1)
                      : Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(17),
                ),
                //color: index % 2 == 0 ? Colors.deepPurpleAccent : Colors.deepPurple,
                child: Dismissible(
                  key: Key(tasks[index].id.toString()),
                  background: Container(
                    width: 60,
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    bool shouldDismiss = await _confirmDelete(
                        context,
                        tasks[index].id,
                        tasks[index].todoId,
                        tasks[index].name);
                    return shouldDismiss;
                  },
                  onDismissed: (direction) {
                    tasks.removeAt(index);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            IconButton(
                              color: tasks[index].isFinished == true
                                  ? Colors.green
                                  : Colors.red,
                              iconSize: 23,
                              icon: Icon(tasks[index].isFinished == true
                                  ? Icons.check_circle
                                  : Icons.pending_actions),
                              onPressed: () {
                                // Thực hiện một hành động khác khi nhấn vào biểu tượng.
                              },
                            ),
                            Expanded(
                              child: Text(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                tasks[index].name.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            onTap: () async {
              int selectId = tasks[index].id;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailTaskScreen(id: selectId),
                ),
              );
              if (result != null) {
                updateTaskList(result as List<Task>);
              }
            },
          );
        },
        itemCount: tasks.length,
      );
    }
  }
}
