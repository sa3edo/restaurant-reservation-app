// screen/add_restaurant_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/location_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/restaurant_service.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class AddRestaurantScreen extends StatefulWidget {
  final QueryDocumentSnapshot? restaurant;
  AddRestaurantScreen({this.restaurant});
  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _tablesController = TextEditingController();

  String? selectedCategoryId;
  String? selectedCategoryName;

  final restaurantService = RestaurantService();

  File? _image;
  double? lat;
  double? lng;
  bool locationUP = false;
  bool locationButtonEnabled = true;

  final ImagePicker _picker = ImagePicker();

  bool get isEdit => widget.restaurant != null;

  static const String addNewCategoryValue = 'add_new';

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final r = widget.restaurant!;
      _nameController.text = r['name'];
      _descController.text = r['description'];
      _tablesController.text = r['tablesCount'].toString();
      selectedCategoryId = r['categoryId'];
      selectedCategoryName = r['categoryName'];

      lat = r['location']['lat'];
      lng = r['location']['lng'];
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> getLocation() async {
    try {
      final position = await LocationHelper.getCurrentLocation();
      setState(() {
        lat = position.latitude;
        lng = position.longitude;

        locationUP = true;
        locationButtonEnabled = false;
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: !isEdit ? Text('Location Added') : Text('Location updated'),
      //   ),
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
              message: !isEdit
                  ? 'Location added successfully'
                  : 'Location updated successfully',
              contentType: ContentType.success,
            ),
          ),
        );
    } catch (e) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text(e.toString())));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error',
              message: e.toString(),
              contentType: ContentType.failure,
            ),
          ),
        );
    }
  }

  Future<void> saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;
    if (lat == null || lng == null) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text('Please add location')));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Warning',
              message: 'Please add restaurant location',
              contentType: ContentType.warning,
            ),
          ),
        );
      return;
    }

    try {
      String imageBase64;

      if (_image != null) {
        imageBase64 = await restaurantService.encodeImage(_image!);
      } else {
        imageBase64 = widget.restaurant!['imageBase64'];
      }

      if (isEdit) {
        await restaurantService.updateRestaurant(
          id: widget.restaurant!.id,
          name: _nameController.text,
          description: _descController.text,
          imageBase64: imageBase64,
          categoryId: selectedCategoryId!,
          categoryName: selectedCategoryName!,
          tables: int.parse(_tablesController.text),
          lat: lat!,
          lng: lng!,
        );
      } else {
        await restaurantService.addRestaurant(
          name: _nameController.text,
          description: _descController.text,
          imageBase64: imageBase64,
          categoryId: selectedCategoryId!,
          categoryName: selectedCategoryName!,
          tables: int.parse(_tablesController.text),
          lat: lat!,
          lng: lng!,
        );
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Done',
              message: isEdit
                  ? 'Restaurant updated successfully'
                  : 'Restaurant added successfully',
              contentType: ContentType.success,
            ),
          ),
        );

      Future.delayed(const Duration(milliseconds: 700), () {
        Navigator.pop(context);
      });
    } catch (e) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text(e.toString())));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error',
              message: e.toString(),
              contentType: ContentType.failure,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Restaurant' : 'Add Restaurant',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: showImagePicker,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : isEdit
                        ? Image.memory(
                            base64Decode(widget.restaurant!['imageBase64']),
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white70,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Restaurant Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Enter restaurant name' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  final categories = snapshot.data!.docs;

                  return DropdownButtonFormField(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white),
                    hint: const Text(
                      'Select Category',
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: [
                      ...categories.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(
                            doc['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                      DropdownMenuItem(
                        value: addNewCategoryValue,
                        child: Row(
                          children: const [
                            Icon(Icons.add, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Add new category',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == addNewCategoryValue) {
                        final result = await showAddCategoryDialog();
                        if (result != null) {
                          setState(() {
                            selectedCategoryId = result['id'];
                            selectedCategoryName = result['name'];
                          });
                        }
                        return;
                      }
                      final doc = categories.firstWhere((e) => e.id == value);
                      setState(() {
                        selectedCategoryId = value.toString();
                        selectedCategoryName = doc['name'];
                      });
                    },
                    validator: (v) => v == null ? 'Select category' : null,
                  );
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _tablesController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Tables',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Enter tables count' : null,
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: locationButtonEnabled
                    ? getLocation
                    : null,
                icon: const Icon(Icons.location_on, color: Colors.black),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(MaterialState.disabled)) {
                      return const Color.fromARGB(255, 111, 1, 1); 
                    }
                    return Colors.red; 
                  }),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                ),
                label: Text(
                  lat == null
                      ? 'Get Location'
                      : !isEdit
                      ? 'Location Added'
                      : !locationUP
                      ? 'Update Location'
                      : 'Location Updated',
                  style: const TextStyle(color: Colors.black),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: saveRestaurant,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(
                    isEdit ? 'Update Restaurant' : 'Save Restaurant',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>?> showAddCategoryDialog() async {
    final controller = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Category',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Category name',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final doc = await FirebaseFirestore.instance
                  .collection('categories')
                  .add({
                    'name': name,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

              Navigator.pop(context, {'id': doc.id, 'name': name});

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Done',
                      message: 'Category added successfully',
                      contentType: ContentType.success,
                    ),
                  ),
                );
            },
            child: const Text('Add', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
