import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:evolvu/common/Common_dropDownFiled.dart';
import 'package:evolvu/common/textFiledStu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/Mylable.dart';
import '../common/common_textFiled.dart';

class StuInfoModal {
  String? studentId;
  String? academicYr;
  String? parentId;
  String? firstName;
  String? midName;
  String? lastName;
  String? studentName;
  String? dob;
  String? gender;
  String? admissionDate;
  String? studIdNo;
  String? motherTongue;
  String? birthPlace;
  String? admissionClass;
  String? rollNo;
  String? classId;
  String? sectionId;
  dynamic feesPaid;
  String? bloodGroup;
  String? religion;
  String? caste;
  dynamic subcaste;
  String? transportMode;
  String? vehicleNo;
  dynamic busId;
  String? emergencyName;
  String? emergencyContact;
  String? emergencyAdd;
  String? height;
  String? weight;
  String? hasSpecs;
  String? allergies;
  String? nationality;
  String? permantAdd;
  String? city;
  String? state;
  String? pincode;
  String? isDelete;
  String? prevYearStudentId;
  String? isPromoted;
  String? isNew;
  String? isModify;
  String? isActive;
  String? regNo;
  String? house;
  String? stuAadhaarNo;
  String? category;
  String? lastDate;
  String? slcNo;
  String? slcIssueDate;
  String? leavingRemark;
  dynamic deletedDate;
  dynamic deletedBy;
  String? imageName;
  String? guardianName;
  String? guardianAdd;
  String? guardianMobile;
  String? relation;
  String? guardianImageName;
  String? udisePenNo;
  dynamic addedBkDate;
  dynamic addedBy;
  String? className;
  String? sectionName;
  String? teacherId;
  String? classTeacher;

  StuInfoModal(
      {this.studentId,
        this.academicYr,
        this.parentId,
        this.firstName,
        this.midName,
        this.lastName,
        this.studentName,
        this.dob,
        this.gender,
        this.admissionDate,
        this.studIdNo,
        this.motherTongue,
        this.birthPlace,
        this.admissionClass,
        this.rollNo,
        this.classId,
        this.sectionId,
        this.feesPaid,
        this.bloodGroup,
        this.religion,
        this.caste,
        this.subcaste,
        this.transportMode,
        this.vehicleNo,
        this.busId,
        this.emergencyName,
        this.emergencyContact,
        this.emergencyAdd,
        this.height,
        this.weight,
        this.hasSpecs,
        this.allergies,
        this.nationality,
        this.permantAdd,
        this.city,
        this.state,
        this.pincode,
        this.isDelete,
        this.prevYearStudentId,
        this.isPromoted,
        this.isNew,
        this.isModify,
        this.isActive,
        this.regNo,
        this.house,
        this.stuAadhaarNo,
        this.category,
        this.lastDate,
        this.slcNo,
        this.slcIssueDate,
        this.leavingRemark,
        this.deletedDate,
        this.deletedBy,
        this.imageName,
        this.guardianName,
        this.guardianAdd,
        this.guardianMobile,
        this.relation,
        this.guardianImageName,
        this.udisePenNo,
        this.addedBkDate,
        this.addedBy,
        this.className,
        this.sectionName,
        this.teacherId,
        this.classTeacher});

