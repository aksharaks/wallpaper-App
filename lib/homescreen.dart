//import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaper/model/model.dart';
import 'package:wallpaper/preview_page.dart';
import 'package:wallpaper/service/pexels_service.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();


  
}



class _HomescreenState extends State<Homescreen> {
//initialize 

   PexelsService  repo = PexelsService();
  ScrollController scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  late Future<List<Images>> imagesList;
  int pageNumber = 1 ;

   final List<String> categories = [
    'Nature',
    'Abstract',
    'Technology',
    'Mountains',
    'Cars',
    'Bikes',
    'People',
  ];

  void getImagesBySearch({required String query}) {
    imagesList = repo.getImagesBySearch(query: query);
    setState(() {});
  }



  @override
  void initState() {
    // TODO: implement initState
  imagesList = repo.getImagesList(pageNumber: pageNumber);
    super.initState();
  }
 
 
  @override
  void dispose() {
    // TODO: implement dispose
    scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
        Text("wallpaper",style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 18,
          color: Colors.blue,
        
        ),
        ),
         Text("App",style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 18,
          color: Colors.yellowAccent
        ),
        )


          ],)
          
      ),

body: SingleChildScrollView(
  controller: scrollController,
        scrollDirection: Axis.vertical,
        child:Column(
          children: [
            SizedBox(height: 10),
            Padding(padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: textEditingController,
              decoration:InputDecoration(
                contentPadding: const EdgeInsets.only(left: 20),
                labelText: 'search',
                border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  suffixIcon: Padding(padding: EdgeInsets.only(right: 5),
                  child: IconButton( onPressed: () {
                        getImagesBySearch(query: textEditingController.text);
                      },
                  icon: Icon(Icons.search)
                  
                  
                  ),
                  
                  
                  
                  ),
              ),
              inputFormatters: [FilteringTextInputFormatter.allow( RegExp('[a-zA-Z0-9]'),)],
               onSubmitted: (value) {
                  getImagesBySearch(query: value);
               }
            ),

            
            ),
            const SizedBox(height: 10,),
            SizedBox(height: 40,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,


              itemBuilder: (context, index) {
                return GestureDetector(
            onTap: () {
              getImagesBySearch(query: categories[index]);
            },

                  child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey,width: 1)
                    ),

                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                    child: Center(child: Text(categories[index]),),
                    
                    
                    ),
                  ),
                  
                  
                  ),
                  
                );
            
            },),
            ),
            SizedBox(

              height: 20,
            )
            
            ,FutureBuilder(future: imagesList, builder:(context, snapshot) {
              
              if(snapshot.connectionState == ConnectionState.done)

              {
                if (snapshot.hasError) {
                  return const Center(
                  child: Text("something went wrong"),
                  );
                  
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(padding:EdgeInsets.symmetric(horizontal: 5),
                    child: MasonryGridView.count(

                      controller: scrollController,
                      itemCount: snapshot.data?.length,
                      shrinkWrap: true,
                      mainAxisSpacing: 5,
                      crossAxisCount: 5,
                      crossAxisSpacing: 2,
                       itemBuilder: (context, index) {
                        double height = (index % 10 + 1);
                        return GestureDetector
                        (
                            onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PreviewPage(
                                      imageId: snapshot.data![index].imageID,
                                      imageUrl: snapshot
                                          .data![index].imagePotraitPath,
                                    ),
                                  ),
                                );
                              },
                          
                          child: ClipRRect
                        (
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          height: height > 300 ?300 :height ,
                          imageUrl:snapshot.data![index].imagePotraitPath,
                           errorWidget: (context, url, error) => 
                           const Icon(Icons.error),
                           ),),);
                      
                    },),
                    ),
                    SizedBox(height: 10),
                    MaterialButton(
                      minWidth: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      color: Color.fromARGB(255, 117, 18, 39),
                      textColor: Colors.white,
                      onPressed: (){
                     pageNumber++;
                     imagesList =repo.getImagesList(pageNumber: pageNumber);
                     setState(() {
                       
                     });

                      },
                      child: Text("Load more..."),)
                  ],
                );
              }
              else{
                return const Center(
child: CircularProgressIndicator(),
                );
              }
            },
            
            
            )
          ],
        )

),


      
    );
  }
}
