import 'package:flutter/material.dart';

mixin ColorMixin{
  Color getColorFromText(String letter){
    switch(letter){
      case 'A':return Colors.amber;
      case 'B':return Colors.blue;
      case 'C':return Colors.cyanAccent;
      case 'D':return Colors.deepOrange;
      case 'E':return Colors.deepPurple;
      case 'F':return Colors.black;
      case 'G':return Colors.green;
      case 'H':return Colors.grey;
      case 'I':return Colors.indigo;
      case 'J':return Colors.indigoAccent;
      case 'K':return Colors.redAccent;
      case 'L':return Colors.lightBlue;
      case 'M':return Colors.blueGrey;
      case 'N':return Colors.pink;
      case 'O':return Colors.orange;
      case 'P':return Colors.blue;
      case 'Q':return Colors.cyanAccent;
      case 'R':return Colors.deepOrange;
      case 'S':return Colors.deepPurple;
      case 'T':return Colors.black;
      case 'U':return Colors.green;
      case 'V':return Colors.grey;
      case 'W':return Colors.indigo;
      case 'X':return Colors.indigoAccent;
      case 'Y':return Colors.redAccent;
      case 'Z':return Colors.tealAccent;
      default: return Colors.teal;
    }
  }
}