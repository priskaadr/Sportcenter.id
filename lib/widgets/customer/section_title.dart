import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const SectionTitle({

    super.key,

    required this.title,

    required this.subtitle,

    this.onTap,

  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Row(

        children: [

          Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                title,

                style: const TextStyle(

                  fontSize: 20,

                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(height: 3),

              Text(

                subtitle,

                style: TextStyle(

                  color: Colors.grey.shade600,

                  fontSize: 13,

                ),

              ),

            ],

          ),

          const Spacer(),

          TextButton(

            onPressed: onTap,

            child: const Text("Lihat Semua"),

          ),

        ],

      ),

    );

  }

}