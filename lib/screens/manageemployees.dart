import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/database.dart';
import '../models/employee.dart';
import './addEmployee.dart';
import './editEmployee.dart';
import '../widgets/customAppBar.dart';

class ManageEmployees extends StatefulWidget {
  final String _username;
  const ManageEmployees(this._username);
  @override
  _ManageEmployeesState createState() => _ManageEmployeesState();
}

class _ManageEmployeesState extends State<ManageEmployees> {
  List<Employee> _employeesList = [];
  List<Employee> _employeesCopy = [];
  bool _fetchedData = false;
  bool _showSearchBar = false;
  String _searchText = 'Show';
  TextEditingController _searchController = TextEditingController();

  Future<void> _getAllEmployees(BuildContext context) async {
    String _shopLocation;

    if (widget._username.toLowerCase().startsWith('a')) {
      _shopLocation = widget._username.substring(1, 2).toUpperCase();
    } else {
      _shopLocation = widget._username.substring(2, 3).toUpperCase();
    }

    await databaseReference
        .child(_shopLocation)
        .child('Employees')
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> results = snapshot.value;
      results.forEach((id, details) {
        setState(() {
          _employeesList.add(Employee(
              id: id,
              name: details['Name'],
              number: details['Number'].toString(),
              adminPriv: details['Admin Privilege'],
              age: details['Age'].toString(),
              lastActivity: details['Last Activity'].toString()));
        });
      });
      _employeesCopy.addAll(_employeesList);
      setState(() {
        _fetchedData = true;
      });
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

  void _addEmployees() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddEmployee()));
  }

  void _editEmployee(int index) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => EditEmployee(_employeesList[index])));
  }

  void _searchInEmployees(String searchedEmployee) {
    List<Employee> dummySearchList = [];
    dummySearchList.addAll(_employeesCopy);
    if (searchedEmployee.isNotEmpty) {
      List<Employee> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.name.toLowerCase().contains(searchedEmployee.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _employeesList.clear();
        _employeesList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _employeesList.clear();
        _employeesList.addAll(_employeesCopy);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllEmployees(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButtonLocation:
          !_fetchedData ? null : FloatingActionButtonLocation.centerDocked,
      floatingActionButton: !_fetchedData
          ? null
          : FloatingActionButton(
              child: const Icon(
                Icons.add_box_outlined,
                color: Colors.white,
              ),
              onPressed: _addEmployees,
            ),
      bottomNavigationBar: !_fetchedData
          ? null
          : BottomAppBar(
              color: Theme.of(context).primaryColor,
              shape: CircularNotchedRectangle(),
              notchMargin: 2.0,
              elevation: 5,
              child: new Row(
                children: <Widget>[
                  Container(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).scaffoldBackgroundColor),
                      label: Text(_searchText),
                      icon: Icon(
                        Icons.search_outlined,
                      ),
                      onPressed: () {
                        if (_showSearchBar) {
                          setState(() {
                            _showSearchBar = false;
                            _searchText = 'Show';
                          });
                        } else {
                          setState(() {
                            _showSearchBar = true;
                            _searchText = 'Hide';
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
      body: !_fetchedData
          ? SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: FittedBox(
                          fit: BoxFit.contain,
                          child: const Text('Please Wait..')))
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  CustomAppBar(
                      title: 'Manage Employees',
                      subtitle: 'Edit, Add or Remove Employees!'),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => WidgetsBinding
                          .instance.focusManager.primaryFocus
                          ?.unfocus(),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (_showSearchBar)
                              Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                      top: 10, right: 10, left: 10, bottom: 5),
                                  child: Card(
                                    child: new ListTile(
                                      leading: new Icon(Icons.search),
                                      title: new TextField(
                                        controller: _searchController,
                                        decoration: new InputDecoration(
                                            hintText: 'Search',
                                            border: InputBorder.none),
                                        onChanged: (searchedEmployee) =>
                                            _searchInEmployees(
                                                searchedEmployee),
                                      ),
                                      trailing: new IconButton(
                                        icon: new Icon(Icons.cancel),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _employeesList.clear();
                                            _employeesList
                                                .addAll(_employeesCopy);
                                          });
                                        },
                                      ),
                                    ),
                                  )),
                            Container(
                              height: _showSearchBar
                                  ? screenMaxHeight * 0.65
                                  : screenMaxHeight * .75,
                              child: ListView.builder(
                                padding: EdgeInsets.all(0.0),
                                itemCount: _employeesList.length == null
                                    ? 0
                                    : _employeesList.length,
                                itemBuilder: (context, index) {
                                  return CartItem(
                                      editEmployee: _editEmployee,
                                      employeesList: _employeesList,
                                      index: index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class CartItem extends StatelessWidget {
  const CartItem({
    Key key,
    @required this.employeesList,
    @required this.index,
    @required this.editEmployee,
  }) : super(key: key);

  final List<Employee> employeesList;
  final int index;
  final Function(int index) editEmployee;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: Card(
          elevation: 5,
          child: Stack(
            children: <Widget>[
              Container(
                margin:
                    EdgeInsets.only(left: 5, right: 16, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          color: Colors.blue.shade200,
                          image: DecorationImage(
                              image: AssetImage("assets/images/logo.png"))),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.only(right: 8, top: 4),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  employeesList[index].name,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      "ID: ${employeesList[index].id}",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      flex: 100,
                    )
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(right: 15, top: 8),
                    child: Container(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: Icon(
                          Icons.edit_sharp,
                          color: Colors.white,
                          size: 15,
                        ),
                        onPressed: () {
                          editEmployee(index);
                        },
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Theme.of(context).accentColor),
                    ),
                  ))
            ],
          )),
    );
  }
}
