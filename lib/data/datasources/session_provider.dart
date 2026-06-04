import 'package:flutter/material.dart';
import '../api/odoo_service.dart';

class SessionProvider extends ChangeNotifier {
  bool   isLoggedIn  = false;
  String userName    = '';
  int    partnerId   = 0;

  Future<void> login(String email, String apiKey) async {
    final result = await OdooService.instance.login(email: email, apiKey: apiKey);
    userName   = result['name'] as String;
    partnerId  = result['partnerId'] as int;
    isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await OdooService.instance.clearSession();
    isLoggedIn = false;
    userName   = '';
    partnerId  = 0;
    notifyListeners();
  }
}
