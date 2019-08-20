import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePageState createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String cep;
  var data;
  int status = 0;

  /*
  Status do Widget 
  0 => Inicial (sem nada)
  1 => Carregando
  2 => OK
  3 => Erro
   */

  final _formKey = new GlobalKey<FormState>();

  void submit() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        status = 1; // LOADING
      });
      _formKey.currentState.save();
      var response = await http.get('http://api.postmon.com.br/v1/cep/$cep');

      //await http.get('http://api.postmon.com.br/v1/cep/' + cep);

      if (response.statusCode == 200) // que deu bom
        setState(() {
          status = 2; //SUCESSO
          data = json.decode(response.body);
        });
      else //deu ruim
        setState(() {
          status = 3; //ERRO
        });
    }
  }

  Widget responseWidget() => status == 0
      ? SizedBox()
      : status == 1
          ? Center(
              child: CircularProgressIndicator(),
            )
          : status == 2
              ? Center(
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.home, size: 60,),
                      data['logradouro'] != null
                          ? Text(
                              data['logradouro'],
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w200),
                            )
                          : Text(
                              'Não há rua',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w200),
                            ),
                      Text(
                        data['bairro'] + ' - ' + data['cidade'],
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w300),
                      )
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.close),
                      Text('Erro no cep',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w200))
                    ],
                  ),
                );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Decode de cep'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: TextFormField(
                validator: (inputText) {
                  if (inputText.isEmpty) return 'Digite algo';
                  if (inputText.length < 8) return 'Digite um cep valido';
                  return null;
                },
                onSaved: (inputText) {
                  cep = inputText;
                },

                /*  COISAS DE DESIGN */
                maxLength: 8,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Digite seu cep'),
              ),
            ),
          ),
          Center(
            child: FlatButton(
              child: Text(
                'Buscar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => submit(),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          responseWidget()
        ],
      ),
    );
  }
}
