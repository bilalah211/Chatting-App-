import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/api/apis.dart';
import 'package:connect/auth/login_screen.dart';
import 'package:connect/components/utils/Utils.dart';
import 'package:connect/model/chat_user/chat_user.dart';
import 'package:connect/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final aboutC = TextEditingController();

  String? image;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) {
                    return HomeScreen();
                  }));
                },
                icon: Icon(Icons.arrow_back)),
            centerTitle: true,
            title: Text(
              'Profile Screen',
              style: TextStyle(
                  color: Colors.orange,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w400),
            )),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.0),
                Center(
                  child: Stack(
                    children: [
                      image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(height * 0.9),
                              child: Image.file(
                                File(image!),
                                width: width * 0.3,
                                height: height * 0.14,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                width: width * 0.25,
                                height: height * 0.12,
                                imageUrl: widget.user.image,
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) =>
                                    Icon(CupertinoIcons.person),
                              ),
                            ),
                      Positioned(
                        left: 80,
                        top: 79,
                        child: InkWell(
                          onTap: () {
                            showBottomDialog();
                          },
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Container(
                              height: height * 0.05,
                              width: width * 0.06,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                Text(
                  widget.user.email,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                SizedBox(height: height * 0.04),
                Container(
                  height: height * 0.065,
                  width: width * 0.7,
                  child: TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.amber),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Enter Your Name',
                        label: const Text('Name')),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Container(
                  height: height * 0.065,
                  width: width * 0.7,
                  child: TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.info_outline_rounded,
                            color: Colors.amber),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'About Yourself',
                        label: const Text('About')),
                  ),
                ),
                SizedBox(height: height * 0.05),
                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      APIs.updateUserInfo().then((value) {
                        Utils.snackBar(context, 'Profile Updated Successfully');
                      });
                    }
                  },
                  child: Container(
                      height: height * 0.05,
                      width: width * 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.amber, Colors.orange]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          SizedBox(width: width * 0.02),
                          Text(
                            'Update',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                letterSpacing: 2),
                          )
                        ],
                      )),
                ),
                SizedBox(height: height * 0.02),
                InkWell(
                  onTap: () async {
                    Utils.showProgressBar(context);
                    await APIs.updateActiveStatus(false);
                    APIs.auth.signOut().then((value) {
                      GoogleSignIn().signOut().then((value) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        APIs.auth = FirebaseAuth.instance;
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) {
                          return LoginScreen();
                        }));
                      });
                    });
                  },
                  child: Container(
                      height: height * 0.05,
                      width: width * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_outlined,
                            color: Colors.amber,
                          ),
                          SizedBox(width: width * 0.02),
                          Text(
                            'Logout',
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                letterSpacing: 2),
                          )
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showBottomDialog() {
    showModalBottomSheet(
        context: (context),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (_) {
          final height = MediaQuery.of(context).size.height;
          final width = MediaQuery.of(context).size.width;
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: height * 0.03, bottom: height * 0.08),
            children: [
              Text(
                'Pick Profile Image',
                style: TextStyle(
                    letterSpacing: 1,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(width * 0.3, height * 0.15)),
                      onPressed: () async {
                        final XFile? images = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (images != null) {
                          setState(() {
                            image = images.path;
                            APIs.updateProfilePicture(File(image!));
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Image.asset('images/g.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(width * 0.3, height * 0.15)),
                      onPressed: () async {
                        final XFile? images = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        if (images != null) {
                          setState(() {
                            image = images.path;
                            APIs.updateProfilePicture(File(image!));
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Image.asset('images/c.png')),
                ],
              )
            ],
          );
        });
  }
}
