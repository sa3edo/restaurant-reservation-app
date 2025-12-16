// category_card.dart
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.red : Colors.grey[900];
    final iconColor = isSelected ? Colors.white : Colors.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
  width: 110,
  height: 110,
  decoration: BoxDecoration(
    color: color,
    shape: BoxShape.circle, 
    border: Border.all(
      color: isSelected ? Colors.red : Colors.grey,
      width: 1,
    ),
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: iconColor, size: 30),
      const SizedBox(height: 8),
      Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
),

    );
  }
}