  StuInfoModal.fromJson(Map<String, dynamic> json) {
    studentId = json['student_id'];
    academicYr = json['academic_yr'];
    parentId = json['parent_id'];
    firstName = json['first_name'];
    midName = json['mid_name'];
    lastName = json['last_name'];
    studentName = json['student_name'];
    dob = json['dob'];
    gender = json['gender'];
    admissionDate = json['admission_date'];
    studIdNo = json['stud_id_no'];
    motherTongue = json['mother_tongue'];
    birthPlace = json['birth_place'];
    admissionClass = json['admission_class'];
    rollNo = json['roll_no'];
    classId = json['class_id'];
    sectionId = json['section_id'];
    feesPaid = json['fees_paid'];
    bloodGroup = json['blood_group'];
    religion = json['religion'];
    caste = json['caste'];
    subcaste = json['subcaste'];
    transportMode = json['transport_mode'];
    vehicleNo = json['vehicle_no'];
    busId = json['bus_id'];
    emergencyName = json['emergency_name'];
    emergencyContact = json['emergency_contact'];
    emergencyAdd = json['emergency_add'];
    height = json['height'];
    weight = json['weight'];
    hasSpecs = json['has_specs'];
    allergies = json['allergies'];
    nationality = json['nationality'];
    permantAdd = json['permant_add'];
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
    isDelete = json['IsDelete'];
    prevYearStudentId = json['prev_year_student_id'];
    isPromoted = json['isPromoted'];
    isNew = json['isNew'];
    isModify = json['isModify'];
    isActive = json['isActive'];
    regNo = json['reg_no'];
    house = json['house'];
    stuAadhaarNo = json['stu_aadhaar_no'];
    category = json['category'];
    lastDate = json['last_date'];
    slcNo = json['slc_no'];
    slcIssueDate = json['slc_issue_date'];
    leavingRemark = json['leaving_remark'];
    deletedDate = json['deleted_date'];
    deletedBy = json['deleted_by'];
    imageName = json['image_name'];
    guardianName = json['guardian_name'];
    guardianAdd = json['guardian_add'];
    guardianMobile = json['guardian_mobile'];
    relation = json['relation'];
    guardianImageName = json['guardian_image_name'];
    udisePenNo = json['udise_pen_no'];
    addedBkDate = json['added_bk_date'];
    addedBy = json['added_by'];
    className = json['class_name'];
    sectionName = json['section_name'];
    teacherId = json['teacher_id'];
    classTeacher = json['class_teacher'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['student_id'] = studentId;
    data['academic_yr'] = academicYr;
    data['parent_id'] = parentId;
    data['first_name'] = firstName;
    data['mid_name'] = midName;
    data['last_name'] = lastName;
    data['student_name'] = studentName;
    data['dob'] = dob;
    data['gender'] = gender;
    data['admission_date'] = admissionDate;
    data['stud_id_no'] = studIdNo;
    data['mother_tongue'] = motherTongue;
    data['birth_place'] = birthPlace;
    data['admission_class'] = admissionClass;
    data['roll_no'] = rollNo;
    data['class_id'] = classId;
    data['section_id'] = sectionId;
    data['fees_paid'] = feesPaid;
    data['blood_group'] = bloodGroup;
    data['religion'] = religion;
    data['caste'] = caste;
    data['subcaste'] = subcaste;
    data['transport_mode'] = transportMode;
    data['vehicle_no'] = vehicleNo;
    data['bus_id'] = busId;
    data['emergency_name'] = emergencyName;
    data['emergency_contact'] = emergencyContact;
    data['emergency_add'] = emergencyAdd;
    data['height'] = height;
    data['weight'] = weight;
    data['has_specs'] = hasSpecs;
    data['allergies'] = allergies;
    data['nationality'] = nationality;
    data['permant_add'] = permantAdd;
    data['city'] = city;
    data['state'] = state;
    data['pincode'] = pincode;
    data['IsDelete'] = isDelete;
    data['prev_year_student_id'] = prevYearStudentId;
    data['isPromoted'] = isPromoted;
    data['isNew'] = isNew;
    data['isModify'] = isModify;
    data['isActive'] = isActive;
    data['reg_no'] = regNo;
    data['house'] = house;
    data['stu_aadhaar_no'] = stuAadhaarNo;
    data['category'] = category;
    data['last_date'] = lastDate;
    data['slc_no'] = slcNo;
    data['slc_issue_date'] = slcIssueDate;
    data['leaving_remark'] = leavingRemark;
    data['deleted_date'] = deletedDate;
    data['deleted_by'] = deletedBy;
    data['image_name'] = imageName;
    data['guardian_name'] = guardianName;
    data['guardian_add'] = guardianAdd;
    data['guardian_mobile'] = guardianMobile;
    data['relation'] = relation;
    data['guardian_image_name'] = guardianImageName;
    data['udise_pen_no'] = udisePenNo;
    data['added_bk_date'] = addedBkDate;
    data['added_by'] = addedBy;
    data['class_name'] = className;
    data['section_name'] = sectionName;
    data['teacher_id'] = teacherId;
    data['class_teacher'] = classTeacher;
    return data;
  }
}

class StudentForm extends StatefulWidget {
  final String studentId;
  final String cname;
  final String secname;
  final String shortName1;

