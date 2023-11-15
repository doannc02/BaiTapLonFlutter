import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ui_todolist/CommonWidget/skeleton_loading.dart';
import 'package:ui_todolist/models/todo.dart';
import 'TaskScreen.dart';
import 'CommonWidget/todo_item.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  int _currentIndex = 0;
  int countItemsStatus = 0;
  List<Todo> todos = [];
  bool showNoResults = false;
  bool showSearchBar = false;
  bool isShowContent = false;

  final _todoController = TextEditingController();

  void _refreshData() async {
    final updatedTodos = await fetchListTodos(http.Client());
    setState(() {
      todos = updatedTodos;
    });
  }
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    _currentIndex = 0;
     _refreshData();
    super.initState();
    _focusNode.requestFocus();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xFFEEEFF5),
      appBar: showSearchBar == true ? searchBox() : _buildAppBar(),
      drawer: _buildDrawer(),
      body: FutureBuilder<List<Todo>>(
        future: Future.delayed(const Duration(milliseconds: 500), () {
           if(_currentIndex == 0) {
                return fetchListTodos(http.Client());
           }else return [];

        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Xử lý trạng thái đang tải dữ liệu
            return Container(
              padding: const EdgeInsets.only(top: 8),
              child: SkeletonLoading(
                itemCount: 6,
                // Số lượng skeleton loading muốn hiển thị
                itemHeight: 70,
                // Chiều cao của mỗi skeleton loading
                itemWidth: 200,
                // Chiều rộng mặc định của mỗi skeleton loading
                itemMargin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16), // Khoảng cách giữa các skeleton loading
              ),
            );
          } else if (snapshot.hasError) {
            // Xử lý trường hợp lỗi
            print(snapshot);
            return Center(child: Text("Kết nối thất bại đến server!!!"),);
          } else if (!snapshot.hasData) {
            // Xử lý trường hợp không có dữ liệu
            return const Text('Không có todo nào.');
          } else {
            if (todos.isEmpty) {
              todos = snapshot.data ?? [];
            } else {
              print(todos.length);
            }
            return Scaffold(
              backgroundColor: const Color(0xFFEEEFF5),
              body: Column(
                children: [
                  Container(
                    color: Colors.deepPurple[300],
                    child: const SizedBox(
                      height: 8,
                    ),
                  ),
                  Expanded(
                    child: isShowContent == true
                        ? const Text("Nhập từ khóa tìm kiếm")
                        : showNoResults == true
                            ? const Text("Không tìm thấy item nào")
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                      for (Todo todoo in todos)
                                        ToDoItem(
                                          todo: todoo,
                                          Priority: todoo.priority,
                                          onToDoChanged: _handleToDoChange,
                                          onDeleteItem: _deleteToDoItem,
                                        )
                                  ],

                                ),
                              ),
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                items: [
                  const BottomNavigationBarItem(
                      tooltip: "All todos",
                      icon: Icon(Icons.library_books_rounded, color: Colors.deepPurple),
                      label: "All todos"),
                  const BottomNavigationBarItem(
                      tooltip: "Item chưa hoàn thành",
                      icon:
                      Icon(Icons.star_border_outlined, color: Colors.black),
                      label: "Finished"),
                  const BottomNavigationBarItem(
                      tooltip: "Item đã hoàn thành",
                      icon: Icon(Icons.star, color: Colors.yellow),
                      label: "UnFinished"),

                ],
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (_currentIndex == 2) {
                    _fetchTodosFinished(false);
                  } else if (_currentIndex == 1) {
                    _fetchTodosFinished(true);
                  }else _refreshData();
                },
              ),
            );
          }
        },
      ),
    ));
  }

  void _fetchTodosFinished(bool isFinished) async {
    if (isFinished) {
      var res = await fetchTodoFinished(http.Client());
      setState(() {
        todos = res.todos;
      });
    } else {
      var res = await fetchTodoUnFinished(http.Client());
      setState(() {
        todos = res.todos;
      });
    }
  }

  void _showAddTodoModal(BuildContext context) {
    DateTime? selectedDate;
    String todoText = '';
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                width: MediaQuery.of(context).size.width, // Sử dụng chiều rộng của màn hình
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  // Đặt border
                  borderRadius:
                      BorderRadius.circular(10.0), // Điều chỉnh góc bo tròn
                ),
                padding: const EdgeInsets.all(16),
               child:Expanded (

                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,

                   children: <Widget>[
                     Text("Add new Todo item"),
                     SizedBox(height: 11,),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Expanded(
                           child: Container(
                             child: TextField(
                               onChanged: (value) {
                                 todoText = value;
                               }, focusNode: _focusNode,
                               controller: _todoController,
                               decoration: InputDecoration(
                                 hintText: 'Name of item...',
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
                           ),
                         ),
                         SizedBox(width: 16), // Khoảng cách giữa hai Container
                         Expanded(
                           child: Container(
                             height: 55,
                             decoration: BoxDecoration(
                               border: Border.all(color: Colors.grey, width: 1.0),
                               borderRadius: BorderRadius.circular(20.0),
                             ),
                             child: Row(
                               children: [
                                 SizedBox(width: 10),
                                 Text(
                                   selectedDate != null
                                       ? DateFormat.yMMMd().format(selectedDate!)
                                       : 'Select duedate',
                                   style: const TextStyle(fontSize: 16),
                                 ),
                                 SizedBox(width: 5),
                                 IconButton(
                                   icon: const Icon(Icons.date_range),
                                   onPressed: () async {
                                     final DateTime? picked = await showDatePicker(
                                       context: context,
                                       initialDate: DateTime.now(),
                                       firstDate: DateTime.now(),
                                       lastDate: DateTime(2101),
                                     );
                                     if (picked != null) {
                                       setState(() {
                                         selectedDate = picked;
                                       });
                                     }
                                   },
                                 ),
                               ],
                             ),
                           ),
                         ),
                       ],
                     ),
                      SizedBox(height: 30,),
                     Container(
                       height: 45,
                       child: Expanded(
                           child: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                                 primary: Colors.deepPurple,
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(20),
                                 ),
                                 minimumSize: Size.fromHeight(6)
                             ),
                             onPressed: () async {
                               if (_todoController.text == "") {
                                 Fluttertoast.showToast(
                                     msg: "Tên item không được để trống!",
                                     toastLength: Toast.LENGTH_LONG,
                                     gravity: ToastGravity.TOP,
                                     backgroundColor: Colors.red,
                                     textColor: Colors.white,
                                     timeInSecForIosWeb: 2,
                                     fontSize: 18);
                               } else if (selectedDate == null) {
                                 Fluttertoast.showToast(
                                     msg: "Hãy chọn 1 dealine!",
                                     toastLength: Toast.LENGTH_LONG,
                                     gravity: ToastGravity.TOP,
                                     backgroundColor: Colors.red,
                                     textColor: Colors.white,
                                     timeInSecForIosWeb: 2,
                                     fontSize: 18);
                               } else {
                                 int prirority = 1;
                                 DateTime currentDateTime =
                                 DateTime.parse(selectedDate.toString());
                                 var date = DateFormat('yyyy-MM-ddTHH:mm:ss')
                                     .format(currentDateTime);
                                 String todoText = _todoController.text;
                                 Map<String, dynamic> params = {
                                   'name': todoText,
                                   'priority': prirority,
                                   'description': ' ',
                                   'dueDate': date,
                                 };
                                 final response =
                                 await create(http.Client(), params);
                                 if (response) {
                                   Fluttertoast.showToast(
                                       msg: "Tạo mới item thành công!",
                                       toastLength: Toast.LENGTH_LONG,
                                       gravity: ToastGravity.TOP,
                                       backgroundColor: Colors.green,
                                       textColor: Colors.white,
                                       timeInSecForIosWeb: 2,
                                       fontSize: 18);
                                   _todoController.text = '';
                                   selectedDate = null;
                                   _refreshData();
                                 } else {
                                   Fluttertoast.showToast(
                                       msg: "Lỗi khi tạo item.",
                                       toastLength: Toast.LENGTH_LONG,
                                       gravity: ToastGravity.TOP,
                                       backgroundColor: Colors.red,
                                       textColor: Colors.white,
                                       timeInSecForIosWeb: 2,
                                       fontSize: 18);
                                 }
                                 Navigator.pop(context);
                               }
                             },
                             child: const Text(
                               'Save',
                               style: TextStyle(
                                 fontSize: 16,
                                 color: Colors.white,
                               ),
                             ),
                           )
                       ),
                     ),
                   ],
                 ),
               ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleToDoChange(Todo todo) async {
    setState(() {
      //  todo.isDone = !todo.isDone;
    });
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TaskScreen(
                  todoId: todo.id,
                  todoName: todo.name,
                  priority: todo.priority,
                  currentIndexPage: _currentIndex,
                ))).then((result) {
      _refreshData();
      print('đây này 2');
      print(result['todos']);
      print(result['priority']);
      return result;
    });

  }

  void _deleteToDoItem(int id) {
    deleteItem(http.Client(), id).then((result) {
      if (result != "") {
        Fluttertoast.showToast(
            msg: 'Xóa item "$result" thành công!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            timeInSecForIosWeb: 2,
            fontSize: 18);
        setState(() {
          if(_currentIndex == 0){
            _refreshData();
          }else if(_currentIndex == 2){
            _fetchTodosFinished(false);
          }else _fetchTodosFinished(true);
        });
      }
    });
  }

  void _runFilter(String enteredKeyword) async {
    List<Todo> results = await searchItems(http.Client(), enteredKeyword);
    print(enteredKeyword);
    isShowContent = false;
    if (results.isNotEmpty) {
      showNoResults = false;
    } else {
      showNoResults = true;
    }
    setState(() {
      todos = results;
    });
  }

  PreferredSizeWidget searchBox() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: SingleChildScrollView(
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black, // Màu của border
                width: 1.0, // Độ dày của border
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () async {
                    List<Todo> results = await searchItems(http.Client(), " ");
                    if (results.toList().isNotEmpty) {
                      todos = results;
                    }
                    setState(() {
                      isShowContent = false;
                      showSearchBar = false;
                      showNoResults = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_back_outlined)),
              Container(
                child: const SizedBox(
                  height: 5,
                ),
              ),
              Container(
                height: 48,
                width: 343,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  onChanged: (value) {
                    _runFilter(value);
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF3A3A3A),
                      size: 25,
                    ),
                    prefixIconConstraints: BoxConstraints(
                      maxHeight: 55,
                      minWidth: 35,
                    ),
                    border: InputBorder.none,
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Color(0xFF717171)),
                  ),
                ),
              ),
              Container(
                child: const SizedBox(
                  height: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Nguyễn Công Đoàn"),
            accountEmail: const Text("sillver47108@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Container(
                height: 50,
                width: 50,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                        'https://i.ytimg.com/vi/W8Fs0BAv9bQ/maxresdefault.jpg')),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.library_add_check_rounded),
            title: const Text("Các danh mục đã hoàn thành"),
            onTap: () {
              // Xử lý khi chọn danh mục 2
            },
          ),
          ListTile(
            leading: const Icon(Icons.pending_actions),
            title: const Text("Các danh mục cần thực hiện"),
            onTap: () {
              // Xử lý khi chọn danh mục 2
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Cài đặt tài khoản."),
            onTap: () {
              // Xử lý khi chọn danh mục 1
            },
          ),
          // Thêm danh sách các mục menu khác ở đây
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 200.0,
                    child: Text(
                          () {
                        if (_currentIndex == 0) {
                          return 'Alls Todos: ${todos.length} items';
                        } else if(_currentIndex == 1) {
                          return 'Finished: ${todos.length} items';
                        }else return 'UnFinished: ${todos.length} items';
                      }()
                  ),),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _showAddTodoModal(context);
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(70),
                          color: Colors.black26,
                        ),
                        height: 32,
                        width: 32,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showSearchBar = true;
                          isShowContent = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(70),
                            color: Colors.black26),
                        height: 32,
                        width: 32,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: const Icon(Icons.search_rounded)),
                      ),
                    ),
                  ),
                  // Thêm các phần tử khác theo nhu cầu của bạn.
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(70),
                        color: Colors.black26),
                    height: 30,
                    width: 30,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                            'https://i.ytimg.com/vi/W8Fs0BAv9bQ/maxresdefault.jpg')),
                  ),
                ]),
          )
        ]));
  }
}
/*
* */
