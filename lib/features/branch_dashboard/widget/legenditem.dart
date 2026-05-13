import 'package:flutter/material.dart';

Widget legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 6),
        Text(text,style: TextStyle(fontSize: 12),),
      ],
    );
  }

  