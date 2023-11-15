import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ui_todolist/models/todo.dart';

import 'CommonWidget/skeleton_loading.dart';

class TodosStatusFinishScreen extends StatefulWidget {
  final bool isFinished;

  TodosStatusFinishScreen({required this.isFinished});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodosStatusFinishScreen> {
   List<Todo> todos = [];
   int countTodos = 0;

    var res = fetchTodoFinished(http.Client());


   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor:  Color(0xFFEEEFF5),
       body: FutureBuilder<TodoResponse>(
         future: Future.delayed(const Duration(milliseconds: 500), () {
          if(widget.isFinished == true){
            return fetchTodoFinished(http.Client());
          }else {
            return fetchTodoUnFinished(http.Client());
          }
         }),
         builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
             // Xử lý trạng thái đang tải dữ liệu
             return  Container(
               padding: EdgeInsets.only(top:45),
               child: SkeletonLoading(
                 itemCount: 8, // Số lượng skeleton loading muốn hiển thị
                 itemHeight: 70, // Chiều cao của mỗi skeleton loading
                 itemWidth: 200, // Chiều rộng mặc định của mỗi skeleton loading
                 itemMargin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Khoảng cách giữa các skeleton loading
               ),
             );
           } else if (snapshot.hasError) {
             // Xử lý trường hợp lỗi
             print(snapshot);
             return Text('Error: $snapshot');
           } else if (!snapshot.hasData) {
             // Xử lý trường hợp không có dữ liệu
             return Text('Không có todo nào.');
           } else {
             if(todos.isEmpty){
               todos = snapshot.data?.todos ?? [];
               countTodos = snapshot.data!.remainingTime;
             }else {
               print(todos.length);
             }
             return Scaffold(
               backgroundColor: Color(0xFFEEEFF5),
               appBar: AppBar(backgroundColor: Colors.deepPurple,
                title: widget.isFinished == true ? Text("Danh sách todo đã hoàn thành: $countTodos items") : Text("Danh sách todo chưa hoàn thành: $countTodos items")
               ),
               body: Column(
                 children: [
                   Container(
                     color: Colors.deepPurple[300],
                     child: SizedBox(
                       height: 8,
                     ),
                   ),
                   Expanded(
                     child: SingleChildScrollView(
                       child: Column(
                         children: [

                         ],
                       ),
                     ),
                   ),
                 ],
               ),
             );
           }
         },
       ),

     );
   }
}


