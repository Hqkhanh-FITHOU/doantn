import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';

class AddressProvider with ChangeNotifier {
  final logger = Logger();

  List<Address> _addresses = [];
  List<Address> get addresses => _addresses;


  Future<List<Address>> getAddresses() async {
    loadAddresses();
    return addresses;
  }

  Future<void> loadAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString('addresses');
    if (encodedData != null) {
      List<dynamic> decodedData = json.decode(encodedData);
      _addresses = decodedData.map((e) => Address.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    //logger.d(_addresses.length);
    notifyListeners();
  }

  Future<void> saveAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> addressMaps = _addresses.map((e) => e.toMap()).toList();
    String encodedData = json.encode(addressMaps);
    await prefs.setString('addresses', encodedData);
  }

  Address getAddress(int index){
    return _addresses.elementAt(index);
  }

  void addAddress(Address address) {
    _addresses.add(address);
    saveAddresses();
    notifyListeners();
  }

  void updateAddress(int index, Address address) {
    _addresses[index] = address;
    saveAddresses();
    notifyListeners();
  }

  void removeAddress(int index){
    _addresses.removeAt(index);
    saveAddresses();
    notifyListeners();
  }


  void updateCheckedStatus(int selectedIndex) {
    for (int i = 0; i < _addresses.length; i++) {
      _addresses[i].isChecked = (i == selectedIndex);
    }
    saveAddresses();
    notifyListeners();
  }

  Address getCheckedAddress() {
    return _addresses.firstWhere((address) => address.isChecked, orElse: () => Address(
      name: '',
      phone: '',
      address: '',
      addressType: '',
      isChecked: false,
    ));
  }
}