import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditStudentFormScreen extends StatefulWidget {


  const EditStudentFormScreen({super.key,});

  @override
  _EditStudentFormScreenState createState() => _EditStudentFormScreenState();
}

class _EditStudentFormScreenState extends State<EditStudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _classDivisionController;
  late TextEditingController _dobController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _classDivisionController = TextEditingController();
    _dobController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _classDivisionController.dispose();
    _dobController.dispose();
    _bloodGroupController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          "Edit Student Details",
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10,10,10,100),
            child: Card(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Student Image
                        CircleAvatar(
                          radius: 80,
                          // backgroundImage: NetworkImage(widget.student.imageUrl),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () {
                              // Add logic to change image
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        // Full Name
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter full name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        // Class-Division
                        TextFormField(
                          controller: _classDivisionController,
                          decoration: InputDecoration(
                            labelText: 'Class-Division',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.school),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter class and division';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        // Date of Birth
                        TextFormField(
                          controller: _dobController,
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter date of birth';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        // Blood Group
                        TextFormField(
                          controller: _bloodGroupController,
                          decoration: InputDecoration(
                            labelText: 'Blood Group',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.bloodtype),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter blood group';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        // Address
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        // Submit Button
                        ElevatedButton(
                          onPressed: () {
                            // if (_formKey.currentState!.validate()) {
                            //   // Save the updated student details
                            //   final updatedStudent = Student(
                            //     fullName: _fullNameController.text,
                            //     classDivision: _classDivisionController.text,
                            //     dob: _dobController.text,
                            //     bloodGroup: _bloodGroupController.text,
                            //     address: _addressController.text,
                            //     imageUrl: widget.student.imageUrl,
                            //   );
                            //   // Add logic to save the updated student details
                            //   Navigator.pop(context, updatedStudent);
                            // }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          ),
                          child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Student {
  final String fullName;
  final String classDivision;
  final String dob;
  final String bloodGroup;
  final String address;
  final String imageUrl;

  Student({
    required this.fullName,
    required this.classDivision,
    required this.dob,
    required this.bloodGroup,
    required this.address,
    required this.imageUrl,
  });
}