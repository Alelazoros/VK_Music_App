import 'package:flutter/material.dart';

void askDialog(BuildContext context, String title, String message,
    String fButton, String sButton, func) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(title),
        content: new Text(message),
        actions: <Widget>[
          new FlatButton(
              child: new Text(
                fButton,
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                func();
              }),
          new FlatButton(
            child: new Text(sButton),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
