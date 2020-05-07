import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagem {
  String _idUser;
  String _mensagem;
  String _urlImagem;
  String _tipo;
  DateTime _data;

  Mensagem();

    Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'data' : this._data,
      'idUser' : this.idUser,
      'mensagem' : this.mensagem,
      'urlImagem' : this.urlImagem,
      'tipo' : this.tipo
    };

    return map;
  }

  String get idUser => _idUser;

  set idUser(String idUser) {
    _idUser = idUser;
  }

    DateTime get data => _data;

  set data(DateTime data) {
    _data = data;
  }

  String get mensagem => _mensagem;

  set mensagem(String mensagem) {
    _mensagem = mensagem;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String urlImagem) {
    _urlImagem = urlImagem;
  }

  String get tipo => _tipo;

  set tipo(String tipo) {
    _tipo = tipo;
  }
}
