import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/Configuracoes.dart';
import 'package:whatsapp/Home.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/abas/mensagens.dart';


class RouteGenerator {

  static const String ROTA_HOME = '/home';
  static const String ROTA_LOGIN = '/login';
  static const String ROTA_CADASTRO = '/cadastro';
  static const String ROTA_CONFIGURACOES = '/configuracoes';
  static const String ROTA_MENSAGENS = '/mensagens';

  static Route<dynamic> generatorRoute(RouteSettings settings){

    final args = settings.arguments;

    switch(settings.name){
      case '/' :
        return MaterialPageRoute(
          builder: (_) => Login()
        );
        break;
      case ROTA_HOME:
        return MaterialPageRoute(
          builder: (_) => Home()
        );
        break;
      case ROTA_LOGIN:
        return MaterialPageRoute(
          builder: (_) => Login()
        );
        break;
      case ROTA_CADASTRO:
        return MaterialPageRoute(
          builder: (_) => Cadastro()
        );
        break;
      case ROTA_CONFIGURACOES:
        return MaterialPageRoute(
          builder: (_) => Configuracoes()
        );
        break;
      case ROTA_MENSAGENS:
        return MaterialPageRoute(
          builder: (_) => Mensagens(args)
        );
      default: 
        _erroRota();
    }

  }

  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Tela não encontrada'),
          ),
          body: Center(
            child: Text('Tela não encontrada'),
          ),
        );
      }
    );
  }
}