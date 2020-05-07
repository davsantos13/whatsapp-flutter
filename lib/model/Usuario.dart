class Usuario {
  String _idUser;
  String _nome;
  String _email;
  String _senha;
  String _urlFoto;

  Usuario();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'nome' : this.nome,
      'email' : this.email,
    };

    return map;
  }

  String get idUser => _idUser;

  set idUser(String idUser){
    _idUser = idUser;
  }

  String get nome => _nome;

  set nome(String nome) {
    _nome = nome;
  }

  String get email => _email;

  set email(String email) {
    _email = email;
  }

  String get senha => _senha;

  set senha(String senha) {
    _senha = senha;
  }

  String get urlFoto => _urlFoto;

  set urlFoto(String urlFoto){
    _urlFoto = urlFoto;
  }
}
