// home/vendor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_reservation_app/screens/vendor_notification_screen.dart';

import '../providers/restaurant_provider.dart';
import '../screens/add_category_screen.dart';
import '../screens/add_restaurant_screen.dart';
import '../screens/restaurant_details_screen.dart';
import '../screens/restaurant_bookings_screen.dart';
import '../widgets/action_card.dart';
import '../widgets/restaurant_card.dart';

class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.red),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VendorNotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 2),
            // Text(
            //   'Manage your restaurants',
            //   style: TextStyle(fontSize: 12, color: Colors.white70),
            // ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      title: 'Categories',
                      icon: Icons.category,
                      color: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddCategoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionCard(
                      title: 'Add Restaurant',
                      icon: Icons.add_business,
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddRestaurantScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Restaurants',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${provider.restaurants.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            if (provider.restaurants.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No restaurants yet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              )
            else
              SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final restaurant = provider.restaurants[index];

                  return RestaurantCard(
                    restaurant: restaurant,

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RestaurantDetailsScreen(restaurant: restaurant),
                        ),
                      );
                    },

                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddRestaurantScreen(restaurant: restaurant),
                        ),
                      );
                    },

                    onViewBookings: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantBookingsScreen(
                            restaurantId: restaurant.id,
                            restaurantName: restaurant['name'],
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: provider.restaurants.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.74,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
