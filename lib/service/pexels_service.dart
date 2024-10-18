import 'dart:convert';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:media_scanner/media_scanner.dart';

import 'package:http/http.dart' as http;

import 'package:wallpaper/model/model.dart';
import 'package:permission_handler/permission_handler.dart';


class PexelsService {
  final String apiKey = "YpHZNd497jGssb1326SSRt8WhW02PZvlbOCut3rUYwHjYPmFoegji6ru";
  final String baseURL = "https://api.pexels.com/v1/";

Future<List<Images>> getImagesList({required int? pageNumber}) async {
    String url = '';

    if (pageNumber == null) {
      url = "${baseURL}curated?per_page=80";
    } else {
      url = "${baseURL}curated?per_page=80&page=$pageNumber";
    }

    List<Images> imagesList = [];

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': apiKey,
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final jsonData = json.decode(response.body);

        for (final json in jsonData["photos"] as Iterable) {
          final image = Images.fromJson(json);
          print(image.imagePotraitPath);
          imagesList.add(image);
        }
      }
    } catch (_) {}

    return imagesList;
  }

  Future<Images> getImageById({required int id}) async {
    final url = "${baseURL}photos/$id";

    Images image = Images.emptyConstructor();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': apiKey,
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final jsonData = json.decode(response.body);

        image = Images.fromJson(jsonData);
      }
    } catch (_) {}
    return image;
  }

  Future<List<Images>> getImagesBySearch({required String query}) async {
    final url = "${baseURL}search?query=$query&per_page=80";
    List<Images> imagesList = [];

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': apiKey,
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final jsonData = json.decode(response.body);

        for (final json in jsonData["photos"] as Iterable) {
          final image = Images.fromJson(json);
          imagesList.add(image);
        }
      }
    } catch (_) {}

    return imagesList;
  }

  Future<void> requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

  Future<void> downloadImage({
  required String imageUrl,
  required int imageId,
  required BuildContext context,
}) async {
  try {
    print("Starting download for Image ID: $imageId");
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final bytes = response.bodyBytes;
      final directory = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);

      final file = File("$directory/$imageId.png");
      await file.writeAsBytes(bytes);

      MediaScanner.loadMedia(path: file.path);

      if (context.mounted) {
        print("File downloaded at: ${file.path}");
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 45, 156, 49),
            content: Text("File's been saved at: ${file.path}"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      print("Failed to download image. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error downloading image: $e");
  }
}
}