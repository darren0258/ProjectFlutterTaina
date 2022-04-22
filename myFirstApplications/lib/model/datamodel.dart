import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myfirstapplications/model/Profile.dart';
import 'package:myfirstapplications/model/databasemodel.dart';

class DataModel extends ChangeNotifier {
  List<String> consumerdata = [];
  List<List<LatLng>> listLatlang = [];
  List<List<LatLng>> process = [];
  List<Marker> myMarker = [];
  List<String> worktype = [];
  List<String> datainformation = [];
  List<String> dataEmail = [];
  List<String> sized = [];
  String phone = '0000000000';

  GoogleSignInAccount? googleAccount;

  Future<void> processSignInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    await Firebase.initializeApp().then((value) async {
      await _googleSignIn.signIn().then((value) {
        print('Login With gmail Success');
      });
    });
  }

  void setphone(String newphone) {
    phone = newphone;
    notifyListeners();
  }

  void addData(String data) {
    consumerdata.add(data);
    notifyListeners();
  }

  void addEmail(String data) {
    dataEmail.add(data);
    notifyListeners();
  }

  void addInformation(List<LatLng> latlng) {
    listLatlang.add(latlng);
    notifyListeners();
  }

  void removeindex(int deleteindex) {
    worktype.removeAt(deleteindex);
    datainformation.removeAt(deleteindex);
    process.removeAt(deleteindex);
    notifyListeners();
  }

  void removeprocess(int deleteindex) {
    process.removeAt(deleteindex);
    notifyListeners();
  }

  void addProcess(List<LatLng> latlng) {
    process.add(latlng);
    notifyListeners();
  }

  void addMarker(List<Marker> marker) {
    myMarker = marker;
    notifyListeners();
  }

  void addworktype(String data) {
    var db = TransactionDB(dbName: "database.db").openDatabase();

    worktype.insert(0, data);
    notifyListeners();
  }

  void adddatainformation(String data) {
    datainformation.add(data);
    notifyListeners();
  }

  markerrecord() {
    List<Marker> newMarker = List.from(myMarker);
    newMarker.removeAt(0);
    notifyListeners();
    return newMarker;
  }

  void addSized(String newsized) {
    sized.add(newsized);
    notifyListeners();
  }
}
