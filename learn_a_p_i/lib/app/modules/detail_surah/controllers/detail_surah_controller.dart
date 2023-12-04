import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

// ignore: depend_on_referenced_packages
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class DetailSurahController extends GetxController {
  Timer? countdownTimer;
  Duration myDuration = const Duration();
  final count = 0.obs;
  final dio = Dio();

  RxBool loading = false.obs;
  RxBool playAudio = false.obs;
  RxString baseUrl = "https://equran.id".obs;
  RxString hours = "".obs;
  RxString minutes = "".obs;
  RxString secondss = "".obs;
  RxString surah = "".obs;
  RxMap detailSurah = {}.obs;
  final assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
  final player = AudioPlayer();
  final nomor = Get.arguments;

  @override
  void onInit() {
    startPageActivity();
    super.onInit();
  }

//pengecekan internet in page detail
  void startPageActivity() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      getDetailSurah(nomor: nomor);
    } else {
      await readFile(nomor: nomor);
    }
  }

  Future<String> getFilePathAyath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/ayat.json'; // 3

    return filePath;
  }

  readFile({required nomor}) async {
    loading(true);
    log("nomor : $nomor");
    File file = File(await getFilePathAyath()); // 1
    String fileContent = await file.readAsString(); // 2
    for (var i in jsonDecode(fileContent)) {
      if (i['nomor'].toString() == nomor) {
        log("okokokokok : $i");
        detailSurah.value = i;
      }
    }
    loading(false);
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    final seconds = myDuration.inSeconds - reduceSecondsBy;
    if (seconds == 0) {
      countdownTimer!.cancel();
      playAudio.value = false;

      myDuration = const Duration(seconds: 0);
      String strDigits(int n) => n.toString().padLeft(2, '0');
      hours.value = strDigits(myDuration.inHours.remainder(24));
      minutes.value = strDigits(myDuration.inMinutes.remainder(60));
      secondss.value = strDigits(myDuration.inSeconds.remainder(60));
    } else {
      myDuration = Duration(seconds: seconds);
      String strDigits(int n) => n.toString().padLeft(2, '0');
      hours.value = strDigits(myDuration.inHours.remainder(24));
      minutes.value = strDigits(myDuration.inMinutes.remainder(60));
      secondss.value = strDigits(myDuration.inSeconds.remainder(60));
    }
  }

  void stopTimer() {
    countdownTimer!.cancel();
  }

  void resetTimer() {
    stopTimer();
  }

  Future<void> _init(String surah) async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    player.playbackEventStream.listen((event) {
      log("Cek : ${event.duration}");
      myDuration = event.duration!;
    }, onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
      await player.setAudioSource(AudioSource.uri(Uri.parse(surah)));
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  Future<void> getDetailSurah({required String nomor}) async {
    loading(true);
    final response = await dio.get(baseUrl + "/api/v2/surat/$nomor");
    loading(false);
    if (response.statusCode == 200) {
      detailSurah.value = jsonDecode(response.toString())['data'];
      _init(detailSurah['audioFull']['05']);
    } else {
      throw Exception('Failed to load Data Api');
    }
  }
}
