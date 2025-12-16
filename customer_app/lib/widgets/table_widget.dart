import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget {
  final int tableNumber;
  final bool isSelected;
  final bool isBooked;
  final VoidCallback onTap;

  const TableWidget({
    super.key,
    required this.tableNumber,
    required this.isSelected,
    required this.isBooked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color iconColor;
    Color textColor;

    if (isBooked) {
      bgColor = const Color.fromARGB(143, 133, 132, 132);
      borderColor = Colors.grey.shade700;
      iconColor = Colors.white24;
      textColor = Colors.white38;
    } else if (isSelected) {
      bgColor = Colors.orange;
      borderColor = Colors.orangeAccent;
      iconColor = Colors.black;
      textColor = Colors.black;
    } else {
      bgColor = Colors.grey.shade900;
      borderColor = Colors.white12;
      iconColor = Colors.white;
      textColor = Colors.white;
    }

    return  Tooltip(
  message: isBooked
      ? 'This table is fully booked'
      : isSelected
          ? 'Selected table'
          : 'Tap to select table',
  waitDuration: const Duration(milliseconds: 300),
  child: InkWell(
    onTap: isBooked ? null : onTap,
    borderRadius: BorderRadius.circular(100),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_seat,
            color: iconColor,
            size: 30,
          ),
          const SizedBox(height: 6),
          Text(
            'Table $tableNumber',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isBooked)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Booked',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  ),
);

  }
}
