//screens/book_table_screen.dart
import 'package:customer_app/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class BookTableScreen extends StatefulWidget {
  final String restaurantId;
  final int tableNumber;
  final String customerId;
  final String date;
  final int maxSeats;

  const BookTableScreen({
    super.key,
    required this.restaurantId,
    required this.tableNumber,
    required this.customerId,
    required this.date,
    required this.maxSeats,
  });

  @override
  State<BookTableScreen> createState() => _BookTableScreenState();
}

class _BookTableScreenState extends State<BookTableScreen> {
  int seats = 1;
  String? selectedTime;

  final List<String> timeSlots = [
    '10:00 AM',
    '12:00 PM',
    '02:00 PM',
    '04:00 PM',
    '06:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Book Table', style: TextStyle(color: Colors.red)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table ${widget.tableNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Number of Seats',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.maxSeats,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final value = index + 1;
                  final isSelected = seats == value;

                  return GestureDetector(
                    onTap: () {
                      setState(() => seats = value);
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.white24,
                          width: 2,
                        ),
                        color: isSelected ? Colors.orange : Colors.transparent,
                      ),
                      child: Text(
                        '$value',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Available Time Slots',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: bookingProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2.2,
                          ),
                      itemCount: timeSlots.length,
                      itemBuilder: (context, index) {
                        final time = timeSlots[index];

                        final isBooked = bookingProvider.isTimeBooked(
                          tableNumber: widget.tableNumber,
                          timeSlot: time,
                        );

                        final isSelected = selectedTime == time;

                        return GestureDetector(
                          onTap: isBooked
                              ? null
                              : () {
                                  setState(() {
                                    selectedTime = time;
                                  });
                                },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? const Color.fromARGB(108, 224, 224, 224)
                                  : isSelected
                                  ? Colors.orange
                                  : Colors.grey[900],
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.white24,
                              ),
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                color: isBooked
                                    ? Colors.white38
                                    : isSelected
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: selectedTime == null
                    ? null
                    : () async {
                        await bookingProvider.bookTable(
                          restaurantId: widget.restaurantId,
                          tableNumber: widget.tableNumber,
                          seats: seats,
                          date: widget.date,
                          customerId: widget.customerId,
                          timeSlot: selectedTime!,
                        );

                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(content: Text('Booking confirmed')),
                        // );
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Success',
                                message:
                                    'Your table has been booked successfully',
                                contentType: ContentType.success,
                              ),
                            ),
                          );

                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => HomeScreen()),
                          (route) => false,
                        );
                      },
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
