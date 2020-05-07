import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();
  File _image;
  String _idUser;
  bool _uploadingImage = false;
  String _urlRecuperada;

  Future _getImage(String origemImage) async {

    File file;
    switch(origemImage){
      case 'Camera' : 
        file = await ImagePicker.pickImage(source: ImageSource.camera); 
        break;
      case 'Galeria' : 
        file = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _image = file;
      if (_image != null){
        _uploadingImage = true;
        _uploadImagem();
      }
    });
  }


  Future _uploadImagem() async{
    FirebaseStorage storage = FirebaseStorage.instance;
    



    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
    .child('perfil')
    .child(_idUser + '.jpg');

    StorageUploadTask task = arquivo.putFile(_image);
    task.events.listen((StorageTaskEvent event) {
      if (event.type == StorageTaskEventType.progress){
        setState(() {
          _uploadingImage = true;
        });

      } else if (event.type == StorageTaskEventType.success) {
         setState(() {
          _uploadingImage = false;
        });
      }
     });

     task.onComplete.then((StorageTaskSnapshot snapshot) {
       _getUrlImage(snapshot);
     });
  }

  Future _getUrlImage(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _updateDataUser(url);
    setState(() {
      _urlRecuperada = url;
    });
  }

  _updateDataUser(String url) {
    Firestore db = Firestore.instance;

    Map<String, dynamic> data = {
      'urlImagem' : url
    };

    db.collection('usuarios')
      .document(_idUser)
      .updateData(data);
  }

  _updateNomeUser() {
    String nome = _controllerNome.text;
    Firestore db = Firestore.instance;

    Map<String, dynamic> data = {
      'nome' : nome
    };

    db.collection('usuarios')
      .document(_idUser)
      .updateData(data);
  }

  _getDataUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    _idUser = user.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection('usuarios')
      .document(_idUser)
      .get();

    Map<String, dynamic> data = snapshot.data;
    _controllerNome.text = data['nome'];

    if (data['urlImagem'] != null){
      setState(() {
        _urlRecuperada = data['urlImagem'];
      });
    }

  }

  @override
  void initState() {
    super.initState();
    _getDataUser();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  child: _uploadingImage ? CircularProgressIndicator() : Container(),
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundImage: _urlRecuperada != null ? NetworkImage(_urlRecuperada) : null,
                  backgroundColor: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Câmera'),
                      onPressed: () {
                        _getImage('Camera');
                      },
                    ),
                    FlatButton(
                      child: Text('Galeria'),
                      onPressed: () {
                        _getImage('Galeria');
                      },
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    //autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: 'Nome',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      color: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      child: Text(
                        'Salvar',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () {
                        _updateNomeUser();
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
