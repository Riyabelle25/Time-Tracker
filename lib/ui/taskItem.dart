import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskItem extends StatefulWidget {
  final String title;
  final String subtitle;
  TaskItem({this.title,this.subtitle});
  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title, style: TextStyle( fontFamily:'Roboto',fontWeight: FontWeight.bold ),),
      subtitle: Text(widget.subtitle, style: TextStyle(fontWeight: FontWeight.w400)),
      trailing: Checkbox(
        value: selected,
        onChanged: (bool val){
          setState(() {
            selected=val;
          });
        },
      ),
    );
  }
}
