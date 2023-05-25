// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/utils/helpers/Country.dart';
import 'package:jollofradio/utils/scope.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  final dynamic user;
  final dynamic mode;
  final String title;
  
  const AccountScreen({ 
    Key? key, 
    required this.user,
    required this.mode,
    required this.title
  }) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late dynamic user;
  bool isLoading = true;
  bool showPassword = false;
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController telephone = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController about = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confPassword = TextEditingController();

  bool creator = false;
  bool isSaving = false;
  bool uploading = false;
  List<Map> forms = [];
  late String mode;
  List countries = [];

  @override
  void initState() {
    user = widget.user;
    mode = widget.mode;

    (() async {
      creator = ( await isCreator() );
      countries = await Countries.get();
    }());

    forms = [
      {
        "label": "Firstname",
        "icon": Iconsax.user,
        "controller": firstname
      },
      {
        "label": "Lastname",
        "icon": Iconsax.user,
        "controller": lastname
      },
      {
        "label": "Email",
        "icon": Iconsax.paperclip,
        "controller": email
      },
      {
        "label": "Telephone",
        "icon": Iconsax.call,
        "controller": telephone
      },
      {
        "label": "Country",
        "icon": Iconsax.global,
        "controller": country
      },
      {
        "label": "State",
        "icon": Iconsax.map,
        "controller": state
      },
      {
        "label": "Address",
        "icon": Iconsax.home,
        "controller": address
      },
      {
        "label": "City",
        "icon": Iconsax.map,
        "controller": city
      },
      {
        "label": "New Password",
        "icon": Iconsax.key,
        "controller": password,
        "password": true
      },
      {
        "label": "Confirm Password",
        "icon": Iconsax.key,
        "controller": confPassword,
        "password": true
      },
    ];

    firstname.text = user.firstname;
    lastname.text = user.lastname;
    email.text = user.email;
    telephone.text = user.telephone;
    country.text = user.country;
    state.text = user.state;
    address.text = user.address;
    city.text = user.city;
    about.text = user.about;
    
    super.initState();
  }

  Future<dynamic> uploadPhoto() async {
    File file;
    PlatformFile pickedFile;
    Uint8List? image;

    final dynamic result = await FilePicker.platform.pickFiles(
        type: FileType.image, 
        lockParentWindow: true, 
        withData: true
    );

    if (result == null) {
      return;
    }

    pickedFile = result.files.first;
    file = File(pickedFile.path.toString());
    image = result.files.first.bytes;

    setState(() {
      uploading = true;
    });

    Map data = {
      'file': pickedFile.name,
      'data': image,
      "userType": creator 
      ? 'creator' : 'user'
    };

    //send uyploaded file to the server
    await AuthController.upload(data).then((result) async {
      dynamic auth;
      setState(() {
        uploading = false;
      });

      if(result['error']){
        Toaster.error(result['message']);
        return;
      }

      if(creator){
        auth =
        Provider.of<CreatorProvider>(context, listen: false)
        .login(result['data']);
      }
      else {
        auth =
        Provider.of<UserProvider   >(context, listen: false)
        .login(result['data']);
      }

      setState(() {
        user = auth;
      });

      Toaster.show(
        status: 'success',
        position: 'TOP',
        message: result['message'] //initiates final callback
      );
    });
  }

  Future<dynamic> _saveProfile() async {
    Map data = {
      "firstname": firstname.text, //////////////////////////
      "lastname": lastname.text,
      "email": email.text,
      "telephone": telephone.text,
      "country": country.text,
      "state": state.text,
      "address": address.text,
      "city": city.text,
      "about": about.text,
      "password": password.text,
      "confirmPassword": confPassword.text,
      "userType": creator 
      ? 'creator' : 'user'
    };

    setState(() {
      isSaving = true;
    });

    return await AuthController.update(data).then((result){
      dynamic auth;
      setState(() {
        isSaving = false;
      });

      if(result['error']){
        Toaster.error(result['message']);
        return;
      }

      if(creator){
        auth =
        Provider.of<CreatorProvider>(context, listen: false)
        .login(result['data']);
      }
      else {
        auth =
        Provider.of<UserProvider   >(context, listen: false)
        .login(result['data']);
      }

      setState(() {
        user = auth;
      });

      Toaster.show(
        status: 'success',
        position: 'TOP',
        message: result['message'] //initiates final callback
      );

      Future.delayed(Duration(seconds: 1), () { /////////////
        RouteGenerator.goBack();
      });
    });
  }

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    email.dispose();
    telephone.dispose();
    country.dispose();
    state.dispose();
    address.dispose();
    city.dispose();
    about.dispose();
    password.dispose();
    confPassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.title, style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        )),
        leading: Buttons.back(),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(
          top: 0,
          left: 0, 
          right: 0
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB  (20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if(mode != 'account')
                      SizedBox(height: 20),
                      if(mode == 'account')
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 20),
                        alignment: Alignment.center,
                        child: Container(
                          width: 120,
                          height: 120,
                          padding: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: Color(0XFF0D1921),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Color(0XFFF0CF7B).withAlpha(50),
                              width: 3
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.expand,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  imageUrl: user.photo,
                                  placeholder: (context, url) {
                                    return Center(
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        )
                                      )
                                    );
                                  },
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.black.withOpacity(0.5),
                                  child: !uploading ? IconButton(
                                    onPressed: () => uploadPhoto(),
                                    icon: Icon(
                                      Iconsax.gallery_add, size: 25,
                                      color: Colors.white,
                                    ),
                                  ) : Center(
                                    child: SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )

                            ],
                          ),
                        ),
                      ),
                      ...forms.map<Widget>((form){
                        bool security = form.containsKey('password');
                        if(mode == 'security' && !security
                        || mode != 'security' &&  security)
                          return SizedBox();

                        Widget input = Input.primary(
                          form['controller'].text,
                          leadingIcon: form['icon'],
                          controller: form['controller'],
                          password: form
                          .containsKey('password') && !showPassword
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 10),
                            Labels.primary(form['label']),
                            SizedBox(
                              child: Stack(
                                children: [
                                  if(form['label'] == 'Country')
                                  GestureDetector(
                                    onTap: () {
                                      _showCountryDialog();
                                    },
                                    child: AbsorbPointer(child: input),
                                  )
                                  else
                                  input, //////////////////////////////

                                  if(security)
                                  Positioned(
                                    top: 18,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showPassword = !showPassword;
                                        });
                                      },
                                      child: Icon(!showPassword ? 
                                        Icons.visibility_off : Icons.visibility,
                                        size: 15,
                                        color: !showPassword ? 
                                        Colors.white30 : Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Buttons.primary(
                label: !isSaving ? "Save" : "Saving... ",
                onTap: () async => await _saveProfile (),
              ),
            ),
          ]
        )
      )
    );
  }

  Future _showCountryDialog() async {
    return showDialog(
      context: context, 
      builder: (context) {

        return Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.red
            ),
            child: Scaffold(
              body: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white24)
                              )
                            ),
                            child: Row(
                              mainAxisAlignment: 
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Labels.primary(
                                  "Select Country",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              key: const PageStorageKey<String>('country'),
                              shrinkWrap: true,
                              itemCount: countries.length,
                              itemBuilder: (context, index) {
                                Map data = countries[index] as Map;
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  minLeadingWidth: 30,
                                  leading: Container(
                                    width: 30,
                                    height: 20,
                                    color: Color(0XFF0D1921),
                                    child: Image.network(
                                      data['flag'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(data['name'], style: TextStyle(
                                    color: Colors.white
                                  )),
                                  onTap: () {
                                    RouteGenerator.goBack();
                                    country.text = data[ 'name' ].toString( );
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );

      },
    );
  }
}