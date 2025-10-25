import 'package:flutter/material.dart'; 
class PieChartData {
  PieChartData(this.category, this.sales, this.color); 
  final String category;
  final num sales;
  final Color color; 
}

class DonutChartData {
  DonutChartData(this.category, this.sales);
  final String category;
  final num sales;
}