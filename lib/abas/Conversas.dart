import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Usuario.dart';

class Conversas extends StatefulWidget {
  @override
  _ConversasState createState() => _ConversasState();
}

class _ConversasState extends State<Conversas> {
  List<Conversa> conversas = List();
  final _controller = StreamController<QuerySnapshot>();
  Firestore db = Firestore.instance;
  String _idUser;

  Stream<QuerySnapshot> _callListen() {
    final stream = db
        .collection('conversas')
        .document(_idUser)
        .collection('ultima')
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _getCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();

    _idUser = user.uid;

    _callListen();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();

    Conversa conversa = Conversa();
    conversa.nome = 'Priscila';
    conversa.mensagem = 'Bora ?';
    conversa.urlFoto = 'Bora ?';

    conversas.add(conversa);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Text('Carregando conversas'),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar os dados'),
              );
            } else {
              QuerySnapshot querySnapshot = snapshot.data;
              if (querySnapshot.documents.length == 0) {
                return Center(
                  child: Text('Você não tem nenhuma mensagem',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                );
              }

              return ListView.builder(
                itemCount: querySnapshot.documents.length,
                itemBuilder: (context, i) {
                  List<DocumentSnapshot> conversas =
                      querySnapshot.documents.toList();
                  DocumentSnapshot conversa = conversas[i];

                  String urlImagem = conversa['urlFoto'];
                  String tipo = conversa['tipo'];
                  String mensagem = conversa['mensagem'];
                  String nome = conversa['nome'];
                  String idDestinatario = conversa['idDestinatario'];

                  Usuario user = Usuario();
                  user.nome = nome;
                  user.urlFoto = urlImagem;
                  user.idUser = idDestinatario;

                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, "/mensagens",
                          arguments: user);
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          urlImagem != null ? NetworkImage(urlImagem) : null,
                    ),
                    title: Text(
                      nome,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      tipo == 'text' ? mensagem : 'Imagem',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  );
                },
              );
            }

            break;
        }
      },
    );
  }
}
