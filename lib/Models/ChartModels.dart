import 'package:flutter/material.dart'; // Import for Color

class PieChartData {
  PieChartData(this.category, this.sales, this.color); // <-- MODIFIED
  final String category;
  final num sales;
  final Color color; // <-- ADDED
}

class DonutChartData {
  DonutChartData(this.category, this.sales);
  final String category;
  final num sales;
}