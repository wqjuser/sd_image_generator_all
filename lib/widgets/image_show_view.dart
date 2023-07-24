import 'package:flutter/material.dart';
import 'dart:convert';

class ImageView extends StatelessWidget {
  final List<String> imageBase64List;

  const ImageView({super.key, required this.imageBase64List});

  @override
  Widget build(BuildContext context) {
    int imageCount = imageBase64List.length;

    if (imageCount == 1) {
      return Center(
        child: Image.memory(
          base64Decode(imageBase64List[0]),
        ),
      );
    } else if (imageCount == 2) {
      return Row(
        children: [
          Expanded(
            child: Image.memory(
              base64Decode(imageBase64List[0]),
            ),
          ),
          Expanded(
            child: Image.memory(
              base64Decode(imageBase64List[1]),
            ),
          ),
        ],
      );
    } else if (imageCount == 3) {
      return Row(
        children: [
          Expanded(
            child: Image.memory(
              base64Decode(imageBase64List[0]),
            ),
          ),
          Expanded(
            child: Image.memory(
              base64Decode(imageBase64List[1]),
            ),
          ),
          Expanded(
            child: Image.memory(
              base64Decode(imageBase64List[2]),
            ),
          ),
        ],
      );
    } else if (imageCount == 4) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Image.memory(
                  base64Decode(imageBase64List[0]),
                ),
              ),
              Expanded(
                child: Image.memory(
                  base64Decode(imageBase64List[1]),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Image.memory(
                  base64Decode(imageBase64List[2]),
                ),
              ),
              Expanded(
                child: Image.memory(
                  base64Decode(imageBase64List[3]),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      int rowCount = (imageCount / 3).ceil();
      List<Widget> rows = [];

      for (int i = 0; i < rowCount; i++) {
        List<Widget> rowChildren = [];

        for (int j = i * 3; j < (i * 3) + 3 && j < imageCount; j++) {
          rowChildren.add(
            Expanded(
              child: Image.memory(
                base64Decode(imageBase64List[j]),
              ),
            ),
          );
        }

        rows.add(
          Row(
            children: rowChildren,
          ),
        );
      }

      return Column(
        children: rows,
      );
    }
  }
}
