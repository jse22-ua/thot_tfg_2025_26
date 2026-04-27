import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thot_tfg_2025_26/ui/appbar.dart';

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThotAppBar(),
      body: Text('Registro realizado')
    );
  }

}