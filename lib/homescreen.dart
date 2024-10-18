import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  PexelsService repo = PexelsService();
  ScrollController singleChildScrollController = ScrollController();
  ScrollController masonryGridScrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  late Future<List<Images>> imagesList;
  int pageNumber = 1;

  final List<String> categories = [
    'Nature',
    'Animals',
    'Birds',
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
    imagesList = repo.getImagesList(pageNumber: pageNumber);
    super.initState();
  }

  @override
  void dispose() {
   singleChildScrollController.dispose();
    masonryGridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade900,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Pexels",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 4),
            Text(
              "Wallpapers",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Color.fromARGB(255, 252, 106, 179),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
           controller: singleChildScrollController,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.teal.shade50,
                  labelText: 'Search wallpapers',
                  labelStyle: TextStyle(color: Colors.teal.shade800),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal.shade700),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: IconButton(
                      onPressed: () {
                        getImagesBySearch(query: textEditingController.text);
                      },
                      icon: Icon(Icons.search, color: Colors.teal.shade800),
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                ],
                onSubmitted: (value) {
                  getImagesBySearch(query: value);
                },
              ),
            ),
            const SizedBox(height: 15),
            // Categories
            SizedBox(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      getImagesBySearch(query: categories[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.teal.shade400, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Grid of Images
            FutureBuilder(
              future: imagesList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Something went wrong!"),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: MasonryGridView.count(
                       controller: masonryGridScrollController,
                      itemCount: snapshot.data?.length,
                      shrinkWrap: true,
                      mainAxisSpacing: 8,
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      itemBuilder: (context, index) {
                        double height = (index % 10 + 1) * 100;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreviewPage(
                                  imageId: snapshot.data![index].imageID,
                                  imageUrl: snapshot.data![index]
                                      .imagePotraitPath,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: height > 300 ? 300 : height,
                              imageUrl:
                                  snapshot.data![index].imagePotraitPath,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            MaterialButton(
              minWidth: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              color: Colors.teal.shade800,
              textColor: Colors.white,
              onPressed: () {
                pageNumber++;
                imagesList = repo.getImagesList(pageNumber: pageNumber);
                setState(() {});
              },
              child: const Text(
                "Load More",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