  StudentForm(this.studentId, this.cname, this.shortName1, this.secname);

  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  File? file;
  String shortName = "";
  String academic_yrstr = "";
  String reg_idstr = "";
  String projectUrl = "";
  String url = "";
  String imageUrl = "";
  StuInfoModal? childInfo;

  Map<String, dynamic> updatedData = {};

  void _handleChanged(String key, String? value) {
    if (value != null && value.isNotEmpty) {
      updatedData[key] = value;
    } else {
      updatedData.remove(key);
    }
  }

  Map<String, String> specsMapping = {
    'Y': 'YES',
    'N': 'NO',
  };

  Map<String, String> genderMapping = {
    'M': 'Male',
    'F': 'Female',
  };
  Map<String, String> TransMapping = {
    '': 'select',
    'Bus': 'Bus',
    'Van': 'Van',
    'Self': 'Self',
  };

  final List<String> displayOptions = [
    'Select',
    'School Bus',
    'Private Van',
    'Self'
  ];

  // Values sent to the server
  final Map<String, String> valueMapping = {
    'Select': '',
    'School Bus': 'Bus',
    'Private Van': 'Van',
    'Self': 'Self'
  };
  String? selectedHouseName = '';
  String? selectedTrans = '';

  String? selectedHouseId; // Store short name
  List<Map<String, String>> houses = [];

  Map<String, String> houseNameMapping = {
    'D': 'Diamond',
    'E': 'Emerald',
    'R': 'Ruby',
    'S': 'Sapphire',
  };

  String getGender(String? abbreviation) {
    if (abbreviation == null || abbreviation.isEmpty) {
      return '';
    }
    return genderMapping[abbreviation] ?? abbreviation;
  }

  String getTrans(String? abbreviation) {
    if (abbreviation == null || abbreviation.isEmpty) {
      return TransMapping['']!; // Return "Select" if empty or null
    }
    return TransMapping[abbreviation] ?? abbreviation;
  }

  String getSpecs(String? abbreviation) {
    if (abbreviation == null || abbreviation.isEmpty) {
      return '';
    }
    return specsMapping[abbreviation] ?? abbreviation;
  }

