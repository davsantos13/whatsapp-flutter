import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Mensagem.dart';
import 'package:whatsapp/model/Usuario.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  TextEditingController _controllerTexto = TextEditingController();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();
  String _idUser;
  String _idDestinatario;
  Firestore db = Firestore.instance;
  bool _uploadingImage = false;

  _sendMessage() {
    String msg = _controllerTexto.text;
    if (msg.isNotEmpty) {
      Mensagem mensagem = Mensagem();

      mensagem.data = DateTime.now();
      mensagem.idUser = _idUser;
      mensagem.mensagem = msg;
      mensagem.urlImagem = '';
      mensagem.tipo = 'text';

      _saveMessage(_idUser, _idDestinatario, mensagem);

      _saveMessage(_idDestinatario, _idUser, mensagem);

      _saveConversa(mensagem);

      _controllerTexto.clear();
    }
  }

  _saveConversa(Mensagem msg) {
    //Conversa remetente
    Conversa conversaRemetente = Conversa();
    conversaRemetente.idRemetente = _idUser;
    conversaRemetente.idDestinatario = _idDestinatario;
    conversaRemetente.mensagem = msg.mensagem;
    conversaRemetente.nome = widget.contato.nome;
    conversaRemetente.urlFoto = widget.contato.urlFoto;
    conversaRemetente.urlImagemConversa = msg.urlImagem;
    conversaRemetente.tipo = msg.tipo;
    conversaRemetente.salvar();

    //ConversaDestinatário
    Conversa conversaDetino = Conversa();
    conversaDetino.idRemetente = _idDestinatario;
    conversaDetino.idDestinatario = _idUser;
    conversaDetino.mensagem = msg.mensagem;
    conversaDetino.nome = widget.contato.nome;
    conversaDetino.urlFoto = widget.contato.urlFoto;
    conversaDetino.urlImagemConversa = msg.urlImagem;
    conversaDetino.tipo = msg.tipo;
    conversaDetino.salvar();
  }

  _saveMessage(String idRemetente, String idDest, Mensagem mensagem) async {
    await db
        .collection('mensagens')
        .document(idRemetente)
        .collection(idDest)
        .add(mensagem.toMap());
  }

  _sendFoto() async {
    File image;
    image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String imageName = DateTime.now().millisecondsSinceEpoch.toString();

    _uploadingImage = true;
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo =
        pastaRaiz.child('mensagens').child(_idUser).child(imageName + '.jpg');

    StorageUploadTask task = arquivo.putFile(image);
    task.events.listen((StorageTaskEvent event) {
      if (event.type == StorageTaskEventType.progress) {
        setState(() {
          _uploadingImage = true;
        });
      } else if (event.type == StorageTaskEventType.success) {
        setState(() {
          _uploadingImage = false;
        });
      }
    });

    task.onComplete
        .then((StorageTaskSnapshot snapshot) => {_getUrlImage(snapshot)});
  }

  Future _getUrlImage(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.data = DateTime.now();
    mensagem.idUser = _idUser;
    mensagem.mensagem = '';
    mensagem.tipo = 'image';
    mensagem.urlImagem = url;

    _saveMessage(_idUser, _idDestinatario, mensagem);
    _saveMessage(_idDestinatario, _idUser, mensagem);
  }

  _getDataUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    _idUser = user.uid;
    _idDestinatario = widget.contato.idUser;

    _callListenMensagem();
  }

  @override
  void initState() {
    super.initState();

    _getDataUser();
  }

  Stream<QuerySnapshot> _callListenMensagem() {
    final stream = db
        .collection('mensagens')
        .document(_idUser)
        .collection(_idDestinatario)
        .orderBy('data', descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
      Timer(Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    var stream = StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
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
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;
            if (snapshot.hasError) {
              return Expanded(
                child: Text('Erro ao carregar mensagens'),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: querySnapshot.documents.length,
                  itemBuilder: (context, i) {
                    List<DocumentSnapshot> itens =
                        querySnapshot.documents.toList();
                    DocumentSnapshot item = itens[i];

                    double largura = MediaQuery.of(context).size.width * 0.7;

                    Alignment alinhamento = Alignment.centerRight;
                    Color cor = Color(0xffd2ffa5);

                    if (_idUser != item['idUser']) {
                      cor = Colors.white;
                      alinhamento = Alignment.centerLeft;
                    }

                    return Align(
                      alignment: alinhamento,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Container(
                          width: largura,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: cor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: item['tipo'] == 'text'
                              ? Text(item['mensagem'],
                                  style: TextStyle(fontSize: 18))
                              : Image.network(item['urlImagem']),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            break;
        }
      },
    );

    var caixaTexto = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerTexto,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                        icon: _uploadingImage
                            ? CircularProgressIndicator()
                            : Icon(Icons.camera_alt),
                        onPressed: _sendFoto),
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: 'Digite uma mensagem',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32))),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff075e54),
            child: Icon(Icons.send, color: Colors.white),
            mini: true,
            onPressed: _sendMessage,
          )
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            maxRadius: 20,
            backgroundColor: Colors.grey,
            backgroundImage: widget.contato.urlFoto != null
                ? NetworkImage(widget.contato.urlFoto)
                : null,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(widget.contato.nome),
          )
        ],
      )),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/bg.png'), fit: BoxFit.cover)),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [stream, caixaTexto],
            ),
          ),
        ),
      ),
    );
  }
}
