import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Usuario.dart';

class Contatos extends StatefulWidget {
  @override
  _ContatosState createState() => _ContatosState();
}

class _ContatosState extends State<Contatos> {
  String _emailUser;
  String _idUser;
  

  Future<List<Usuario>> _getContatos() async {
    Firestore db = Firestore.instance;

    QuerySnapshot querySnapshot =
        await db.collection('usuarios').getDocuments();

    List<Usuario> usuarios = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;
      if (dados['email'] == _emailUser) continue;
        
      Usuario usuario = Usuario();

      usuario.idUser = item.documentID;
      usuario.nome = dados['nome'];
      usuario.email = dados['email'];
      usuario.urlFoto = dados['urlImagem'];

      usuarios.add(usuario);
    }

    return usuarios;

  }

  _getDataUserCurrent() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    _emailUser = user.email;
    _idUser = user.uid;
    
  }

  @override
  void initState() {
    super.initState();

    _getDataUserCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _getContatos(),
      builder: (_, snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.active:
          case ConnectionState.none:
          case ConnectionState.waiting: 
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text('Carregando'),
                  ),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.done:
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, i){
                List<Usuario> users = snapshot.data;
                Usuario user = users[i];

                return ListTile(
                  onTap: (){
                    Navigator.pushNamed(context, "/mensagens", arguments: user);
                  },
                  contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  leading: CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: user.urlFoto != null ? NetworkImage(user.urlFoto) : null,
                  ),
                  title: Text(
                    user.nome,
                    style: TextStyle(
                      fontSize: 16,

                    ),
                    ),
                );
              }
              );
            break;
        }
      },
    );
  }
}
