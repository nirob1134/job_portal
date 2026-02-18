import 'package:flutter/material.dart';


import '../main.dart';

void showMsg(String? msg,[bool isError = true]){
  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(msg?? ''),
      backgroundColor: isError? Colors.red: Colors.green
  )
  );
}