import 'package:flutter/material.dart';
import 'package:ui_todolist/Hooks/dayRemain.dart';
import 'package:ui_todolist/models/todo.dart';
import 'package:intl/intl.dart';

class ToDoItem extends StatefulWidget {
  final Todo todo;
  final onToDoChanged;
  final onDeleteItem;
  final int Priority;

  ToDoItem({
    Key? key,
    required this.todo,
    required this.Priority,
    required this.onToDoChanged,
    required this.onDeleteItem,
  }) : super(key: key);

  @override
  _ToDoItemState createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  bool isHovered = false;

  // func hiển thị màu theo ngày hết hạn
  Color getColorForTodoItem(Todo todo) {
    int daysRemaining = calculateDaysRemaining(todo.dueDate.toString());

    if (daysRemaining < 4 && todo.priority == 1) {
      return  Colors.red;
    } else {
      return Colors.blue;
    }
  }

  //xác nhận
  Future<void> _confirmDelete(BuildContext context, int id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thông báo'),
          content: Text('Bạn có muốn xóa item "${widget.todo.name}" không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                widget.onDeleteItem(id);
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    int Priority = widget.Priority;
    String formattedFullDate =
    DateFormat.yMMMd().format(DateTime.parse(widget.todo.dueDate));

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHovered = false;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: ListTile(
          onTap: () {
            widget.onToDoChanged(widget.todo);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          tileColor: Colors.white,
          title: Row(
            children: <Widget>[
              IconButton(
                icon: Priority == 1 ? Icon(Icons.star) : Icon(Icons.star_border),
                color: Priority == 1 ? Colors.yellow : Colors.blueGrey,
                onPressed: () {
                  // Xử lý khi nhấn vào biểu tượng sao
                },
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      isHovered ? widget.todo.name :
                      widget.todo.name.length > 26
                          ? widget.todo.name.substring(0, 26) + '...'
                          : widget.todo.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.only(top: 1),
                    child: Text(
                      'Deadline: $formattedFullDate - daysUntilDue: ${calculateDaysRemaining((widget.todo.dueDate).toString())}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: getColorForTodoItem(widget.todo),
    ),
                    ),
                  )
                ],
              ),
            ],
          ),
          trailing: Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              color: Colors.white,
              iconSize: 25,
              icon: Icon(Icons.delete),
              onPressed: () {
                _confirmDelete(context,widget.todo.id);
              },
            ),
          ),
        ),
      ),
    );
  }
}
