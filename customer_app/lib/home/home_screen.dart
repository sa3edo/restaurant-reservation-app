import 'dart:convert';
import 'dart:typed_data';

import 'package:customer_app/screens/restaurant_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/auth/cubit/auth_cubit.dart';
import 'package:customer_app/services/category_service.dart';
import 'package:customer_app/widgets/category_card.dart';
import 'package:customer_app/providers/restaurant_provider.dart';
import 'package:customer_app/screens/category_restaurants_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();
  String? selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).listenToRestaurants();
    });
  }

  void _searchRestaurants(String value) {
    Provider.of<RestaurantProvider>(
      context,
      listen: false,
    ).listenToRestaurants(search: value);
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String tempSearch = '';
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                title: const Text(
                  'Search Restaurant',
                  style: TextStyle(color: Colors.white),
                ),
                content: TextField(
                  onChanged: (value) => tempSearch = value,
                  decoration: const InputDecoration(
                    hintText: 'Type restaurant name...',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _searchRestaurants(tempSearch);
                    },
                    child: const Text(
                      'Search',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.search, color: Colors.black),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.home, color: Colors.red),
              Icon(Icons.favorite_border, color: Colors.white),
              SizedBox(width: 40),
              Icon(Icons.shopping_cart_outlined, color: Colors.white),
              Icon(Icons.person_outline, color: Colors.white),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Restaurant App',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
         
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Food Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: StreamBuilder(
                stream: _categoryService.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final categories = snapshot.data!.docs;
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CategoryCard(
                          name: 'All',
                          icon: Icons.restaurant,
                          isSelected: selectedCategory == 'all',
                          onTap: () {
                            setState(() {
                              selectedCategory = 'all';
                            });

                            context
                                .read<RestaurantProvider>()
                                .listenToRestaurants();
                          },
                        ),
                      ),

                      ...List.generate(categories.length, (index) {
                        final category = categories[index];
                        final id = category.id;

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: CategoryCard(
                            name: category['name'],
                            icon: Icons.fastfood, 
                            isSelected: selectedCategory == id,
                            onTap: () {
                              setState(() {
                                selectedCategory = id;
                              });

                              context
                                  .read<RestaurantProvider>()
                                  .listenToRestaurants(categoryId: id);
                            },
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Restaurants',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (restaurantProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (restaurantProvider.restaurants.isEmpty)
              const Center(
                child: Text(
                  'No restaurants found',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: restaurantProvider.restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurantProvider.restaurants[index];

                  Uint8List imageBytes;
                  if (restaurant['imageBase64'] != null &&
                      restaurant['imageBase64']!.isNotEmpty) {
                    imageBytes = base64Decode(restaurant['imageBase64']);
                  } else {
                    imageBytes = Uint8List(0); 
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RestaurantDetailsScreen(restaurant.id),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 180,
                            child: imageBytes.isNotEmpty
                                ? Image.memory(imageBytes, fit: BoxFit.cover)
                                : Image.network(
                                    'https://via.placeholder.com/300',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  restaurant['categoryName'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
