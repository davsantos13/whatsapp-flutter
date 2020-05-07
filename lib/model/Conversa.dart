import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {
  String _idRemetente;
  String _idDestinatario;
  String _tipo;
  String _nome;
  String _mensagem;
  String _urlFoto;
  String _urlImagemConversa;

  Conversa();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'idRemetente' : this.idRemetente,
      'idDestinatario' : this.idDestinatario,
      'tipo' : this.tipo,
      'nome' : this.nome,
      'mensagem' : this.mensagem,
      'urlFoto' : this.urlFoto,
      'urlImagemConversa' : this.urlImagemConversa
    };

    return map;
  }

  salvar() async {
    Firestore db = Firestore.instance;
    await db.collection('conversas')
      .document(this.idRemetente)
      .collection('ultima')
      .document(this.idDestinatario)
      .setData(this.toMap());
  }

  String get nome => _nome;

  set nome(String nome) {
    _nome = nome;
  }

  String get mensagem => _mensagem;

  set mensagem(String mensagem) {
    _mensagem = mensagem;
  }

  String get urlFoto => _urlFoto;

  set urlFoto(String urlFoto) {
    _urlFoto = urlFoto;
  }

  String get idRemetente => _idRemetente;

  set idRemetente(String idRemetente) {
    _idRemetente = idRemetente;
  }

  String get idDestinatario => _idDestinatario;

  set idDestinatario(String idDestinatario) {
    _idDestinatario = idDestinatario;
  }

  String get tipo => _tipo;

  set tipo(String tipo) {
    _tipo = tipo;
  }

  String get urlImagemConversa => _urlImagemConversa;

  set urlImagemConversa(String urlImagemConversa){
    _urlImagemConversa = urlImagemConversa;
  }
}
