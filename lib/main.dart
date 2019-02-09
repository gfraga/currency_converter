import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const requestHg =
    "https://api.hgbrasil.com/finance?format=json-cors&key=3b271fe8";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white)));
}

Future<Map> getData() async {
  http.Response response = await http.get(requestHg);
  var results = json.decode(response.body)["results"];

  return results;
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final tecReal = TextEditingController();
  final tecDolar = TextEditingController();
  final tecEuro = TextEditingController();

  double _real = 0;
  double _dolar = 0;
  double _euro = 0;

  void realChanged(String text) {
    double real = double.parse(text);

    tecDolar.text = (real / this._dolar).toStringAsFixed(2);
    tecEuro.text = (real / this._euro).toStringAsFixed(2);
  }

  void dolarChanged(String text) {
    double dolar = double.parse(text);

    tecReal.text = (dolar * this._dolar).toStringAsFixed(2);
    tecEuro.text = ((dolar * this._dolar) / this._euro).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    double euro = double.parse(text);

    tecReal.text = (euro * this._euro).toStringAsFixed(2);
    tecDolar.text = ((euro * this._euro) / this._dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            title: Text("Currency Converter"),
            backgroundColor: Colors.amber,
            centerTitle: true),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text("Loading data...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error load data...",
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                          textAlign: TextAlign.center),
                    );
                  } else {
                    _dolar = snapshot.data["currencies"]["USD"]["buy"];
                    _euro = snapshot.data["currencies"]["EUR"]["buy"];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          Divider(),
                          buildTextField("Reais", "R\$ ", tecReal, realChanged),
                          Divider(),
                          buildTextField(
                              "Dolars", "US\$ ", tecDolar, dolarChanged),
                          Divider(),
                          buildTextField(
                              "Euros", "EUR\$ ", tecEuro, euroChanged)
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController tec, Function func) {
  return TextField(
      onChanged: func,
      controller: tec,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefixText: prefix),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      keyboardType: TextInputType.number);
}
