import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {

  final String title;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 250),

        margin: const EdgeInsets.only(right: 12),

        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),

        decoration: BoxDecoration(

          color: selected
              ? const Color(0xff001DFF)
              : Colors.white,

          borderRadius: BorderRadius.circular(30),

          boxShadow: [

            BoxShadow(

              color: Colors.black12,

              blurRadius: 6,

              offset: const Offset(0,3),

            )

          ],

        ),

        child: Text(

          title,

          style: TextStyle(

            color:
                selected
                    ? Colors.white
                    : Colors.black87,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

    );

  }

}