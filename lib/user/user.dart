import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/user/updatecontact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import '../common/components.dart';
import 'api.dart';
import 'forms.dart';
import 'loginregister.dart';

class Profile extends StatelessWidget {
  final Map userData;

  const Profile({super.key, required this.userData});

  Widget _page(BuildContext context) {
    switch (userData['profile'] == null) {
      case true:
        return LoginRegister(
          onLog: () async {
            await homeKey.currentState!.updateUserData();
            String? profileKind =
                homeKey.currentState!.userData['profile']?['kind'];
            if (profileKind == null || profileKind == 'R') {
              homeKey.currentState!.pageIndex = 2;
            } else if (profileKind == 'C') {
              homeKey.currentState!.pageIndex = 3;
            } else {
              homeKey.currentState!.pageIndex = 1;
            }
            await homeKey.currentState!.getData();
          },
        );
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(96)),
                  clipBehavior: Clip.antiAlias,
                  height: 192,
                  width: 192,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: userData['profile']['image'] ?? '',
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.account_circle_rounded,
                      size: 192,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (userData['profile']['kind'] == 'R')
                Center(
                  child: Text(
                    userData['profile']['restaurantName'],
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.person_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title:
                    Text('${userData['first_name']} ${userData['last_name']}'),
                subtitle: Text(userData['profile']['kind'] == 'R'
                    ? 'Manager Name'
                    : 'Name'),
              ),
              const Divider(
                height: 10,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey,
              ),
              if (userData['profile']['kind'] == 'R' ||
                  userData['profile']['kind'] == 'D')
                for (var widget in [
                  ListTile(
                    onTap: () => href(
                      context,
                      url: userData['profile']['kind'] == 'R'
                          ? 'upi://pay?pa=${userData['profile']['upiID']}&pn=${userData['first_name']} ${userData['last_name']}&tn=FoodEx Payment to ${userData['profile']['restaurantName']}'
                          : 'upi://pay?pa=${userData['profile']['upiID']}&pn=${userData['first_name']} ${userData['last_name']}&tn=FoodEx Payment to delivery partner ${userData['first_name']} ${userData['last_name']}}',
                    ),
                    leading: Icon(
                      Icons.currency_rupee_rounded,
                      size: 32,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.qr_code_rounded),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Scan to Pay with UPI'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(
                                    child: Text(
                                      userData['profile']['kind'] == 'D'
                                          ? 'FoodEx delivery partner ${userData['profile']['user']['first_name']} ${userData['profile']['user']['last_name']}'
                                          : '${userData['profile']['restaurantName']}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  UPIPaymentQRCode(
                                    upiDetails: UPIDetails(
                                      upiID: userData['profile']['upiID'],
                                      payeeName: userData['profile']['kind'] ==
                                              'D'
                                          ? 'FoodEx delivery partner ${userData['first_name']} ${userData['last_name']}'
                                          : 'FoodEx Restaurant ${userData['profile']['restaurantName']} owner ${userData['first_name']} ${userData['last_name']}',
                                    ),
                                    upiQRErrorCorrectLevel:
                                        UPIQRErrorCorrectLevel.high,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: QrEyeShape.circle,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.circle,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    '${userData['first_name']} ${userData['last_name']}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'UPI ID: ${userData['profile']['upiID']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Close'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    title: Text('${userData['profile']['upiID']}'),
                    subtitle: const Text('UPI ID'),
                  ),
                  const Divider(
                    height: 10,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey,
                  ),
                ])
                  widget,
              ListTile(
                onTap: () => href(context,
                    scheme: 'tel', path: '+91${userData['username']}'),
                leading: Icon(
                  Icons.call,
                  size: 32,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: Text('+91 ${userData['username']}'),
                subtitle: const Text('Phone number'),
                trailing: IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdatePhone(
                          onSubmit: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(
                height: 10,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey,
              ),
              ListTile(
                onTap: () => href(context,
                    scheme: 'mailto', path: '${userData['email']}'),
                leading: Icon(
                  Icons.mail,
                  size: 32,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: Text('${userData['email']}'),
                subtitle: const Text('Email'),
                trailing: IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateEmail(
                          onSubmit: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(
                height: 10,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey,
              ),
              if (userData['id'] == homeKey.currentState!.userData['id'])
                for (var widget in [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.primary,
                        ),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 16),
                        ),
                        textStyle: const WidgetStatePropertyAll(
                          TextStyle(fontSize: 16),
                        ),
                        foregroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(
                              onSubmit: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.error,
                        ),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 16),
                        ),
                        textStyle: const WidgetStatePropertyAll(
                          TextStyle(fontSize: 16),
                        ),
                        foregroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.onError,
                        ),
                      ),
                      onPressed: () async {
                        await logout();
                        homeKey.currentState!.pageIndex = 2;
                        homeKey.currentState!.userData = {};
                        // homeKey.currentState!.setState(() {}); // Called immediately in the function in the next line
                        await homeKey.currentState!.getData();
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                ])
                  widget,
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _page(context),
        if (homeKey.currentState!.isLoadingUserData)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withAlpha(224),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Text("Refreshing..."),
            ),
          ),
      ],
    );
  }
}

