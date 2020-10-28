import 'package:flutter/material.dart';

enum covidStateField { newConfirmed, totalConfirmed, newDeaths, totalDeaths, newRecovered, totalRecovered }

Color blueColor = Color(0xff4e5af6);


List<Map<String, dynamic>> covidStateList = [
  {
    'state' : 'newConfirmed',
    'name' : 'Mới nhiễm',
    'color' : Color(0xff3d4bf7),
  },
  {
    'state' : 'totalConfirmed',
    'name' : 'Tổng nhiễm',
    'color' : Color(0xfff7b63a),
  },
  {
    'state' : 'newDeaths',
    'name' : 'Mới chết',
    'color' : Color(0xffef5b54),
  },
  {
    'state' : 'totalDeaths',
    'name' : 'Tổng chết',
    'color' : Color(0xff5dcb86),
  },
  {
    'state' : 'newRecovered',
    'name' : 'Mới hồi phục',
    'color' : Color(0xffa257df),
  },
  {
    'state' : 'totalRecovered',
    'name' : 'Tổng hồi phục',
    'color' : Color(0xffbec2da),
  },
];

