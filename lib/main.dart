import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=749c7e18";

void main() async {
  print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.green, primaryColor: Colors.white),
  ));
}

//Vai me retornar apenas no futuro
Future<Map> getData() async {
  //O await faz com que nós temos que esperar os dados chegarem do servidor
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controleReal = TextEditingController();
  final controleDolar = TextEditingController();
  final controleEuro = TextEditingController();

  double dolar;
  double euro;

  void _changeReal(String text) {
    double real = double.parse(text);
    controleDolar.text = (real / dolar).toStringAsFixed(2);
    controleEuro.text = (real / euro).toStringAsFixed(2);
     }

  void _changeDolar(String text) {
    double dolar = double.parse(text);
    controleReal.text = (dolar * this.dolar).toStringAsFixed(2);
    controleEuro.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _changeEuro(String text) {
    double euro = double.parse(text);
    controleReal.text = (euro * this.euro).toStringAsFixed(2);
    controleDolar.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor de Moedas"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),

      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            //verifico o estado da conexão
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.green, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar dados.",
                      style: TextStyle(color: Colors.green, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.green),
                        buildTextField(
                            "Reais", "R\$", controleReal, _changeReal),
                        Divider(),
                        buildTextField(
                            "Dólares", "US\$", controleDolar, _changeDolar),
                        Divider(),
                        buildTextField("Euros", "€", controleEuro, _changeEuro),
                        Divider(),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controlador, Function changed) {
  return TextField(
      controller: controlador,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.green),
          border: OutlineInputBorder(),
          prefixText: prefix),
      style: TextStyle(color: Colors.green, fontSize: 25.0),
      onChanged: changed,
      keyboardType: TextInputType.number);
}
