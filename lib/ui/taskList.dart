import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class taskList extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<taskList> {


  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      elevation: 1,
      child: InkWell(
        child: ListTile(
          onTap: (){},
          contentPadding: EdgeInsets.all(10),
          title: Text(
            document['name'],
            style: TextStyle( fontFamily:'Roboto',fontWeight: FontWeight.bold),),
          subtitle: Text(
            document['time'], style: TextStyle(fontWeight: FontWeight.w200),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildList(context, snapshot) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return _buildListItem(context, snapshot.data.documents[index]);
        },
        childCount: snapshot.data.documents.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: CustomScrollView(

        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.deepPurple[900],
            pinned: true,
            snap: true,
            floating: true,
            expandedHeight: 400,

            flexibleSpace:FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  "TASKLIST ",
                   style: TextStyle(
                   fontSize: 40,
                   fontWeight: FontWeight.w500,
            ),
          ),
                  background: Image.network("http://wonderfulengineering.com/56-free-motivational-wallpapers-for-download-that-will-make-your-day/")
          ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('Tasks')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

              if (snapshot.hasError) return SliverFillRemaining();
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return SliverToBoxAdapter(
                    child: Center(
                      heightFactor: 20,
                      widthFactor: 10,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.deepPurple[600]),
                      ),
                    ),
                  );
                default:
                  return
                    _buildList(context, snapshot);
              }
            },
          ),
        ],
      ),

      floatingActionButton: new FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.add,color: Colors.brown[100],),
          backgroundColor: Colors.deepPurple[800],
          onPressed: (){
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new UploadFormField()),
            );
          }
      ),
    );
  }
}

class UploadFormField extends StatefulWidget {
  @override
  _UploadFormFieldState createState() => _UploadFormFieldState();
}

class _UploadFormFieldState extends State<UploadFormField> {
  GlobalKey<FormState> _key = GlobalKey();
  bool _validate = false;
  String name, time;
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: new Scaffold(
        backgroundColor: Colors.brown[100],
        appBar: new AppBar(
          title: new Text('Upload'),
        ),
        body: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: new Form(
                key: _key,
                autovalidate: _validate,
                child: FormUI()
            ),
          ),
        ),

      ),
    );
  }
  Widget FormUI() {
    return new Column(
      children: <Widget>[
        new TextFormField(
            decoration: new InputDecoration(hintText: 'task name', icon: Icon(Icons.person),labelText: 'Name '),
            validator: validateName,
            onSaved: (String val) {
              name = val;
            }
        ),
        new TextFormField(
            decoration: new InputDecoration(hintText: 'for eg 3 May ',icon: Icon(Icons.calendar_today),labelText: 'Deadline Date'),
            validator: validateDeadline,
            onSaved: (String val) {
              time = val;
            },
          keyboardType: TextInputType.datetime
        ),
        new SizedBox(height: 15.0),
        new RaisedButton(onPressed: _sendToServer, child: new Text('Upload'),
        )
      ],
    );
  }
  String validateName(String value) {
    String pattern = r' (^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0){
      return 'Title is required';

    } else if (!regExp.hasMatch(value)) {
      return "Title must be a-z and A-Z";
    }

    return null;
  }

  String validateDeadline (String value) {
    String pattern = r' (^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0){
      return 'Author is required';

    } else if (!regExp.hasMatch(value)) {
      return "Author must be a-z and A-Z";
    }

    return null;
  }


  _sendToServer(){
    if (_key.currentState.validate() ){
      //No error in validator
      _key.currentState.save();
      Firestore.instance.runTransaction((Transaction transaction) async {
        CollectionReference reference = Firestore.instance.collection('Tasks');
        await reference.add({"name": "$name", "time": "$time"});
      });
    } else {
      // validation error
      setState(() {
        _validate = true;
      });
    }

  }
}
