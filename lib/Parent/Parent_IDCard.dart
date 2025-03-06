import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Edit_IDCard.dart';

class StudentFormScreen extends StatefulWidget {
  @override
  _StudentFormScreenState createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  List<Student> students = [
    Student(
      fullName: "SHIFRA FRANCIS D'SOUZA",
      classDivision: "5 D",
      dob: "2014-11-11",
      bloodGroup: "O+",
      address: "Pune hadapsar",
      imageUrl: "https://via.placeholder.com/100", // Replace with actual image
    ),
    Student(
      fullName: "GADDIEL FRANCIS D'SOUZA",
      classDivision: "9 D",
      dob: "2010-11-11",
      bloodGroup: "AB-",
      address: "A2, B7, GARDENIA PHASE 2 SOMNATH NAGAR NEAR SHUBHAM BUS STOP WADGAON SHERI",
      imageUrl: "https://via.placeholder.com/100", // Replace with actual image
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          "ID Card Details",
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
          padding: const EdgeInsets.only(top: 80.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  ...students.map((student) => StudentCard(student: student)).toList(),
                  ParentInfoCard(
                    title: "Father Name",
                    name: "FRANCIS DENIS D'SOUZA",
                    mobile: "9876543210",
                    imageUrl: "https://via.placeholder.com/100", // Replace with actual image
                  ),
                  ParentInfoCard(
                    title: "Mother Name",
                    name: "SWETHA FRANCIS D'SOUZA",
                    mobile: "9766220055",
                    imageUrl: "https://via.placeholder.com/100", // Replace with actual image
                  ),
                  ParentInfoCard(
                    title: "Guardian Name",
                    name: "Suchita Kamath",
                    mobile: "8329955921",
                    relation: "Grandmother",
                    imageUrl: "https://via.placeholder.com/100", // Replace with actual image
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Checkbox(value: false, onChanged: (bool? value) {}),
                        const Expanded(
                          child: Text("I hereby declare that the information provided is true and correct."),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: const Text("Submit", style: TextStyle(color: Colors.white)),
                  ),
                ],
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

class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Container
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200], // Placeholder background color
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          student.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 60, color: Colors.grey[500]); // Fallback icon
                          },
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {},
                    //   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    //   child: const Text("Edit", style: TextStyle(color: Colors.white)),
                    // ),
                    IconButton(
                      icon: Column(
                        children: [
                          const Icon(Icons.upload_file, color: Colors.black),
                          const Text("Edit", style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditStudentFormScreen(
                            )),
                        );


                      },
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Full Name: ${student.fullName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Class-Division: ${student.classDivision}"),
                      Text("Date Of Birth: ${student.dob}"),
                      Text("Blood Group: ${student.bloodGroup}"),
                      Text("Address: ${student.address}", maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 10),

          ],
        ),
      ),
    );
  }
}

class ParentInfoCard extends StatelessWidget {
  final String title;
  final String name;
  final String mobile;
  final String? relation;
  final String imageUrl;

  const ParentInfoCard({
    super.key,
    required this.title,
    required this.name,
    required this.mobile,
    this.relation,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image Container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200], // Placeholder background color
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.person, size: 40, color: Colors.grey[500]); // Fallback icon
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$title: $name", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Mobile No: $mobile"),
                  if (relation != null) Text("Relation: $relation"),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.upload_file, color: Colors.black54),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}