class EditProfile extends StatefulWidget {
  final Function() onSubmit;

  const EditProfile({super.key, required this.onSubmit});
  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  bool _isLoading = false;
  late String _imageUrl;
  late FileImage? _image = null;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _imageUrl = homeKey.currentState!.userData['profile']['image'] ?? '';
    if (homeKey.currentState!.userData['profile']['kind'] == 'R') {
      restaurantnameController.text =
          homeKey.currentState!.userData['profile']['restaurantName'];
    }
    firstnameController.text = homeKey.currentState!.userData['first_name'];
    lastnameController.text = homeKey.currentState!.userData['last_name'];
    upiIDController.text = homeKey.currentState!.userData['profile']['upiID'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(96)),
                  clipBehavior: Clip.antiAlias,
                  height: 192,
                  width: 192,
                  child: GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxHeight: 512,
                        maxWidth: 512,
                      );
                      if (image != null) {
                        setState(() {
                          _image = FileImage(File(image.path));
                          _imageUrl = '';
                        });
                      }
                    },
                    child: _image == null
                        ? _imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: _imageUrl,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.account_circle_rounded,
                                  size: 192,
                                ),
                              )
                            : const Icon(
                                Icons.account_circle_rounded,
                                size: 192,
                              )
                        : Image(
                            image: _image!,
                            fit: BoxFit.cover,
                          ),
                  )),
            ),
            const SizedBox(height: 20),
            if (homeKey.currentState!.userData['profile']['kind'] == 'R')
              for (Widget widget in [
                restaurantnameForm(context),
                const SizedBox(height: 10),
              ])
                widget,
            firstnameForm(context),
            const SizedBox(height: 10),
            lastnameForm(context),
            const SizedBox(height: 10),
            if (homeKey.currentState!.userData['profile']['kind'] == 'R' ||
                homeKey.currentState!.userData['profile']['kind'] == 'D')
              for (Widget widget in [
                upiIDForm(context),
                const SizedBox(height: 20),
              ])
                widget,
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Theme.of(context).colorScheme.secondaryContainer;
                    }
                    return Theme.of(context).colorScheme.primaryContainer;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Theme.of(context)
                          .colorScheme
                          .onSecondaryContainer
                          .withAlpha(128);
                    }
                    return Theme.of(context).colorScheme.onPrimaryContainer;
                  },
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 16),
                ),
                textStyle: const WidgetStatePropertyAll(
                  TextStyle(fontSize: 16),
                ),
              ),
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                      });
                      bool validated = true;
                      Map profileData = {};
                      if (_image != null) {
                        profileData['image'] = _image;
                      }
                      if (homeKey.currentState!.userData['profile']['kind'] ==
                          'R') {
                        if (restaurantnameKey.currentState!.validate()) {
                          profileData['restaurantname'] =
                              restaurantnameController.text;
                        } else {
                          validated = false;
                        }
                      }
                      if (firstnameKey.currentState!.validate()) {
                        profileData['first_name'] = firstnameController.text;
                        profileData['last_name'] = lastnameController.text;
                      } else {
                        validated = false;
                      }
                      if (homeKey.currentState!.userData['profile']['kind'] ==
                              'R' ||
                          homeKey.currentState!.userData['profile']['kind'] ==
                              'D') {
                        if (upiIDKey.currentState!.validate()) {
                          profileData['upiID'] = upiIDController.text;
                        } else {
                          validated = false;
                        }
                      }
                      if (validated) {
                        if (await updateProfile(() => {}, profileData) == 0) {
                          widget.onSubmit();
                          await homeKey.currentState!.updateUserData();
                          await homeKey.currentState!.getData();
                        }
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    },
              child: Text(_isLoading ? 'Submiting...' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
