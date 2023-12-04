import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:learn_a_p_i/app/modules/home/views/courosel.dart';
import 'package:learn_a_p_i/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';


class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:  InkWell(
          onTap: (){
            controller.readFile();

          },
          child:const  Text('AL-Quran Ku')),
        centerTitle: true,
      ),
      body:  Obx(
        ()=>controller.loading.value == true
       ?const Center(child: CircularProgressIndicator())
       : Column(
         children: [
          CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
          ),
          items: imageSliders,
        ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.black38)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: controller.search,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Serach Surah"
                  ),
                        
                ),
              ),
            ),
          ),
          const SizedBox(height: 20,),
           Expanded(
             child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.listSurah.length,
              itemBuilder: (context,index){
              return InkWell(
                onTap: (){
                  Get.toNamed(Routes.DETAIL_SURAH,arguments: controller.listSurah[index]['nomor'].toString());
                },
                child: ListTile(
                  leading:Text("${controller.listSurah[index]['nomor']}.",style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 18),) ,
                  subtitle: Text("${controller.listSurah[index]['nama']}.",style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16)) ,
                  title:Text(controller.listSurah[index]['namaLatin'].toString(),style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 18))),
              );
             }),
           ),
         ],
       )
      ),
    );
  }
}
