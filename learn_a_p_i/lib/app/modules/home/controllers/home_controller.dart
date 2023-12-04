import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomeController extends GetxController {
  final LocalStorage storage = LocalStorage('quran.json');
  final TextEditingController search = TextEditingController();
  final count = 0.obs;
  final dio = Dio();

  RxString baseUrl = "https://equran.id".obs;
  RxBool loading = false.obs;
  RxList listSurah = [].obs;
  RxList listAyat = [].obs;

  @override
  void onInit() {
    getSurah();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

//get list al-quran
  Future<void> getSurah() async {
    loading(true);

    bool result = await InternetConnectionChecker().hasConnection;

    if (result == true) {
      log('YAY! Ada internet!');
      final response = await dio.get(baseUrl + "/api/v2/surat");
      loading(false);

      if (response.statusCode == 200) {
        listSurah.value = jsonDecode(response.toString())['data'];
        //untuk melakukan save ke local data list quran
        saveFile(jsonDecode(response.toString())['data']);

        //untuk me loop satu" suratnya dan menjalankan fungsi get detail quran
        for (var i in listSurah) {
          await getDetailSurah(nomor: i['nomor'].toString());
          if (listAyat.length == 114) {
            saveFileDetail(listAyat);
          }
        }

        //untuk melakukan save ke local data ayat quran
        log("cek list ayat $listAyat");
      } else {
        throw Exception('Failed to load Data Api');
      }
    } else {
      loading(false);
      readFile();
      log('No internet :(');
    }
  }

  readFileAyat(nomor) async {
    File file = File(await getFilePathAyath()); // 1
    String fileContent = await file.readAsString(); // 2
    // ignore: prefer_interpolation_to_compose_strings
    List datas = jsonDecode(fileContent);
    for (var i in datas) {
      if (i['nomor'].toString() == nomor) {
        log("okokokokok : $i");
      }
    }

    // for(var i in jsonDecode(fileContent)){
    //   if(i['nomor'] == nomor){
    //     log("okokokokok : $i");
    //   }
    // }
  }

//untu set file ke local
  Future<String> getFilePath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/quran.json'; // 3

    return filePath;
  }

  Future<String> getFilePathAyath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/ayat.json'; // 3

    return filePath;
  }

//untuk melakukan simpan ke local data list quran
  void saveFile(data) async {
    File file = File(await getFilePath()); // 1
    file.writeAsString(jsonEncode(data)); // 2
  }

  //untuk melakukan simpan ke local data ayat quran
  void saveFileDetail(data) async {
    File file = File(await getFilePathAyath()); // 1
    file.writeAsString(jsonEncode(data)); // 2
  }

//untuk membaca file dari local
  void readFile() async {
    File file = File(await getFilePath()); // 1
    String fileContent = await file.readAsString(); // 2
    listSurah.value = jsonDecode(fileContent);
    log('File Content: $fileContent');
  }

  void getitemFromLocalStorage() {
    for (var i in storage.getItem('list_quran')) {
      log(i['namaLatin']);
    }
  }

  //untuk mengambil data dari api GET detail quran
  Future<void> getDetailSurah({required String nomor}) async {
    final response = await dio.get(baseUrl + "/api/v2/surat/$nomor");
    if (response.statusCode == 200) {
      //menampung datanya ke list
      listAyat.add(jsonDecode(response.toString())['data']);
    } else {
      throw Exception('Failed to load Data Api');
    }
  }
}
