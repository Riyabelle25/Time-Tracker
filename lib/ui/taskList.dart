import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetracker/ui/taskItem.dart';

class taskList extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<taskList> {


  //List of Widgets -

  static Widget bgImage = Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0 ,0.0, 0.0),
      child: Image.network(
        'https://wonderfulengineering.com/wp-content/uploads/2014/10/motivational-wallpaper-2-610x381.jpg',
        width: double.infinity,
        height: 50,
      ));


  Widget _buildListItem(BuildContext context, DocumentSnapshot document, int index, int n) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      elevation: 1,
      child: InkWell(
        child: TaskItem(
            title: "TASK: ${document['name']}",
            subtitle: " DEADLINE: ${document['time']}"
        ),
      ),
    );
  }

  Widget _buildList(context, snapshot) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _buildListItem(context, snapshot.data.documents[index], index,snapshot.data.documents.length);
        },
        childCount: snapshot.data.documents.length,

      ),
    );
  }

  //Main UI begins-

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.blue[800],
            pinned: true,
            snap: true,
            floating: true,
            expandedHeight: 215.3,

            flexibleSpace:FlexibleSpaceBar(
              background: bgImage,
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
                        valueColor: AlwaysStoppedAnimation(Colors.blue[800]),
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
          backgroundColor: Colors.blue[600],
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
          title: new Text('ADD TASKS '),
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
        ),
        new SizedBox(height: 15.0),
        new RaisedButton(onPressed: _sendToServer , child: new Text('Upload'),
        )
      ],
    );
  }
  String validateName(String value) {
    if (value.length == 0){
      return 'Title is required';
    }
    return null;
  }

  String validateDeadline (String value) {
    if (value.length == 0){
      return 'Date is required';
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
