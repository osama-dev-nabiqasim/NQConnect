// ignore_for_file: file_names

import 'dart:io';

class Suggestion {
  final String title;
  final String description;
  final String? category;
  final File? image; // 👈 Optional image field

  Suggestion({
    required this.title,
    required this.description,
    this.category,
    this.image,
  });
}