  Future<StuInfoModal?> _getSchoolInfo(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');
    print('logUrls====\\\\: $logUrls');
    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
        print('logUrls====\\\\11111: $logUrls');

        academic_yrstr = logUrlsparsed['academic_yr'];
        reg_idstr = logUrlsparsed['reg_id'];
        // shortName = logUrlsparsed['short_name'];

        print('academic_yr ID: $academic_yrstr');
        print('reg_id: $reg_idstr');
      } catch (e) {
        print('Error parsing school info: $e');
      }
    } else {
      print('School info not found in SharedPreferences.');
    }

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);

        String schoolId = parsedData['school_id'];
        String name = parsedData['name'];
        shortName = parsedData['short_name'];
        url = parsedData['url'];
        String teacherApkUrl = parsedData['teacherapk_url'];
        projectUrl = parsedData['project_url'];
        String defaultPassword = parsedData['default_password'];

        print('Short Name: $shortName');
        print('URL1111: $url');
        print('Teacher APK URL: $teacherApkUrl');
        print('Project URL: $projectUrl');
        print('Default Password: $defaultPassword');
      } catch (e) {
        print('Error parsing school info: $e');
      }
    } else {
      print('School info not found in SharedPreferences.');
    }

    http.Response response = await http.post(
      Uri.parse("${url}get_student"),
      body: {
        'student_id': studentId,
        'academic_yr': academic_yrstr,
        'short_name': shortName
      },
    );
    imageUrl = "${projectUrl}uploads/student_image/$studentId.jpg";
    print('Response status code: ${response.statusCode}');
    print('get_student body: ${response.body}');

    if (response.statusCode == 200) {
      print('Response ```````11111111111```````');
      // Assuming 'response' contains the API response
      List<dynamic> apiResponse = json.decode(response.body);

      Map<String, dynamic> data = apiResponse[0];
      setState(() {
        isLoading = false;
        // visitors = uniqueVisitors;
      });
      return StuInfoModal.fromJson(data);
    }
    return null;
  }

  Future uploadImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
    );
    if (image == null) return;

    // Convert the image path to a File
    File imageFile = File(image.path);

    var croppedFile = await cropImage(imageFile);

    // Update the file variable with the cropped image
    setState(() {
      file = croppedFile;
    });
    // Upload the cropped image to the server
    imageUrl = await uploadImageToServer(croppedFile!);

    // Set the image using the received URL
    setState(() {
      imageUrl = imageUrl;
    });
  }

  // Function to crop the selected image using the image_cropper package
  Future<File?> cropImage(File pickedFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: const AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        statusBarColor: Colors.blue,
        backgroundColor: Colors.white,
      ),
      iosUiSettings: const IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );

    // Returning the edited/cropped image if available, otherwise the original image
    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return File(pickedFile.path);
    }
  }

  Future<String> uploadImageToServer(File croppedImage) async {
    // Create a multipart request using Dio package

    try {
      // Make POST request to upload image
      http.Response uploadresponse = await http.post(
        Uri.parse("${url}get_student_profile_images_details"),
        body: {'student_id': widget.studentId, 'short_name': shortName},
      );
      print('image_urlResponse body: ${uploadresponse.body}');
      // Check if response is successful
      if (uploadresponse.statusCode == 200) {
        // Parse the response JSON and extract image URL
        String uploadresponsestr = uploadresponse.body;
        Map<String, dynamic> uploadresponsedata =
        json.decode(uploadresponsestr);
        imageUrl = uploadresponsedata["image_url"];
        return imageUrl;
      } else {
        // Handle error
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      // Handle Dio errors
      print("Error uploading image: $e");
      throw Exception('Failed to upload image');
    }
  }

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
    // _getSchoolInfo(widget.studentId);
  }

  Future<void> fetchHouseData() async {
    try {
      print('get_house body:${widget.shortName1}');

      http.Response response = await http.post(
        Uri.parse("$url+get_house"),
        body: {'short_name': shortName},
      );
      print('get_house body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          houses = data.map((house) {
            return {
              'house_id': house['house_id'] as String,
              'house_name': house['house_name'] as String,
            };
          }).toList();

          // Set the initial selected house to the first house in the list, or you can choose another default

          // selectedHouseName = houses.first['house_name'];
          selectedHouseId = houses.first['house_id'];
          print('Failed to load house data ${childInfo?.house}');

          if (childInfo?.house == 'E') {
            selectedHouseName = 'Emerald';
            print('Failed to load house data $selectedHouseName');
          } else if (childInfo?.house == 'D') {
            selectedHouseName = 'Diamond';
          } else if (childInfo?.house == 'S') {
            selectedHouseName = 'Sapphire';
          } else if (childInfo?.house == 'R') {
            selectedHouseName = 'Ruby';
          }

          if (childInfo?.transportMode == 'Bus') {
            selectedTrans = 'School Bus';
            print('Failed to load house data $selectedTrans');
          } else if (childInfo?.transportMode == 'Van') {
            selectedTrans = 'Private Van';
          } else if (childInfo?.house == 'Self') {
            selectedTrans = 'Self';
          }
        });
      } else {
        print('Failed to load house data');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  _init() async {
    childInfo = await _getSchoolInfo(widget.studentId);
    setState(() {
      fetchHouseData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Card(
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(35),
            child: isLoading
                ? Center(
              child:
              CircularProgressIndicator(), // Show loading indicator while fetching data
            )
                : childInfo != null
                ? SingleChildScrollView(
              child: FormBuilder(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200.h,
                      width: 200.w,
                      child: Stack(
                        children: [
                          Positioned(
                            height: 150.w,
                            left: 0,
                            right: 0,
                            top: 10.h,
                            child: CircleAvatar(
                              radius: 75
                                  .w, // Adjust the radius to make the image circular
                              backgroundColor: Colors
                                  .grey[200], // Placeholder color
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(
                                imageUrl +
                                    '?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                              )
                                  : AssetImage(
                                childInfo?.gender == 'M'
                                    ? 'assets/boy.png'
                                    : 'assets/girl.png',
                              ) as ImageProvider,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 1, 24, 43)
                                    .withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.add),
                                iconSize: 24,
                                color: Colors.white,
                                onPressed: () {
                                  uploadImage(ImageSource.gallery);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),

                    CustomTextField(
                      label: 'First Name',
                      name: 'First Name',
                      readOnly: true,
                      initialValue: childInfo?.firstName,
                    ),

                    CustomTextField(
                      label: 'Middle Name',
                      name: 'Middle Name',
                      readOnly: true,
                      initialValue: childInfo?.midName,
                    ),

                    CustomTextField(
                      label: 'Last Name',
                      name: 'Last Name',
                      readOnly: true,
                      initialValue: childInfo?.lastName,
                    ),

                    CustomTextField(
                      label: 'Date Of Birth',
                      name: 'Date Of Birth',
                      readOnly: true,
                      initialValue: childInfo?.dob,
                    ),

                    // Date Of Admission Field
                    CustomTextField(
                      label: 'Date Of Admission',
                      name: 'Date Of Admission',
                      readOnly: true,
                      initialValue: childInfo?.admissionDate,
                    ),

                    // GRN NO. CustomTextField
                    CustomTextField(
                      label: 'GRN NO.',
                      name: 'GRN NO.',
                      readOnly: true,
                      initialValue: childInfo?.regNo,
                    ),

                    // Student ID NO. Field
                    CustomTextField(
                      label: 'Student ID NO.',
                      name: 'Student ID NO.',
                      readOnly: true,
                      initialValue: childInfo?.studIdNo,
                    ),

// Add some vertical space between the two fields

// Student ID NO. CustomTextField
                    // CustomTextField(
                    //   label: 'Student ID NO.',
                    //   name: 'Student ID NO.',
                    //   readOnly: true,
                    //   initialValue: childInfo?.studIdNo,
                    // ),

                    CustomTextField(
                      label: 'Udise Pen No.',
                      name: 'Udise Pen No.',
                      readOnly: true,
                      initialValue: childInfo?.udisePenNo,
                    ),
                    // Space between the two fields

                    // Student Aadhaar No. Field
                    StuTextField(
                      label: 'Student Aadhaar NO.',
                      name: 'Student Aadhaar NO.',
                      readOnly: false,
                      initialValue: childInfo?.stuAadhaarNo ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.stuAadhaarNo = value;
                        });
                      },
                    ),
                    ////
                    // TextFormField(
                    //   initialValue: childInfo?.stuAadhaarNo,
                    //   decoration: const InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Student Aadhaar NO.',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.stuAadhaarNo = value;
                    //     });
                    //   },
                    // ),

                    // Display the full house name
                    // if (childInfo?.house != null)
                    //   Text('House: ${getFullHouseName(childInfo!.house)}'),

                    CustomTextField(
                      label: 'Admitted In Class',
                      name: 'Admitted In Class',
                      initialValue: childInfo?.admissionClass,
                    ),
                    SizedBox(
                        width: 16.w), // Space between the two fields
                    // Class Field
                    CustomTextField(
                      initialValue: widget?.cname,
                      label: 'Class',
                      name: 'Class',
                      readOnly: true,
                    ),
                    CustomTextField(
                      initialValue: widget?.secname,
                      readOnly: true,
                      label: 'Division',
                      name: 'Division',
                    ),

                    CustomTextField(
                      readOnly: true,
                      initialValue: childInfo?.rollNo,
                      label: 'Roll No.',
                      name: 'Roll No.',
                    ),
                    LabeledDropdown(
                      label: "Gender", // Keep the label static
                      options: ['Male', 'Female'],
                      selectedValue: getGender(childInfo!
                          .gender), // Show the selected gender inside the dropdown
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            childInfo?.gender = newValue;
                          }
                        });
                      },
                    ),

                    LabeledDropdown(
                      label: "Blood Group", // Static label
                      options: const [
                        "AB+",
                        "AB-",
                        "B+",
                        "B-",
                        "A+",
                        "A-",
                        "O+",
                        "O-"
                      ],
                      selectedValue: childInfo?.bloodGroup ??
                          '', // Display the selected blood group inside the dropdown
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            childInfo?.bloodGroup =
                                newValue; // Update the selected value
                          }
                        });
                      },
                    ),

                    // TextFormField(
                    //   initialValue: childInfo?.bloodGroup,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Blood Group',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.bloodGroup = value;
                    //     });
                    //   },
                    // ),

                    LabeledDropdown(
                      label: 'House', // Static label
                      options: houseNameMapping.values.toList(), // List of house names
                      selectedValue: selectedHouseName, // Display the selected house name inside the dropdown
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedHouseName = newValue; // Update the selected house name
                            selectedHouseId = houses.firstWhere(
                                    (house) => house['house_name'] == newValue)['house_id']; // Update the house ID based on the selected house name
                          }
                        });
                      },
                    ),

                    StuTextField(
                      label: 'Nationality',
                      name: 'Nationality',
                      readOnly: false,
                      initialValue: childInfo?.nationality ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.nationality = value;
                        });
                      },
                    ),

                    // TextFormField(
                    //   initialValue: childInfo?.nationality,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Nationality',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.nationality = value;
                    //     });
                    //   },
                    // ),

                    StuTextField(
                      label: 'Address',
                      name: 'Address',
                      readOnly: false,
                      initialValue: childInfo?.permantAdd ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.permantAdd = value;
                        });
                      },
                    ),

                    // TextFormField(
                    //   initialValue: childInfo?.permantAdd,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Address',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.permantAdd = value;
                    //     });
                    //   },
                    // ),
                    StuTextField(
                      label: 'City',
                      name: 'City',
                      readOnly: false,
                      initialValue: childInfo?.city ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.city = value;
                        });
                      },
                    ),

                    StuTextField(
                      label: 'State',
                      name: 'State',
                      readOnly: false,
                      initialValue: childInfo?.state ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.state = value;
                        });
                      },
                    ),

                    // TextFormField(
                    //   initialValue: childInfo?.state,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'State',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.state = value;
                    //     });
                    //   },
                    // ),
                    StuTextField(
                      label: 'Pincode',
                      name: 'Pincode',
                      readOnly: false,
                      initialValue: childInfo?.pincode ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.pincode = value;
                        });
                      },
                    ),

                    StuTextField(
                      label: 'Birth Place',
                      name: 'Birth Place',
                      readOnly: false,
                      initialValue: childInfo?.birthPlace ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.birthPlace = value;
                        });
                      },
                    ),

                    // TextFormField(
                    //   initialValue: childInfo?.birthPlace,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Birth Place',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.birthPlace = value;
                    //     });
                    //   },
                    // ),
                    StuTextField(
                      label: 'Mother Tongue',
                      name: 'Mother Tongue',
                      readOnly: false,
                      initialValue: childInfo?.motherTongue ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.motherTongue = value;
                        });
                      },
                    ),

                    // Religion TextField
                    StuTextField(
                      label: 'Religion',
                      name: 'Religion',
                      readOnly: false,
                      initialValue: childInfo?.religion ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.religion = value;
                        });
                      },
                    ),

                    // TextFormField(
                    //   initialValue: childInfo?.religion,
                    //   readOnly: true,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Religion',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.religion = value;
                    //     });
                    //   },
                    // ),
                    StuTextField(
                      label: 'Caste',
                      name: 'Caste',
                      readOnly: false,
                      initialValue: childInfo?.caste ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.caste = value;
                        });
                      },
                    ),

                    // Category TextField
                    StuTextField(
                      label: 'Category',
                      name: 'Category',
                      readOnly: false,
                      initialValue: childInfo?.category ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.category = value;
                        });
                      },
                    ),

                    // TextFormField(
                    //   initialValue: childInfo?.category,
                    //   readOnly: true,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Category',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.category = value;
                    //     });
                    //   },
                    // ),
                    StuTextField(
                      label: 'Emergency Name',
                      name: 'Emergency Name',
                      readOnly: false,
                      initialValue: childInfo?.emergencyName ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.emergencyName = value;
                        });
                      },
                    ),
                    // TextFormField(
                    //   initialValue: childInfo?.emergencyName,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Emergency Name',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.emergencyName = value;
                    //     });
                    //   },
                    // ),
                    StuTextField(
                      label: 'Emergency Address',
                      name: 'Emergency Address',
                      readOnly: false,
                      initialValue: childInfo?.emergencyAdd ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.emergencyAdd = value;
                        });
                      },
                    ),
                    // TextFormField(
                    //   initialValue: childInfo?.emergencyAdd,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Emergency Address',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.emergencyAdd = value;
                    //     });
                    //   },
                    // ),
                    StuTextField(
                      label: 'Emergency Contact',
                      name: 'Emergency Contact',
                      readOnly: false,
                      initialValue: childInfo?.emergencyContact ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.emergencyContact = value;
                        });
                      },
                    ),

                    StuTextField(
                      label: 'Allergies(If ANY)',
                      name: 'Allergies(If ANY)',
                      readOnly: false,
                      initialValue: childInfo?.allergies ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.allergies = value;
                        });
                      },
                    ),

                    // TextFormField(
                    //   initialValue: childInfo?.emergencyContact,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Emergency Contact',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.emergencyContact = value;
                    //     });
                    //   },
                    // ),
                    // StuTextField(
                    //   label: 'Nationality',
                    //   name: 'Nationality',
                    //   readOnly: false,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.nationality = value;
                    //     });
                    //   },
                    // ),

                    //////////////

                    // StuTextField(
                    //   label: 'Allergies(If ANY)',
                    //   name: 'Allergies(If ANY)',
                    //   readOnly: false,
                    //   initialValue: childInfo?.allergies ?? '',
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.allergies = value;
                    //     });
                    //   },
                    // ),

                    // TextFormField(
                    //   initialValue: childInfo?.allergies,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Allergies(If ANY)',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.allergies = value;
                    //     });
                    //   },
                    // ),
                    StuTextField(
                      label: 'Height',
                      name: 'Height',
                      readOnly: false,
                      initialValue: childInfo?.height ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.height = value;
                        });
                      },
                    ),

                    StuTextField(
                      label: 'Weight',
                      name: 'Weight',
                      readOnly: false,
                      initialValue: childInfo?.weight ?? '',
                      onChanged: (value) {
                        setState(() {
                          childInfo?.weight =
                              value; // Corrected this line, it was updating 'nationality' instead of 'weight'
                        });
                      },
                    ),

                    // TextFormField(
                    //   initialValue: childInfo?.weight,
                    //   decoration: InputDecoration(
                    //     hintText: "50",
                    //     border: UnderlineInputBorder(),
                    //     labelText: 'Weight',
                    //   ),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       childInfo?.weight = value;
                    //     });
                    //   },
                    // ),
                    LabeledDropdown(
                      label: 'Transport Mode', // Static label
                      options: displayOptions, // Dropdown options
                      selectedValue:
                      selectedTrans, // The currently selected transport mode
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedTrans =
                                newValue; // Update the selected transport mode
                            childInfo?.transportMode = valueMapping[
                            newValue]!; // Map the selected value to server-side transport mode
                          }
                        });
                      },
                    ),

                    LabeledDropdown(
                      label: 'Has Spectacles?', // Static label
                      options: ['YES', 'NO'], // Dropdown options
                      selectedValue: getSpecs(childInfo!
                          .hasSpecs), // The currently selected spectacles status
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            childInfo?.hasSpecs =
                                newValue; // Update the spectacles status
                          }
                        });
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        print('###### body: ${childInfo?.allergies}');

                        try {
                          Response response = await post(
                            Uri.parse("${url}update_student"),
                            body: {
                              'short_name': shortName ?? '',
                              'student_id':
                              childInfo?.studentId ?? '',
                              'gender': childInfo?.gender ?? '',
                              'blood_group':
                              childInfo?.bloodGroup ?? '',
                              'stu_aadhaar_no':
                              childInfo?.stuAadhaarNo ?? '',
                              'nationality':
                              childInfo?.nationality ?? '',
                              'permant_add':
                              childInfo?.permantAdd ?? '',
                              'city': childInfo?.city ?? '',
                              'state': childInfo?.state ?? '',
                              'pincode': childInfo?.pincode ?? '',
                              'caste': childInfo?.caste ?? '',
                              'religion': childInfo?.religion ?? '',
                              'category': childInfo?.category ?? '',
                              'emergency_contact':
                              childInfo?.emergencyContact ?? '',
                              'emergency_name':
                              childInfo?.emergencyName ?? '',
                              'emergency_add':
                              childInfo?.emergencyAdd ?? '',
                              'transport_mode':
                              childInfo?.transportMode ?? '',
                              'vehicle_no':
                              childInfo?.vehicleNo ?? '',
                              'has_specs': childInfo?.hasSpecs ?? '',
                              'birth_place': childInfo?.birthPlace ?? '',
                              'mother_tongue': childInfo?.motherTongue ?? '',
                              'stud_id_no': childInfo?.studIdNo ?? '',
                              'admission_class': childInfo?.admissionClass ?? '',
                              'allergies': childInfo?.allergies ?? '',
                              'height': childInfo?.height ?? '',
                              'weight': childInfo?.weight ?? '',
                              'house': selectedHouseId ?? '',
                              'transport_mode': childInfo?.transportMode ?? '',
                            },
                          );

                          // print('Response body: $qrCode $academic_yr $formattedTime $formattedDate');
                          print('Response body: ${response.body} $selectedHouseId');
                          print(
                              'childInfo?.stuAadhaarNo33##### body: ${childInfo?.allergies}+${childInfo?.gender}+${childInfo?.transportMode}');

                          if (response.statusCode == 200) {
                            Fluttertoast.showToast(
                              msg: "Profile updated successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );

                            Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(
                              msg: "Failed to update Profile",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                        } catch (e) {
                          print('Exception: $e');
                        }

                        // UpdateStudent(context,childInfo?.studentId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 72, vertical: 12),
                      ),
                      child: Text(
                        'Update',
                        style: TextStyle(
                            color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
                    // Continue adding more fields or other widgets
                  ],
                ),
              ),
            )
                : Center(
              child: Text(
                'No visitors found',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    //   },
    // );
  }
}
