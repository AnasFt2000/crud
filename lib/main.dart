import 'dart:io';
import 'package:crud/contact.dart';
import 'package:crud/database_helper.dart';
import 'package:crud/utility.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SQLite CRUD'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Contact _contact = Contact();
  List<Contact> _contacts = [];
  DatabaseHelper _dbHelper;
  final _formKey = GlobalKey<FormState>();
  final _ctrlName = TextEditingController();
  final _ctrlMobile = TextEditingController();
  final _ctrlAddress = TextEditingController();
  final _ctrlBirthday = TextEditingController();
  final ctrlSearch = TextEditingController();

  var maleCountVar = 0;
  var femaleCountVar = 0;
  var contactsCountVar = 0;
  @override
  void initState() {
    super.initState();

    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _refreshContactList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _form(),
              TextButton(
                onPressed: () => _list(),
                child: Text('Show All Contacts'),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.account_circle_outlined,
                size: 50.0,
              ),
              title: Text(
                "Male Contact Count : ${maleCountVar.toString()}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle_outlined,
                size: 50.0,
              ),
              title: Text(
                "Female Contact Count : ${femaleCountVar.toString()}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle_outlined,
                size: 50.0,
              ),
              title: Text(
                "Count Of Contacts : ${contactsCountVar.toString()}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _birthdayVar;
  String _dropDownValue = 'Male';
  fromMap(Map<String, dynamic> map) {
    for (var item in map[Contact.colName]) {
      names.add(item);
    }
  }

  _form() => Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ctrlName,
                enableSuggestions: true,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                ),
                autofillHints: [AutofillHints.name],
                keyboardType: TextInputType.text,
                onSaved: (val) => setState(() => _contact.name = val),
                validator: (val) =>
                    (val.length == 0 ? 'This Field Is Required' : null),
              ),
              TextFormField(
                controller: _ctrlMobile,
                enableSuggestions: true,
                decoration: InputDecoration(labelText: 'Mobile'),
                autofillHints: [AutofillHints.telephoneNumberNational],
                keyboardType: TextInputType.number,
                onSaved: (val) => setState(() => _contact.mobile = val),
                validator: (val) => (val.length < 10 || val.length > 10
                    ? 'Phone Number must be 10 character'
                    : null),
              ),
              TextFormField(
                controller: _ctrlAddress,
                enableSuggestions: true,
                decoration: InputDecoration(labelText: 'Address'),
                autofillHints: [AutofillHints.postalAddress],
                keyboardType: TextInputType.text,
                onSaved: (val) => setState(() => _contact.address = val),
                validator: (val) =>
                    (val.length == 0 ? 'This Field Is Required' : null),
              ),
              TextFormField(
                controller: _ctrlBirthday,
                enableSuggestions: true,
                decoration: InputDecoration(
                  labelText: 'Birthday',
                ),
                onTap: () => _addBirthday(),
                onSaved: (val) =>
                    setState(() => _contact.birthday = _birthdayVar),
                readOnly: true,
                validator: (val) =>
                    (val.length == 0 ? 'This Field Is Required' : null),
              ),
              DropdownButton<String>(
                value: _dropDownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (newValue) {
                  _addGender(newValue);
                },
                items: <String>['Male', 'Female']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Color(0xffFDCF09),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              _image,
                              width: 100,
                              height: 100,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(50)),
                            width: 100,
                            height: 100,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () => _onSubmit(),
                        child: Text('Submit'),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      );
  File _image;
  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  List<String> names = [];
  List<String> mobile = [];
  List<String> address = [];
  List<String> birthday = [];
  autoComplete() async {
    Database db = await _dbHelper.database;
    List<Map> x = await db.rawQuery(
        "select name,mobile,address,birthday from contacts group by name,mobile,address,birthday");
    for (var item in x) {
      names.add(item['name']);
      mobile.add(item['mobile']);
      address.add(item['address']);
      birthday.add(item['birthday']);
    }
  }

  _addGender(var value) {
    setState(() {
      _dropDownValue = value;
    });
    _dropDownValue = value;
  }

  _addBirthday() async {
    DateTime temp = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select a date',
    );
    _birthdayVar = "${temp.day}/${temp.month}/${temp.year}";
    if (_birthdayVar == null) return;
    _ctrlBirthday.text = _birthdayVar;
  }

  _refreshContactList() async {
    List<Contact> x = await _dbHelper.fetchContacts();
    setState(() {
      _contacts = x;
    });
    autoComplete();
    maleCount();
    femaleCount();
    allContactsCount();
    _image = null;
  }

  _onSearch() async {
    _formKey.currentState.reset();
    _ctrlName.clear();
    _ctrlMobile.clear();
    _ctrlAddress.clear();
    _ctrlBirthday.clear();
    if (_contact.search != null) {
      List<Contact> x = await _dbHelper.fetchSearchContacts(_contact);
      setState(() {
        _contacts = x;
      });
      ctrlSearch.clear();
      return;
    }
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (_contact.id == null) {
        _contact.gender = _dropDownValue;
        if (_image != null)
          _contact.img = Utility.base64String(_image.readAsBytesSync());
        await _dbHelper.insertContact(_contact);
      } else {
        _contact.gender = _dropDownValue;
        if (_image != null) _contact.img = null;
        await _dbHelper.updateContact(_contact);
      }
      _refreshContactList();
      _resetForm();
      _image = null;
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState.reset();
      _ctrlName.clear();
      _ctrlMobile.clear();
      _ctrlAddress.clear();
      _ctrlBirthday.clear();
      _contact.id = null;
      _birthdayVar = null;
    });
  }

  maleCount() async {
    Database db = await _dbHelper.database;
    List<Map> contacts = await db.query("contacts WHERE gender = 'Male'");
    setState(() {
      maleCountVar = contacts.length;
    });
  }

  femaleCount() async {
    Database db = await _dbHelper.database;
    List<Map> contacts = await db.query("contacts WHERE gender = 'Female'");
    setState(() {
      femaleCountVar = contacts.length;
    });
  }

  allContactsCount() async {
    Database db = await _dbHelper.database;
    List<Map> contacts = await db.query("contacts");
    setState(() {
      contactsCountVar = contacts.length;
    });
  }

  d(var index) async {
    await _dbHelper.deleteContact(_contacts[index].id);
  }

  _list() async {
    List<Contact> t = await _dbHelper.fetchContacts();
    setState(() {
      _contacts = t;
    });
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (_contacts.length == 0)
          return Expanded(
            child: Card(
                margin: EdgeInsets.fromLTRB(20, 30, 20, 50),
                child: ListTile(
                  leading: Icon(Icons.contact_mail),
                  title: Text("Empty"),
                )),
          );
        else
          return Column(children: [
            TextFormField(
              controller: ctrlSearch,
              decoration: InputDecoration(
                  labelText: 'Search',
                  icon: IconButton(
                      icon: Icon(Icons.person_search),
                      onPressed: () => _onSearch())),
              onChanged: (val) => setState(() => _contact.search = val),
            ),
            Expanded(
              child: Card(
                margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Utility.imageFromBase64String(
                              _contacts[index].img),
                          title: Text(
                            _contacts[index].name.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  Text(_contacts[index].mobile),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(_contacts[index].address),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(_contacts[index].birthday),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("${_contacts[index].gender}"),
                                ],
                              ),
                              Row(
                                children: [
                                  if (_contacts[index].gender == "Male")
                                    Text(
                                        "His Age is : ${(DateTime.now().year) - int.parse((_contacts[index].birthday).substring((_contacts[index].birthday).length - 4))}"),
                                  if (_contacts[index].gender == "Female")
                                    Text(
                                        "Her Age is : ${(DateTime.now().year) - int.parse((_contacts[index].birthday).substring((_contacts[index].birthday).length - 4))}"),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                              icon: Icon(Icons.delete_sweep),
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: Text('Delete Contact ?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await _dbHelper.deleteContact(
                                                _contacts[index].id);
                                            setState(() {
                                              Navigator.pop(context);
                                              _resetForm();
                                              _refreshContactList();
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    );
                                  })),
                          onTap: () {
                            _resetForm();
                            setState(() {
                              _contact = _contacts[index];
                              _ctrlName.text = _contacts[index].name;
                              _ctrlMobile.text = _contacts[index].mobile;
                              _ctrlAddress.text = _contacts[index].address;
                              _ctrlBirthday.text = _contacts[index].birthday;
                              _birthdayVar = _contacts[index].birthday;
                              _addGender(_contacts[index].gender);
                            });
                          },
                        ),
                        Divider(
                          height: 5.0,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ]);
      },
    );
  }
}
