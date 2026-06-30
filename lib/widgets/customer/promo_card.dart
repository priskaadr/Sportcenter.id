import 'package:flutter/material.dart';

class PromoCard extends StatelessWidget {

  final String title;
  final String subtitle;
  final Color color;

  const PromoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 20),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: color,

        borderRadius: BorderRadius.circular(25),

      ),

      child: Row(

        children: [

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

              ],

            ),

          ),

          const Icon(
            Icons.local_offer,
            color: Colors.amber,
            size: 55,
          )

        ],

      ),

    );

  }

}