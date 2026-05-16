import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Receiveditem extends StatefulWidget {

  final String title;

  final String trays;

  final String eggs;

  const Receiveditem({
    super.key,
    required this.title,
    required this.trays,
    required this.eggs,
  });

  @override
  State<Receiveditem> createState() =>
      _ReceiveditemState();
}

class _ReceiveditemState
    extends State<Receiveditem> {

  @override
  Widget build(BuildContext context) {

    return Container(

      padding:
          const EdgeInsets.all(12),

      margin:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),

      decoration: BoxDecoration(

        border: Border.all(
          color: Colors.grey.shade300,
        ),

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(

            widget.title,

            style:
                AppTextStyles.bodyText14dark,
          ),

          const SizedBox(height: 12),

          const Row(

            children: [

              Expanded(
                child: Text(
                  "Trays",
                ),
              ),

              Expanded(
                child: Text(
                  "Eggs",
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(

            children: [

              Expanded(

                child: Container(

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 12,
                  ),

                  alignment:
                      Alignment.center,

                  decoration: BoxDecoration(

                    border: Border.all(
                      color:
                          Colors.grey.shade300,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),

                  child: Text(

                    widget.trays,

                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(

                child: Container(

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 12,
                  ),

                  alignment:
                      Alignment.center,

                  decoration: BoxDecoration(

                    border: Border.all(
                      color:
                          Colors.grey.shade300,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),

                  child: Text(

                    widget.eggs,

                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}