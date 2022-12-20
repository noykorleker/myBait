import 'package:flutter/material.dart';

class Report {
  final String? id;
  final String? title;
  final String? description;
  final String? location;
  final String? imageUrl;

  Report({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.location,
    @required this.imageUrl,
  });
}