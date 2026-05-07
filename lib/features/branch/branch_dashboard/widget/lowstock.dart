import 'package:flutter/material.dart';

Widget lowStockBox({

  required String title,

  required String subtitle,

  required String stock,

}) {

  return Container(

    padding: const EdgeInsets.symmetric(
      horizontal: 7,
      vertical: 7,
    ),

    decoration: BoxDecoration(

      borderRadius: BorderRadius.circular(10),

      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),

    child: Row(

      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        Expanded(

          child: RichText(

            text: TextSpan(
              children: [

                TextSpan(

                  text: title,

                  style: const TextStyle(

                    color: Colors.black,

                    fontSize: 18,

                    fontWeight: FontWeight.w500,
                  ),
                ),

                TextSpan(

                  text: " $subtitle",

                  style: TextStyle(

                    color: Colors.grey.shade600,

                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        Text(

          stock,

          style: TextStyle(

            color: Colors.red.shade400,

            fontSize: 12,

            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}