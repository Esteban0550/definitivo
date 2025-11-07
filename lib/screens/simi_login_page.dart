import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Terms Acceptance'),
        ),
        body: TermsAcceptanceWidget(),
      ),
    );
  }
}

class TermsAcceptanceWidget extends StatefulWidget {
  @override
  _TermsAcceptanceWidgetState createState() => _TermsAcceptanceWidgetState();
}

class _TermsAcceptanceWidgetState extends State<TermsAcceptanceWidget> {
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Aceptar términos",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13, // <-- tamaño reducido
            ),
          ),
          const SizedBox(width: 10),
          CupertinoSwitch(
            value: _acceptTerms,
            activeColor: Colors.teal,
            onChanged: (val) {
              setState(() => _acceptTerms = val);
            },
          ),
        ],
      ),
    );
  }
}