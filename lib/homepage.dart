import 'package:coba_sqlite/sql_helper.dart';
import 'package:coba_sqlite/main.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  var myData = [];

  String? validateTextField(String? value) {
    if (value!.isEmpty) {
      return "Field is required";
    }
    return null;
  }

  bool _isLoading = true;

  void _refreshData() async {
    final data = await DatabaseHelper.getItems();
    setState(() {
      myData = data;
      _isLoading = false;
    });
  }

  Future<void> addItem() async {
    await DatabaseHelper.createItem(
        _titleController.text, _descController.text);
    _refreshData();
  }

  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(
        id, _titleController.text, _descController.text);
    _refreshData();
  }

  void deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);
    if(context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Record Successfuly Deleted"),
        backgroundColor: Colors.red,
      ));
    }
    _refreshData();
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Journal"),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(MyApp.themeNotifier.value == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode),
                onPressed: () {
                  MyApp.themeNotifier.value =
                      MyApp.themeNotifier.value == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                })
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : myData.isEmpty
                ? const Center(
                    child: Text(
                    "No Data Available",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))
                : ListView.builder(
                    itemCount: myData.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        margin: const EdgeInsets.all(15),
                        color:
                            index % 2 == 0 ? Colors.amber : Colors.amber[300],
                        child: ListTile(
                          title: Text(myData[index]['title']),
                          subtitle: Text(myData[index]['description']),
                          textColor: Colors.black,
                          iconColor: Colors.black,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () =>
                                      showMyForm(myData[index]['id']),
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () =>
                                      deleteItem(myData[index]['id']),
                                  icon: const Icon(Icons.delete)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showMyForm(null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void showMyForm(int? id) async {
    if (id != null) {
      final existingData = myData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['description'];
    } else {
      _titleController.text = "";
      _descController.text = "";
    }

    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        isDismissible: true,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                right: 15,
                left: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      validator: validateTextField,
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: "Title",
                      ),
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.none,
                      validator: validateTextField,
                      controller: _descController,
                      decoration: const InputDecoration(
                        hintText: "Description",
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                if (id != null) {
                                  await updateItem(id);
                                } else {
                                  addItem();
                                }
                                if(context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                              setState(() {
                                _titleController.text = "";
                                _descController.text = "";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: Text(id == null ? "Create" : "Update"),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}
