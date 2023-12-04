import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_surah_controller.dart';

class DetailSurahView extends GetView<DetailSurahController> {
  const DetailSurahView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
           Obx(()=>
              InkWell(
                      onTap: ()async{           
                          if(controller.playAudio.value == true){
                            log("masuk");
                            controller.playAudio.value = false;
                            await controller.player.stop();                      
                          }else{
                             log("masuk 2");
                            controller.playAudio.value = true;
                            controller.startTimer();
                            await controller.player.play();

                        }
              
                      },
                      child:  Row(
                        children: [
                          controller.playAudio.value == true
                          ? Column(
                            children: [
                              const Icon(Icons.stop),
                              Text("${controller.hours.value} : ${controller.minutes.value} : ${controller.secondss.value}")
                            ],
                          )
                          :Column(
                            children: [
                              const Icon(Icons.play_arrow),
                              Text("${controller.hours.value} : ${controller.minutes.value} : ${controller.secondss.value}")

                            ],
                          ),
                          const SizedBox(width: 20,),
                        ],
                      ),
                    ),
           )
        ],
        title:  Obx(()=> controller.loading.value == true ? const Text("")
        :Text(controller.detailSurah['namaLatin'])),
        centerTitle: true,
      ),
      body: Obx(()=>controller.loading.value == true
      ?const Center(child: CircularProgressIndicator())
        : ListView.builder(
          shrinkWrap: true,
          itemCount: controller.detailSurah['ayat'].length,
          itemBuilder: (ctx,i){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: (){
                 showModalBottomSheet(
        context: context,
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular( // <-- SEE HERE
            10.0
          ),
        ),
        builder: (context) {
          return  SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children:[
                  InkWell(
                    onTap: ()async{
                   
                    },
                    child:  Row(
                      children: [
                        controller.playAudio.value == true
                        ?const Icon(Icons.stop)
                        :const Icon(Icons.play_arrow),
                        const SizedBox(width: 20,),
                        const Text("Play Audio")
                      ],
                    ),
                  )
                  ,const Divider(thickness: 1,)
                  
                ],
              ),
            ),
          );
        });
              },
              child: ListTile(
                leading:Container(decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${controller.detailSurah['ayat'][i]['nomorAyat']}.",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                  )) ,
                subtitle: Text("${controller.detailSurah['ayat'][i]['teksIndonesia']}.") ,
                title:Text(controller.detailSurah['ayat'][i]['teksArab'].toString() ,style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 20),textAlign: TextAlign.end,)),
            ),
          );
         }),
      )
    );
  }
}
